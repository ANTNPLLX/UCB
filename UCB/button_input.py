#!/usr/bin/env python3
"""
button_input.py - Button input module for USB Cleaner Box
"""

import RPi.GPIO as GPIO
import time

# Button pin assignments
BUTTON_PIN_LEFT = 23
BUTTON_PIN_RIGHT = 24

class ButtonInput:
    """Button input handler class"""

    def __init__(self):
        # Set up GPIO mode
        GPIO.setmode(GPIO.BCM)

        # Set up button pins with pull-up resistors
        GPIO.setup(BUTTON_PIN_LEFT, GPIO.IN, pull_up_down=GPIO.PUD_UP)
        GPIO.setup(BUTTON_PIN_RIGHT, GPIO.IN, pull_up_down=GPIO.PUD_UP)

    def is_left_pressed(self):
        """Check if left button is pressed"""
        return GPIO.input(BUTTON_PIN_LEFT) == GPIO.LOW

    def is_right_pressed(self):
        """Check if right button is pressed"""
        return GPIO.input(BUTTON_PIN_RIGHT) == GPIO.LOW

    def wait_for_button(self, timeout=None):
        """
        Wait for a button press and return which button was pressed.
        Returns: 'left', 'right', or None (if timeout)
        """
        start_time = time.time()

        # Wait for button release first (debounce)
        while self.is_left_pressed() or self.is_right_pressed():
            time.sleep(0.01)
            if timeout and (time.time() - start_time) > timeout:
                return None

        # Reset start time after buttons are released
        start_time = time.time()

        # Wait for button press
        while True:
            if self.is_left_pressed():
                # Debounce delay
                time.sleep(0.05)
                if self.is_left_pressed():
                    # Wait for release
                    while self.is_left_pressed():
                        time.sleep(0.01)
                    return 'left'

            if self.is_right_pressed():
                # Debounce delay
                time.sleep(0.05)
                if self.is_right_pressed():
                    # Wait for release
                    while self.is_right_pressed():
                        time.sleep(0.01)
                    return 'right'

            # Check timeout
            if timeout and (time.time() - start_time) > timeout:
                return None

            time.sleep(0.01)

    def wait_for_yes_no(self, timeout=None):
        """
        Wait for YES (right) or NO (left) button press.
        Returns: True (YES/right), False (NO/left), or None (timeout)
        """
        result = self.wait_for_button(timeout)
        if result == 'right':
            return True
        elif result == 'left':
            return False
        else:
            return None

    def cleanup(self):
        """Cleanup GPIO resources"""
        # Note: We don't call GPIO.cleanup() here as it might be shared
        # with other modules. The main script should handle final cleanup.
        pass
