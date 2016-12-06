defmodule UpsideDownLeds.TwitterListener do
  use GenServer

  ## client API

  @doc """
  Starts the server.
  """
  def start_link(options \\ {}) do
    GenServer.start_link(__MODULE__, options, [])
  end

  ## server callbacks

  def init(options \\ {}) do
    puts_fn = if tuple_size(options) > 0 and is_function(elem(options, 0)) do
                elem(options, 0)
              else
                fn text -> IO.puts(text) end
              end

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
            puts_fn.(text)
          _ ->
            # ignore this tweet
            IO.puts "discarded tweet: #{tweet.text}"
        end
      end
    end)
    {:ok, pid}
  end

  def terminate(_reason, state) do
    cond do
      %{pid: pid} = state ->
        IO.puts "stopping stream filter"
        ExTwitter.stream_control(pid, :stop)
    end
  end
end
