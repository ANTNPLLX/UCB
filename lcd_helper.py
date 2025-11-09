#!/usr/bin/env python3
"""
lcd_helper.py - LCD display helper module for USB Cleaner Box
"""

import smbus
import time
import unicodedata
import RPi.GPIO as GPIO

# I2C Configuration
I2C_ADDR = 0x27
I2C_BUS = 1
LCD_POWER_PIN = 4

# LCD Commands
LCD_CHR = 1
LCD_CMD = 0

LCD_LINE_1 = 0x80
LCD_LINE_2 = 0xC0

LCD_BACKLIGHT = 0x08
ENABLE = 0b00000100

E_PULSE = 0.0005
E_DELAY = 0.0005

class LCD:
    """LCD display controller class"""

    def __init__(self):
        # Power on the LCD via GPIO4
        GPIO.setmode(GPIO.BCM)
        GPIO.setwarnings(False)
        GPIO.setup(LCD_POWER_PIN, GPIO.OUT)
        GPIO.output(LCD_POWER_PIN, GPIO.HIGH)

        # Wait for LCD to power up
        time.sleep(0.5)

        self.bus = smbus.SMBus(I2C_BUS)
        self.initialized = False

    def remove_accents(self, text):
        """Remove accents from text and convert to ASCII equivalents"""
        nfd = unicodedata.normalize('NFD', text)
        return ''.join(char for char in nfd if unicodedata.category(char) != 'Mn')

    def lcd_byte(self, bits, mode):
        """Send byte to data pins"""
        bits_high = mode | (bits & 0xF0) | LCD_BACKLIGHT
        bits_low = mode | ((bits << 4) & 0xF0) | LCD_BACKLIGHT

        self.bus.write_byte(I2C_ADDR, bits_high)
        self.lcd_toggle_enable(bits_high)

        self.bus.write_byte(I2C_ADDR, bits_low)
        self.lcd_toggle_enable(bits_low)

    def lcd_toggle_enable(self, bits):
        """Toggle enable"""
        time.sleep(E_DELAY)
        self.bus.write_byte(I2C_ADDR, (bits | ENABLE))
        time.sleep(E_PULSE)
        self.bus.write_byte(I2C_ADDR, (bits & ~ENABLE))
        time.sleep(E_DELAY)

    def init(self):
        """Initialize the LCD display"""
        self.lcd_byte(0x33, LCD_CMD)
        self.lcd_byte(0x32, LCD_CMD)
        self.lcd_byte(0x06, LCD_CMD)
        self.lcd_byte(0x0C, LCD_CMD)
        self.lcd_byte(0x28, LCD_CMD)
        self.lcd_byte(0x01, LCD_CMD)
        time.sleep(E_DELAY)
        self.initialized = True

    def display(self, line1, line2=""):
        """Display text on LCD (line1 and optional line2)"""
        if not self.initialized:
            self.init()

        # Remove accents and format
        line1 = self.remove_accents(line1)
        line2 = self.remove_accents(line2)

        # Pad or truncate to 16 chars
        line1 = line1.ljust(16, " ")[:16]
        line2 = line2.ljust(16, " ")[:16]

        # Display line 1
        self.lcd_byte(LCD_LINE_1, LCD_CMD)
        for char in line1:
            char_code = ord(char)
            if char_code < 128:
                self.lcd_byte(char_code, LCD_CHR)
            else:
                self.lcd_byte(ord('?'), LCD_CHR)

        # Display line 2
        self.lcd_byte(LCD_LINE_2, LCD_CMD)
        for char in line2:
            char_code = ord(char)
            if char_code < 128:
                self.lcd_byte(char_code, LCD_CHR)
            else:
                self.lcd_byte(ord('?'), LCD_CHR)

    def clear(self):
        """Clear the LCD display"""
        if not self.initialized:
            self.init()
        self.lcd_byte(0x01, LCD_CMD)
        time.sleep(E_DELAY)

    def off(self):
        """Turn off the LCD backlight and power"""
        try:
            if self.initialized:
                self.bus.write_byte(I2C_ADDR, 0x00)
        except Exception as e:
            print(f"Warning: Could not turn off LCD backlight: {e}")

        # Power off the LCD via GPIO4
        try:
            GPIO.output(LCD_POWER_PIN, GPIO.LOW)
        except Exception as e:
            print(f"Warning: Could not power off LCD: {e}")
