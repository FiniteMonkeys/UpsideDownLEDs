defmodule UpsideDownLeds.TwitterListener do
  use GenServer

  require Logger

  ##
  ## client API
  ##

  @doc """
  Starts the server.
  """
  def start_link(options) do
    GenServer.start_link(__MODULE__, options, name: __MODULE__)
  end

  ##
  ## server callbacks
  ##

  def init({pid_server: pid_server}) do
    pid = spawn(fn ->
      stream = ExTwitter.stream_filter(track: "@UpsideDownLEDs")
      Logger.info "starting stream filter"
      for tweet <- stream do
        ##
        ## The tweets we're interested in start with "@UpsideDownLEDs ". Everything else can be discarded.
        ## If we're interested, strip off "@UpsideDownLEDs " and send the rest to the BlinkingLights server.
        ##
        case Regex.run(~r/\A@UpsideDownLEDs\s+(.+)\z/i, tweet.text) do
          [_, text] ->
            # IO.puts "message from the Upside Down: #{text}"
            GenServer.cast(pid_server, {:puts, text})
          _ ->
            # ignore this tweet
            Logger.info "discarded tweet: #{tweet.text}"
        end
      end
    end)
    {:ok, pid}
  end

  def terminate(_reason, state) do
    cond do
      %{pid: pid} = state ->
        Logger.info "stopping stream filter"
        ExTwitter.stream_control(pid, :stop)
    end
  end
end
