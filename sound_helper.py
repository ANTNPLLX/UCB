#!/usr/bin/env python3
"""
sound_helper.py - Sound helper module for USB Cleaner Box
"""

import RPi.GPIO as GPIO
import time

# GPIO pin for the buzzer
BUZZER_PIN = 26
DUTY_CYCLE = 50

class SoundPlayer:
    """Sound player class for playing jingles and tones"""

    def __init__(self):
        # Set up the GPIO pin for the buzzer
        GPIO.setmode(GPIO.BCM)
        GPIO.setup(BUZZER_PIN, GPIO.OUT)
        self.pwm = None

    def play_note(self, frequency, duration):
        """Play a note at the specified frequency for the given duration"""
        # Start PWM with the desired frequency if not already started
        if self.pwm is None:
            self.pwm = GPIO.PWM(BUZZER_PIN, frequency)
            self.pwm.start(DUTY_CYCLE)
        else:
            self.pwm.ChangeFrequency(frequency)

        time.sleep(duration)

    def stop(self):
        """Stop the current sound"""
        if self.pwm is not None:
            self.pwm.stop()
            self.pwm = None

    def play_sncf_jingle(self):
        """Play SNCF startup jingle"""
        try:
            self.play_note(261.63, 0.25)  # C
            time.sleep(0.25)
            self.play_note(392.00, 0.25)  # G
            time.sleep(0.25)
            self.play_note(415.30, 0.25)  # Ab
            time.sleep(0.125)
            self.play_note(311.13, 0.5)   # Eb
        finally:
            self.stop()

    def play_success(self):
        """Play success sound"""
        tempo = 0.05
        try:
            self.play_note(196, tempo)      # G (low)
            time.sleep(tempo)
            self.play_note(261.63, tempo)   # C (high)
            time.sleep(tempo)
            self.play_note(329.63, tempo)   # E
            time.sleep(tempo)
            self.play_note(392.00, tempo)   # G
            time.sleep(tempo * 3)
            self.play_note(329.63, tempo)   # E
            time.sleep(tempo)
            self.play_note(392.00, 0.5)     # G (longer)
        finally:
            self.stop()

    def play_failed(self):
        """Play failure sound"""
        tempo = 0.1
        try:
            self.play_note(392.00, tempo)      # G
            time.sleep(tempo)
            self.play_note(369.99, tempo)      # F#
            time.sleep(tempo)
            self.play_note(349.23, tempo)      # F
            time.sleep(tempo)
            # Descending notes
            for _ in range(9):
                self.play_note(329.63, tempo / 3)  # E
                time.sleep(tempo / 3)
                self.play_note(331.13, tempo / 3)  # E (slightly higher)
                time.sleep(tempo / 3)
        finally:
            self.stop()

    def play_warning(self):
        """Play warning beep (3 beeps)"""
        tempo = 0.05
        try:
            for _ in range(4):
                self.play_note(220, tempo)  # A note
                time.sleep(tempo)
                self.stop()
                time.sleep(tempo)
        finally:
            self.stop()

    def play_beep(self):
        """Play single beep"""
        try:
            self.play_note(440, 0.15)  # A note
            time.sleep(0.15)
        finally:
            self.stop()

    def cleanup(self):
        """Cleanup GPIO resources"""
        self.stop()
        # Note: We don't call GPIO.cleanup() here as it might be shared
        # with other modules. The main script should handle final cleanup.
