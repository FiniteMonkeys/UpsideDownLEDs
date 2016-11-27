defmodule UpsideDownLeds.TwitterListener do
  use GenServer

  ## client API

  @doc """
  Starts the server.
  """
  def start_link(options \\ %{}) do
    GenServer.start_link(__MODULE__, options, [])
  end

  ## server callbacks

  def init(options \\ %{}) do
    cond do
      Map.has_key?(options, :lights) ->
        %{lights: lights_pid} = options
        pid = spawn(fn ->
          stream = ExTwitter.stream_filter(track: "@UpsideDownLEDs")
          IO.puts "starting stream filter"
          for tweet <- stream do
            ##
            ## The tweets we're interested in start with "@UpsideDownLEDs ". Everything else can be discarded.
            ## If we're interested, strip off "@UpsideDownLEDs " and send the rest to the BlinkingLights server.
            ##
            case Regex.run(~r/\A@UpsideDownLEDs\s+(.+)\z/i, tweet.text) do
              [_, text] ->
                # IO.puts "message from the Upside Down: #{text}"
                UpsideDownLeds.BlinkingLights.puts(lights_pid, text)
              _ ->
                # ignore this tweet
                IO.puts "discarded tweet: #{tweet.text}"
            end
          end
        end)

        {:ok, %{pid: pid}}
      true ->
        {:ok, %{}}
    end
  end

  def terminate(reason, state) do
    cond do
      %{pid: pid} = state ->
        IO.puts "stopping stream filter"
        ExTwitter.stream_control(pid, :stop)
    end
  end
end
