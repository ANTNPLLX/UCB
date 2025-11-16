#!/usr/bin/env python3
"""
lcd_ipc.py - IPC mechanism for LCD display updates from workers
"""

import os
import time
import threading
import json
from pathlib import Path

LCD_COMMAND_FILE = "/tmp/ucb_lcd_command"

class LCDIPCMonitor:
    """Monitor for LCD commands from worker scripts"""

    def __init__(self, lcd):
        self.lcd = lcd
        self.running = False
        self.thread = None

    def start(self):
        """Start monitoring for LCD commands"""
        self.running = True
        self.thread = threading.Thread(target=self._monitor_loop, daemon=True)
        self.thread.start()

    def stop(self):
        """Stop monitoring"""
        self.running = False
        if self.thread:
            self.thread.join(timeout=1.0)

    def _monitor_loop(self):
        """Monitor loop that checks for LCD commands"""
        last_mtime = 0

        while self.running:
            try:
                # Check if command file exists and has been modified
                if os.path.exists(LCD_COMMAND_FILE):
                    current_mtime = os.path.getmtime(LCD_COMMAND_FILE)

                    if current_mtime > last_mtime:
                        last_mtime = current_mtime

                        # Read and execute command
                        with open(LCD_COMMAND_FILE, 'r') as f:
                            content = f.read().strip()

                        if content:
                            try:
                                # Parse command (JSON format: {"line1": "...", "line2": "..."})
                                cmd = json.loads(content)
                                line1 = cmd.get('line1', '')
                                line2 = cmd.get('line2', '')

                                # Update LCD
                                self.lcd.display(line1, line2)

                            except json.JSONDecodeError:
                                # Fallback: treat as simple two-line format
                                lines = content.split('\n', 1)
                                line1 = lines[0] if len(lines) > 0 else ''
                                line2 = lines[1] if len(lines) > 1 else ''
                                self.lcd.display(line1, line2)

            except Exception as e:
                # Silently ignore errors to avoid disrupting main app
                pass

            # Check every 100ms
            time.sleep(0.1)


def send_lcd_command(line1, line2=""):
    """Send LCD command from worker script"""
    try:
        cmd = {
            'line1': line1,
            'line2': line2
        }
        with open(LCD_COMMAND_FILE, 'w') as f:
            json.dump(cmd, f)
            f.flush()
            os.fsync(f.fileno())
    except Exception:
        pass  # Silently fail if unable to send command


if __name__ == "__main__":
    import sys
    # Allow calling from command line: python3 lcd_ipc.py "Line 1" "Line 2"
    if len(sys.argv) >= 2:
        line1 = sys.argv[1]
        line2 = sys.argv[2] if len(sys.argv) >= 3 else ""
        send_lcd_command(line1, line2)
