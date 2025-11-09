#!/usr/bin/env python3
"""
led_control.py - LED control module for USB Cleaner Box
"""

import RPi.GPIO as GPIO
import time
import threading

# LED pin assignments
GREEN_LED_PIN = 16
ORANGE_LED_PIN = 20
RED_LED_PIN = 21

class LEDController:
    """LED controller class for managing RGB LEDs"""

    def __init__(self):
        # Set up GPIO mode (BCM mode)
        GPIO.setmode(GPIO.BCM)

        # Set GPIO pins as output
        GPIO.setup(GREEN_LED_PIN, GPIO.OUT)
        GPIO.setup(ORANGE_LED_PIN, GPIO.OUT)
        GPIO.setup(RED_LED_PIN, GPIO.OUT)

        # Initialize all LEDs to OFF
        GPIO.output(GREEN_LED_PIN, GPIO.LOW)
        GPIO.output(ORANGE_LED_PIN, GPIO.LOW)
        GPIO.output(RED_LED_PIN, GPIO.LOW)

        self.stop_animation = False
        self.animation_thread = None

    def all_off(self):
        """Turn off all LEDs"""
        self.stop_animation = True
        if self.animation_thread and self.animation_thread.is_alive():
            self.animation_thread.join()

        GPIO.output(GREEN_LED_PIN, GPIO.LOW)
        GPIO.output(ORANGE_LED_PIN, GPIO.LOW)
        GPIO.output(RED_LED_PIN, GPIO.LOW)

    def green_on(self):
        """Turn on green LED only"""
        self.all_off()
        GPIO.output(GREEN_LED_PIN, GPIO.HIGH)

    def orange_on(self):
        """Turn on orange LED only"""
        self.all_off()
        GPIO.output(ORANGE_LED_PIN, GPIO.HIGH)

    def red_on(self):
        """Turn on red LED only"""
        self.all_off()
        GPIO.output(RED_LED_PIN, GPIO.HIGH)

    def _snake_animation(self, duration=2.0, speed=0.2):
        """Internal method to run snake animation"""
        self.stop_animation = False
        start_time = time.time()

        while not self.stop_animation and (time.time() - start_time) < duration:
            # Green LED on
            GPIO.output(GREEN_LED_PIN, GPIO.HIGH)
            time.sleep(speed)
            GPIO.output(GREEN_LED_PIN, GPIO.LOW)

            if self.stop_animation:
                break

            # Orange LED on
            GPIO.output(ORANGE_LED_PIN, GPIO.HIGH)
            time.sleep(speed)
            GPIO.output(ORANGE_LED_PIN, GPIO.LOW)

            if self.stop_animation:
                break

            # Red LED on
            GPIO.output(RED_LED_PIN, GPIO.HIGH)
            time.sleep(speed)
            GPIO.output(RED_LED_PIN, GPIO.LOW)

            if self.stop_animation:
                break

            # Orange LED on (reverse)
            GPIO.output(ORANGE_LED_PIN, GPIO.HIGH)
            time.sleep(speed)
            GPIO.output(ORANGE_LED_PIN, GPIO.LOW)

        self.all_off()

    def snake(self, duration=2.0, speed=0.2):
        """Run LED snake animation for specified duration"""
        self.all_off()
        self.animation_thread = threading.Thread(
            target=self._snake_animation,
            args=(duration, speed)
        )
        self.animation_thread.start()

    def snake_blocking(self, duration=2.0, speed=0.2):
        """Run LED snake animation (blocking)"""
        self.all_off()
        self._snake_animation(duration, speed)

    def _blink_animation(self, pin, duration=3.0, speed=0.5):
        """Internal method to blink a specific LED"""
        self.stop_animation = False
        start_time = time.time()

        while not self.stop_animation and (time.time() - start_time) < duration:
            GPIO.output(pin, GPIO.HIGH)
            time.sleep(speed)
            if self.stop_animation:
                break
            GPIO.output(pin, GPIO.LOW)
            time.sleep(speed)

        GPIO.output(pin, GPIO.LOW)

    def blink_red(self, duration=3.0, speed=0.5):
        """Blink red LED for specified duration"""
        self.all_off()
        self._blink_animation(RED_LED_PIN, duration, speed)

    def blink_orange(self, duration=3.0, speed=0.5):
        """Blink orange LED for specified duration"""
        self.all_off()
        self._blink_animation(ORANGE_LED_PIN, duration, speed)

    def blink_green(self, duration=3.0, speed=0.5):
        """Blink green LED for specified duration"""
        self.all_off()
        self._blink_animation(GREEN_LED_PIN, duration, speed)

    def cleanup(self):
        """Cleanup GPIO resources"""
        self.stop_animation = True
        if self.animation_thread and self.animation_thread.is_alive():
            self.animation_thread.join()
        self.all_off()
        # Note: We don't call GPIO.cleanup() here as it might be shared
        # with other modules. The main script should handle final cleanup.
