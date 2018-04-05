# Creating the Base Image for UpsideDownLEDs

## The software

I started with a fresh install of [Raspbian](https://www.raspberrypi.org/downloads/raspbian/) (Stretch with Desktop, March 2018).

## Step 1: Get a recent Raspbian image

https://downloads.raspberrypi.org/raspbian_lite/images/raspbian_lite-2018-03-14/2018-03-13-raspbian-stretch-lite.zip

Write it to a microSD card. [Etcher](https://etcher.io/) is good for this.

## Step 2: Set up SSH over USB

While the microSD card is still mounted on your computer:

```bash
$ cd /Volumes/boot
$ touch ssh
$ echo "dtoverlay=dwc2" >> config.txt
$ sed -i '' -E '1 s/^.+$/& modules-load=dwc2,g_ether/' cmdline.txt
```

> Note: See https://www.thepolyglotdeveloper.com/2016/06/connect-raspberry-pi-zero-usb-cable-ssh/ for more details.

Unmount the microSD card, put it in your Raspberry Pi, and power it up using a USB cable connected to your computer.
(Using a powered USB hub will provide the most power to the Raspberry Pi.)

## Step 3: Update it

The Raspberry Pi will broadcast its presence to the network as `raspberrypi.local` using Bonjour.

```bash
$ ssh pi@raspberrypi.local
```

To make logging in easier in the future, add your public key from whatever computer you're using to connect to `~/.ssh/authorized_keys`.

> Note: See https://dev.to/gr8raisin/raspberry-pi-zero-w-headless-setup-2n8b for more details

```bash
$ sudo dpkg-reconfigure locales
$ sudo dpkg-reconfigure keyboard-configuration
$ sudo dpkg-reconfigure tzdata
$ sudo apt-get update
$ sudo apt-get dist-upgrade
```

Reboot to pick up any changes.

### Step 4: Prerequisites

```bash
$ sudo apt-get update
# $ sudo apt-get install -y autoconf curl git libncurses5-dev libreadline-dev libssl-dev libtool m4 unzip
$ sudo apt-get install -y build-essential curl git unzip
```

Now would be a good time to make an image from the microSD card. Power down the Raspberry Pi, remove the microSD card,
and mount it on your computer.

```bash
$ sudo dd if=/dev/disk5 of=step-4.img status=progress
```

### Step 5: Erlang and Elixir

Raspbian Stretch Lite has Erlang 19.2.1 available, but the package in Debian has an obscene number of dependencies
(including packages that don't make sense on a Raspberry Pi).

As of this writing, [Erlang Solutions](https://www.erlang-solutions.com/) has Debian packages for Erlang OTP 20.1.7
and Elixir 1.6.1.

```bash
# use package from Erlang Solutions
$ wget https://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb
$ sudo dpkg -i erlang-solutions_1.0_all.deb
$ sudo apt-get update
$ sudo apt-get install erlang-nox erlang-dev elixir
```

> Note: https://www.erlang-solutions.com/resources/download.html talks about a package named `erlang-mini`, but that doesn't appear to exist.
