defmodule UpsideDownLeds.Master do
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
    {:ok, lights} = UpsideDownLeds.BlinkingLights.start_link
    {:ok, twitter} = UpsideDownLeds.TwitterListener.start_link({ fn text -> UpsideDownLeds.BlinkingLights.puts(lights, text) end })
    {:ok, lights: lights, twitter: twitter}
  end
end
