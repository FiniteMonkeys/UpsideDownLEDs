defmodule UpsideDownLeds.BlinkingLights do
  use GenServer

  ##
  ## client API
  ##

  @doc """
  Starts the server.
  """
  def start_link do
    GenServer.start_link(__MODULE__, :ok, [])
  end

  @doc """
  Displays the string on the LEDs.

  Returns `{:ok, pid}` on success, `:error` otherwise.
  """
  def puts(server, str) do
    GenServer.cast(server, {:puts, str |> String.upcase |> String.replace(~r/[^A-Z ]+/, "")})
  end

  ##
  ## server callbacks
  ##

  @delay_during        500
  @delay_after         500
  @delay_nonprinting  1000

  def init(:ok) do
    pin_map = %{
      "A" => 13,
      "B" => 16,
      "C" => 21,
      "D" =>  4,
      "E" => 17,
      "F" => 20,
      "G" => 12,
      "H" => 19,
      "I" =>  2,
      "J" => 25,
      "K" =>  3,
      "L" => 14,
      "M" => 15,
      "N" =>  5,
      "O" =>  6,
      "P" => 11,
      "Q" => 27,
      "R" =>  7,
      "S" => 24,
      "T" =>  8,
      "U" => 23,
      "V" => 26,
      "W" => 18,
      "X" => 22,
      "Y" =>  9,
      "Z" => 10,
    } |> Enum.map(fn {letter, pin_no} ->
                    {:ok, pid} = ElixirALE.GPIO.start_link(pin_no, :output)
                    {letter, pid}
                  end)
      |> Enum.into(%{})

    pin_map |> Enum.each(fn {_, pid} -> ElixirALE.GPIO.write(pid, 1) end)

    {:ok, pin_map}
  end

  def handle_cast({:puts, str}, pin_map) do
    str
      |> String.to_charlist
      |> Enum.each(
           fn letter ->
             case Map.fetch(pin_map, to_string([letter])) do
               {:ok, pid} ->
                 blink(pid)
               _ ->
                 :timer.sleep(@delay_nonprinting)
             end
           end
         )

    {:noreply, pin_map}
  end

  defp blink(pid, delay_during \\ @delay_during, delay_after \\ @delay_after) do
    ElixirALE.GPIO.write(pid, 0)
    :timer.sleep(delay_during)
    ElixirALE.GPIO.write(pid, 1)
    :timer.sleep(delay_after)
  end
end
