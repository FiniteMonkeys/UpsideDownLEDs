defmodule SmokeTest do
  defp blink(pid, delay_during \\ 500, delay_after \\ 500) do
    ElixirALE.GPIO.write(pid, 0)
    :timer.sleep(delay_during)
    ElixirALE.GPIO.write(pid, 1)
    :timer.sleep(delay_after)
  end

  def go do
    pin_defs = %{
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
    }

    pin_map = pin_defs
              |> Enum.map(fn {letter, pin_no} ->
                            {:ok, pid} = ElixirALE.GPIO.start_link(pin_no, :output)
                            {letter, pid}
                          end)
              |> Enum.into(%{})

    pin_map |> Enum.each(fn {_, pid} -> ElixirALE.GPIO.write(pid, 1) end)

    ?A..?Z |> Enum.each(fn letter -> pin_map[to_string([letter])] |> blink(300, 0); end)

    :timer.sleep(2000)

    "HELLO" |> String.to_charlist |> Enum.each(fn letter -> pin_map[to_string([letter])] |> blink(); end)
  end
end

SmokeTest.go
