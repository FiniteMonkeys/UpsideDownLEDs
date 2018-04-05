import RPi.GPIO as GPIO
import string
import time

pindefs = {
    'A': 13,
    'B': 16,
    'C': 21,
    'D':  4,
    'E': 17,
    'F': 20,
    'G': 12,
    'H': 19,
    'I':  2,
    'J': 25,
    'K':  3,
    'L': 14,
    'M': 15,
    'N':  5,
    'O':  6,
    'P': 11,
    'Q': 27,
    'R':  7,
    'S': 24,
    'T':  8,
    'U': 23,
    'V': 26,
    'W': 18,
    'X': 22,
    'Y':  9,
    'Z': 10,
}

def blink(pin, delay_during=0.5, delay_after=0.5):
    GPIO.output(pin, GPIO.LOW)
    time.sleep(delay_during)
    GPIO.output(pin, GPIO.HIGH)
    time.sleep(delay_after)

GPIO.setmode(GPIO.BCM)

for pin in pindefs.values():
    GPIO.setup(pin, GPIO.OUT)
    GPIO.output(pin, GPIO.HIGH)

for letter in list(string.ascii_uppercase):
    blink(pindefs[letter], 0.3, 0)

time.sleep(2)

blink(pindefs["H"])
blink(pindefs["E"])
blink(pindefs["L"])
blink(pindefs["L"])
blink(pindefs["O"])

GPIO.cleanup()
