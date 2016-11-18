# UpsideDownLEDs

## The backstory

It started, as one may suppose things do these days, with a seemingly innocent exchange on [Slack](http://www.slack.com/).

![alt text](https://www.evernote.com/l/AHdc-C2QJkNJMLoutZ0Unp-G9JcQ-C_7qeoB/image.png)

...which led to...

![alt text](https://www.evernote.com/l/AHc_Wx0UxlhIQrnMFoxvrv-Kt7WWdmu_EXYB/image.png)

### Wait, what?

If you're not already familiar with [Stranger Things](http://www.imdb.com/title/tt4574334/), the part that's relevant to our tale here is this. A boy goes missing, and his mother is convinced that whatever otherworldly place he's gone to, he can communicate with her by controlling electric lights. So she strings up Christmas tree lights on a wall and paints a letter of the alphabet under each one, with the hope that her son will use them to spell out messages to her.

That's all you get from me. Seriously, if you want to know more, go watch it.

### So, what you're saying is...

![alt text](https://www.evernote.com/l/AHcvX99-cCBOUYOe5N60Sp-Cjyd1YSHJOAcB/image.png)

Sort of. The reality is going to turn out to be much more interesting.

## The hardware

I already had everything I needed on hand.

* Raspberry Pi Model B+, v1.2
* A breakout board for the Pi's GPIO connector (similar to the [Sparkfun Pi Wedge](https://www.sparkfun.com/products/retired/13091), but not as nice)
* A breadboard
* 26 LEDs of assorted colors
* 26 220&ohm; resistors
* A bunch of jumper wires

Twenty-six letters in the English alphabet means twenty-six LEDs. Conveniently, the Raspberry Pi Model B+ has twenty-six GPIO pins. That should make for a relatively simple and straightforward circuit design.

(Multiplexing the GPIO pins to require fewer of them is left as an exercise for the reader, or possibly for version 2.)

![picture of the breadboard](https://www.evernote.com/l/AHdGaO3zeEZKKqKnT3avZ5fb45XkTmazFw0/image.png)

The assignment of pins to LEDs was driven by the lengths of the jumper wires I had available and the layout of GPIO pins on the breakout board. If I ever get around to making a PCB for this, I'll make it less haphazard.

## The software

I started with a fresh install of [Raspbian](https://www.raspberrypi.org/downloads/raspbian/) (Jessie with Pixel, September 2016).
