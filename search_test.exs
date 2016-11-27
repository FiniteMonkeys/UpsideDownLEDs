defmodule SearchTest do
  def go do
    ExTwitter.search("upside down", [count: 3])
    |> Enum.map(fn tweet -> tweet.text end)
    |> Enum.join("\n-----\n")
    |> IO.puts
  end
end

SearchTest.go
