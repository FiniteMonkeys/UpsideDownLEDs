defmodule UpsideDownLeds.Application do
  use Application

  require Logger

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    Logger.info("Starting BlinkingLights process")
    {:ok, lights} = UpsideDownLeds.BlinkingLights.start_link

    Logger.info("Starting TwitterListener process")
    {:ok, _twitter} = UpsideDownLeds.TwitterListener.start_link({ fn text -> UpsideDownLeds.BlinkingLights.puts(lights, text) end })

    {:ok, self()}
  end
end
