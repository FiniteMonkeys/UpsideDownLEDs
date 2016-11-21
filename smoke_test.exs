defmodule SmokeTest do
  defp blink(pid, delay_during \\ 500, delay_after \\ 500) do
    Gpio.write(pid, 1)
    :timer.sleep(delay_during)
    Gpio.write(pid, 0)
    :timer.sleep(delay_after)
  end

  def go do
    pin_defs = %{
      "A" => 4,
      "B" => 2,
      "C" => 27,
      "D" => 22,
      "E" => 26,
      "F" => 19,
      "G" => 13,
      "H" => 6,
      "I" => 5,
      "J" => 11,
      "K" => 9,
      "L" => 10,
      "M" => 3,
      "N" => 14,
      "O" => 15,
      "P" => 8,
      "Q" => 18,
      "R" => 23,
      "S" => 21,
      "T" => 17,
      "U" => 24,
      "V" => 25,
      "W" => 7,
      "X" => 12,
      "Y" => 16,
      "Z" => 20,
    }

    pin_map = pin_defs |> Enum.map(fn pair -> {letter, pin_no} = pair; {:ok, pid} = Gpio.start_link(pin_no, :output); {letter, pid} end) |> Enum.into(%{})

    ?A..?Z |> Enum.each(fn letter -> pid = pin_map[to_string([letter])]; blink(pid, 300, 0); end)

    :timer.sleep(2000)

    "HELLO" |> String.to_charlist |> Enum.each(fn letter -> pid = pin_map[to_string([letter])]; blink(pid); end)
  end
end

SmokeTest.go
