defmodule UpsideDownLeds.Supervisor do
  use Supervisor

  ##
  ## API
  ##

  @doc """
  Starts the supervisor.
  """
  def start_link do
    Supervisor.start_link(__MODULE__, :ok)
  end

  ##
  ## callbacks
  ##

  def init(:ok) do
    children = [
      worker(UpsideDownLeds.TwitterListener, []),
      worker(UpsideDownLeds.BlinkingLights, [])
    ]
    supervise(children, strategy: :one_for_one)
  end
end
