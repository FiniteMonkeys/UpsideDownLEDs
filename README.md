# UpsideDownLEDs

## The backstory

It started, as one may suppose things do these days, with a seemingly innocent exchange on [Slack](https://kcelixir.slack.com/).

![I really want to make "Stranger Things Christmas lights" just to do it](documentation/images/alan.png)

...which led to...

![I'm imagining a Pi running Nerves and Twitter client code](documentation/images/craig.png)

### Wait, what?

If you're not already familiar with [Stranger Things](http://www.imdb.com/title/tt4574334/), the part that's relevant to our tale here is this. A boy goes missing, and his mother is convinced that whatever otherworldly place he's gone to, he can communicate with her by controlling electric lights. So she strings up Christmas tree lights on a wall and paints a letter of the alphabet under each one, with the hope that her son will use them to spell out messages to her.

That's all you get from me. Seriously, if you want to know more, go watch it.

### So, what you're saying is...

![All the pieces are in place for an LED Ouija board](documentation/images/jordan.png)

Sort of. The reality is (hopefully) going to turn out to be much more interesting.

## Table of Contents

* [Iteration 0](#iteration-0)
  * [Step 1: The smoke test](#step-1-the-smoke-test)
  * [Step 2: Elixir](#step-2-elixir)
* [Iteration 1](#iteration-1)
  * [Step 3: Adding a GenServer](#step-3-adding-a-genserver)
  * [Step 4: The ghost in the machine](#step-4-the-ghost-in-the-machine)
  * [Step 5: Putting together the pieces](#step-5-putting-together-the-pieces)
  * [Step 6: Nerves](#step-6-nerves)

## Iteration 0

### The hardware

I already had everything I needed on hand.

* Raspberry Pi Model B+, v1.2
* A breakout board for the Pi's GPIO connector (similar to the [Sparkfun Pi Wedge](https://www.sparkfun.com/products/retired/13091), but not as nice)
* A breadboard
* 26 LEDs of assorted colors
* 2 220&ohm; resistors
* A bunch of jumper wires

Twenty-six letters in the English alphabet means twenty-six LEDs. Conveniently, the Raspberry Pi Model B+ has twenty-six GPIO pins. That made for a relatively simple and straightforward circuit design.

(Multiplexing the GPIO pins to require fewer of them is left as an exercise for the reader, or possibly for version 2.)

![picture of the breadboard](documentation/images/UpsideDownLEDs%20Prototype_bb.png)

The assignment of pins to LEDs was driven by the lengths of the jumper wires I had available and the layout of GPIO pins on the breakout board. If I ever get around to making a PCB for this, I'll make it less haphazard.

### The software

A full description of how I set up the initial disk image can be found in `Base Image.md`.

### Step 1: The smoke test

Raspbian comes with a Python library for controlling the GPIO pins already installed, so that was as good a place to start as any.

```python
import RPi.GPIO as GPIO
import string
import time

pindefs = {
    'A':  4, 'B':  2, 'C': 27, 'D': 22, 'E': 26, 'F': 19, 'G': 13, 'H':  6, 'I':  5, 'J': 11, 'K':  9, 'L': 10, 'M':  3,
    'N': 14, 'O': 15, 'P':  8, 'Q': 18, 'R': 23, 'S': 21, 'T': 17, 'U': 24, 'V': 25, 'W':  7, 'X': 12, 'Y': 16, 'Z': 20,
}

def blink(pin, delay_during=0.5, delay_after=0.5):
    GPIO.output(pin, GPIO.HIGH)
    time.sleep(delay_during)
    GPIO.output(pin, GPIO.LOW)
    time.sleep(delay_after)

GPIO.setmode(GPIO.BCM)

for pin in pindefs.values():
    GPIO.setup(pin, GPIO.OUT)

for letter in list(string.ascii_uppercase):
    blink(pindefs[letter], 0.3, 0)

time.sleep(2)

blink(pindefs["H"])
blink(pindefs["E"])
blink(pindefs["L"])
blink(pindefs["L"])
blink(pindefs["O"])

GPIO.cleanup()
```

When I run this on the Raspberry Pi (via `python smoke_test.py`), each of the LEDs lights up in sequence, then it blinks out the word `HELLO`.

### Step 2: Elixir

Python's all well and good, but could I do the same thing using Elixir?

To access the GPIO pins, I employed [elixir_ale](https://github.com/fhunleth/elixir_ale). After installing it as a dependency in `mix.exs` and running `mix deps.get`, it was straightforward to use.

```elixir
iex(1)> {:ok, pid} = ElixirALE.GPIO.start_link(4, :output)
{:ok, #PID<0.235.0>}
iex(2)> ElixirALE.GPIO.write(pid, 1)
:ok
iex(3)> ElixirALE.GPIO.write(pid, 0)
:ok
iex(4)>
```

You can't see it from where you're sitting (unless you're playing along at home with your own Raspberry Pi), but the "A" LED just turned on and off again.

```elixir
defmodule SmokeTest do
  defp blink(pid, delay_during \\ 500, delay_after \\ 500) do
    ElixirALE.GPIO.write(pid, 1)
    :timer.sleep(delay_during)
    ElixirALE.GPIO.write(pid, 0)
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

    pin_map = pin_defs |> Enum.map(fn pair -> {letter, pin_no} = pair; {:ok, pid} = ElixirALE.GPIO.start_link(pin_no, :output); {letter, pid} end) |> Enum.into(%{})

    ?A..?Z |> Enum.each(fn letter -> pid = pin_map[to_string([letter])]; blink(pid, 300, 0); end)

    :timer.sleep(2000)

    "HELLO" |> String.to_charlist |> Enum.each(fn letter -> pid = pin_map[to_string([letter])]; blink(pid); end)
  end
end

SmokeTest.go
```

Running this (via `mix run smoke_test.exs`) produces the same output as the Python script above.

## Iteration 1

Now that I had a proof of concept, it was time to make it better looking and more permanent.

### The hardware

The Raspberry Pi remains the same, but I added a [terminal block breakout HAT](https://www.adafruit.com/product/2711) to better secure the wires.
My daughter Abigail ([@ItsIronicallyUs](https://twitter.com/ItsIronicallyUs)) recreated the wall from the show, into which I drilled holes and mounted the LEDs.

![picture of the front of the wall](documentation/images/front.png)
![picture of the back of the wall](documentation/images/back.png)

### The software

The only change to the initial software was remapping the GPIO pins, as I hadn't preserved the old mapping when I wired up the new one.

### Step 3: Adding a GenServer

I wanted this code to eventually be persistent and long-lived, so it seemed like a good idea at this point to make it into a server. I borrowed heavily from [the GenServer example on the Elixir web site](http://elixir-lang.org/getting-started/mix-otp/genserver.html); the result is in `lib/upside_down_leds/blinking_lights.ex`.

```elixir
iex(1)> {:ok, lights} = UpsideDownLeds.BlinkingLights.start_link
{:ok, #PID<0.235.0>}
iex(2)> UpsideDownLeds.BlinkingLights.puts(lights, "HELLO")
:ok
iex(3)> UpsideDownLeds.BlinkingLights.puts(lights, "ELEVEN LOVES EGGOS")
:ok
iex(4)>
```

### Step 4: The ghost in the machine

In the show, the blinking lights are used to receive messages from an unseen messenger in an otherworldly, forbidding place. I, too, wanted to receive messages from unseen messengers in an otherworldly, forbidding place.

In other words, Twitter.

I reserved the Twitter handle [@UpsideDownLEDs](https://twitter.com/UpsideDownLEDs) so that messages sent to it will be displayed on the blinking lights. To be able to receive them on the Raspberry Pi, I used the [ExTwitter](https://github.com/parroty/extwitter) library.

```elixir
def application do
  [applications: [:logger, :extwitter]]
end

defp deps do
  [
    {:elixir_ale, "~> 0.5.6"},
    {:extwitter, "~> 0.7.0"},
    {:oauth, git: "https://github.com/tim/erlang-oauth.git"}
  ]
end
```

Note that ExTwitter depends on the Erlang `oauth` library, but doesn't include it as a dependency itself, so it needs to be included explicitly.

Access to the Twitter API via OAuth requires four tokens (two of them secret) that can be generated by going to https://apps.twitter.com and creating a new app. Then add them to `config/config.exs`.

```elixir
config :extwitter, :oauth, [
   consumer_key: "U7LD5Jtnq5kwQggwWICgZKA6K",
   consumer_secret: "",
   access_token: "789505576778674176-hcvnZ1inik53KVUKfG8zQ2NcMsgYbIi",
   access_token_secret: ""
]
```

(I'm not including the secret values here or in the file in Github, and you shouldn't either.)

There are two flavors of API that can be used. I used the search API as a one-off to test access to the Twitter API, and the streaming API to actually listen for messages to display.

#### Search API

```elixir
Interactive Elixir (1.3.4) - press Ctrl+C to exit (type h() ENTER for help)
iex(1)> ExTwitter.search("upside down", [count: 3]) |>
...(1)> Enum.map(fn tweet -> tweet.text end) |>
...(1)> Enum.join("\n-----\n") |>
...(1)> IO.puts
```

will print out the most recent three tweets containing `upside down`.

#### Streaming API

```elixir
Interactive Elixir (1.3.4) - press Ctrl+C to exit (type h() ENTER for help)
iex(1)> stream = ExTwitter.stream_filter(track: "@UpsideDownLEDs") |>
...(1)> Stream.map(fn tweet -> tweet.text end) |>
...(1)> Stream.map(fn text -> IO.puts "#{text}\n-----\n" end)
#Stream<[enum: #Function<49.87278901/2 in Stream.resource/3>,
 funs: [#Function<46.87278901/1 in Stream.map/2>,
  #Function<46.87278901/1 in Stream.map/2>]]>
iex(2)> Enum.to_list(stream)
```

will print out all references to the `@UpsideDownLEDs` Twitter handle as they appear in the Twitter firehose stream.

I wrapped the ExTwitter code in another GenServer similar to the one for the blinking lights; the result is in `lib/upside_down_leds/twitter_listener.ex`.

### Step 5: Putting together the pieces

One key difference between `UpsideDownLeds.BlinkingLights` and `UpsideDownLeds.TwitterListener` is that an anonymous function is passed to `UpsideDownLeds.TwitterListener.start_link`. The latter uses the anonymous function to "write" the tweet text to the former.

```elixir
Interactive Elixir (1.3.4) - press Ctrl+C to exit (type h() ENTER for help)
iex(1)> {:ok, lights} = UpsideDownLeds.BlinkingLights.start_link
{:ok, #PID<0.147.0>}
iex(2)> {:ok, twitter} = UpsideDownLeds.TwitterListener.start_link { fn text -> UpsideDownLeds.BlinkingLights.puts(lights, text) end }
{:ok, #PID<0.175.0>}
starting stream filter
iex(3)>
```

Two processes are created and linked. Now, any tweets that start with `@UpsideDownLEDs` will be displayed on the blinking lights.

To make it a little simpler, `lib/upside_down_leds.ex` now contains a GenServer as well that starts and links the other two modules. Firing up the app is now simpler.

```elixir
Interactive Elixir (1.3.4) - press Ctrl+C to exit (type h() ENTER for help)
iex(1)> {:ok, pid} = UpsideDownLeds.start_link
{:ok, #PID<0.147.0>}
iex(2)>
```

### Step 6: Nerves

At this point, the software has to be started manually. It would be better if it were self-contained and self-starting.
We can do that with [Nerves](https://nerves-project.org).

```bash
$ brew install fwup squashfs coreutils
$ mix archive.install hex nerves_bootstrap
```

Normally, you'd start from scratch with a new Nerves project. Since I've already started and all of my source files are in `git`, I'm going to create the project in my existing directory, let Nerves overwrite any files it wants, then use `git diff` to merge in the changes.

```bash
$ mix nerves.new . --app upside_down_leds
```

The most significant changes are the addition of the `UpsideDownLEDs.Application` module and a substantial reworking of `mix.exs`.

`UpsideDownLEDs.Application` contains the entry point for the application. It does pretty much the same thing that was added to `UpsideDownLEDs.start_link/1` in the previous step, so that code can be moved here.

The changes to `mix.exs` are unlike anything I've seen in any other Elixir project. Since Nerves supports a number of different hardware configurations, `mix.exs` is highly parameterized. For instance, the list of dependencies is built from three different pieces which depend on the targeted architecture and configuration.

```elixir
defp deps do
  [{:nerves, "~> 0.9", runtime: false}] ++ deps(@target)
end

# Specify target specific dependencies
defp deps("host"), do: []

defp deps(target) do
  [
    {:elixir_ale, "~> 1.0"},
    {:extwitter, "~> 0.9.1"},
    {:nerves_runtime, "~> 0.4"},
    {:oauth, git: "https://github.com/tim/erlang-oauth.git"},
    {:shoehorn, "~> 0.2"},
  ] ++ system(target)
end

defp system("rpi"), do: [{:nerves_system_rpi, ">= 0.0.0", runtime: false}]
defp system("rpi0"), do: [{:nerves_system_rpi0, ">= 0.0.0", runtime: false}]
defp system("rpi2"), do: [{:nerves_system_rpi2, ">= 0.0.0", runtime: false}]
defp system("rpi3"), do: [{:nerves_system_rpi3, ">= 0.0.0", runtime: false}]
defp system("bbb"), do: [{:nerves_system_bbb, ">= 0.0.0", runtime: false}]
defp system("ev3"), do: [{:nerves_system_ev3, ">= 0.0.0", runtime: false}]
defp system("qemu_arm"), do: [{:nerves_system_qemu_arm, ">= 0.0.0", runtime: false}]
defp system("x86_64"), do: [{:nerves_system_x86_64, ">= 0.0.0", runtime: false}]
defp system(target), do: Mix.raise "Unknown MIX_TARGET: #{target}"
```

Note that our dependencies from previous steps are only included if the target is not `"host"`. `elixir_ale` in particular doesn't make sense on anything other than an embedded Linux platform.

> Note: The other two dependencies, `extwitter` and `oauth`, might be usable for testing on the host if `elixir_ale` can be mocked out somehow. I'm going to leave that for a future iteration.

In previous versions of Nerves, you had to specify the target configuration when you created the project. Since it's now parameterized in `mix.exs`, you specify it when running `mix`.

```bash
$ MIX_TARGET=rpi mix deps.get
$ MIX_TARGET=rpi mix firmware
$ MIX_TARGET=rpi mix firmware.burn -d firmware.img
```

The first command should be self-explanatory. The second creates a firmware bundle file, and the third generates an image file suitable for writing to a microSD card. To do the actual writing, I like [Etcher](https://etcher.io).

After writing the microSD card, I removed it from my host computer, inserted it in the Raspberry Pi, and powered up.
