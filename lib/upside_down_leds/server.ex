defmodule UpsideDownLeds.Server do
  use GenServer
  import Supervisor.Spec

  defmodule State do
    defstruct pid_sv: nil, pid_twitter_listener: nil, pid_blinking_lights: nil
  end

  ##
  ## API
  ##

  @doc """
  Starts the server.
  """
  def start_link(pid_sv) do
    GenServer.start_link(__MODULE__, pid_sv, name: __MODULE__)
  end

  @doc """
  Displays the string on the LEDs.

  Returns `{:ok, pid}` on success, `:error` otherwise.
  """
  def puts(server, str) do
    GenServer.cast(server, {:puts, str})
  end

  ##
  ## callbacks
  ##

  def init(pid_sv) when is_pid(pid_sv) do
    init([], %State{pid_sv: pid_sv})
  end

  # other state options go here

  def init([], state) do
    send(self, :start_twitter_listener)
    send(self, :start_blinking_lights)
    {:ok, state}
  end

  def handle_info(:start_twitter_listener, state = %{pid_sv: pid_sv}) do
    {:ok, pid_twitter_listener} = Supervisor.start_child(pid_sv, worker(UpsideDownLeds.TwitterListener, [pid_server: self]))
    {:noreply, %{state | pid_twitter_listener: pid_twitter_listener}}
  end

  def handle_info(:start_blinking_lights, state = %{pid_sv: pid_sv}) do
    {:ok, pid_blinking_lights} = Supervisor.start_child(pid_sv, worker(UpsideDownLeds.BlinkingLights, [pid_server: self]))
    {:noreply, %{state | pid_blinking_lights: pid_blinking_lights}}
  end

  def handle_cast(msg = {:puts, _}, state = %{pid_blinking_lights: pid_blinking_lights}) do
    GenServer.cast(pid_blinking_lights, msg)
    {:noreply, state}
  end
end
