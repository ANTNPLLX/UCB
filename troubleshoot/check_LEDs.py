import RPi.GPIO as GPIO
import time

# Set up GPIO mode
GPIO.setmode(GPIO.BCM)

# Set up LED pin (GPIO13) and button pin (GPIO20)
GREEN_LED_PIN = 16
ORANGE_LED_PIN = 20
RED_LED_PIN = 21

# Set GPIO13 as an output pin for the LED
GPIO.setup(GREEN_LED_PIN, GPIO.OUT)
GPIO.setup(ORANGE_LED_PIN, GPIO.OUT)
GPIO.setup(RED_LED_PIN, GPIO.OUT)


GPIO.output(GREEN_LED_PIN, GPIO.HIGH)  # Turn LED on
time.sleep(0.5)
GPIO.output(GREEN_LED_PIN, GPIO.LOW)  # Turn LED on
time.sleep(0.5)

GPIO.output(ORANGE_LED_PIN, GPIO.HIGH)  # Turn LED on
time.sleep(0.5)
GPIO.output(ORANGE_LED_PIN, GPIO.LOW)  # Turn LED on
time.sleep(0.5)

GPIO.output(RED_LED_PIN, GPIO.HIGH)  # Turn LED on
time.sleep(0.5)
GPIO.output(RED_LED_PIN, GPIO.LOW)  # Turn LED on
time.sleep(0.5)



