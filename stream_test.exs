defmodule StreamTest do
  def go do
    stream = ExTwitter.stream_filter(track: "@UpsideDownLEDs")
             |> Stream.map(fn tweet -> tweet.text end)
             |> Stream.map(fn text -> IO.puts "#{text}\n-----\n" end)
    Enum.to_list(stream)
  end
end

StreamTest.go
