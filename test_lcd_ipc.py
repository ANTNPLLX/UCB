#!/usr/bin/env python3
"""
Test script to verify LCD IPC is working
This simulates what the main app does
"""

import time
import sys
sys.path.insert(0, '/home/antoine/raspberry/UCB')

from lcd_helper import LCD
from lcd_ipc import LCDIPCMonitor

print("Initializing LCD...")
lcd = LCD()
lcd.init()

print("Starting LCD IPC Monitor...")
monitor = LCDIPCMonitor(lcd)
monitor.start()

print("Monitor running. Now test with:")
print("  source /home/antoine/raspberry/UCB/workers/lcd_helper.sh")
print("  display_on_lcd 'Test Line 1' 'Test Line 2'")
print()
print("Press Ctrl+C to stop...")

try:
    while True:
        time.sleep(1)
except KeyboardInterrupt:
    print("\nStopping monitor...")
    monitor.stop()
    lcd.off()
    print("Done!")
