defmodule UpsideDownLeds.TwitterListener do
  use GenServer

  ## client API

  @doc """
  Starts the server.
  """
  def start_link(output_fn \\ fn text -> text end) do
    GenServer.start_link(__MODULE__, output_fn, [])
  end

  ## server callbacks

  def init(output_fn) do
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
            output_fn.(text)
          _ ->
            # ignore this tweet
            IO.puts "discarded tweet: #{tweet.text}"
        end
      end
    end)
    {:ok, pid}
  end

  def terminate(reason, state) do
    cond do
      %{pid: pid} = state ->
        IO.puts "stopping stream filter"
        ExTwitter.stream_control(pid, :stop)
    end
  end
end
