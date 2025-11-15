#!/usr/bin/env python3
"""
log_helper.py - Logging helper module for USB Cleaner Box
"""

import os
from datetime import datetime

# Log file path
LOG_FILE = "/var/log/usb_malware_scan.log"

def log_message(message):
    """Log a message with timestamp"""
    timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    log_line = f"[{timestamp}] {message}"

    try:
        with open(LOG_FILE, 'a') as f:
            f.write(log_line + '\n')
        print(log_line)
    except Exception as e:
        print(f"Error writing to log: {e}")

def log_session_banner(device_info):
    """
    Log a session banner with comprehensive device information.
    This creates a clear marker for the start of a new session.
    """
    timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')

    banner_lines = [
        "",
        "=" * 80,
        f"{'SESSION START':^80}",
        "=" * 80,
        f"Timestamp:   {timestamp}",
        f"Device:      /dev/{device_info.get('device', 'Unknown')}",
        f"Size:        {device_info.get('size', 'Unknown')}",
        f"Label:       {device_info.get('label', 'No label')}",
        f"Filesystem:  {device_info.get('fstype', 'Unknown')}",
        f"Vendor:      {device_info.get('vendor', 'Unknown')}",
        f"Model:       {device_info.get('model', 'Unknown')}",
        f"Serial:      {device_info.get('serial', 'Unknown')}",
        "=" * 80,
        ""
    ]

    try:
        with open(LOG_FILE, 'a') as f:
            for line in banner_lines:
                f.write(line + '\n')
                print(line)
    except Exception as e:
        print(f"Error writing session banner: {e}")

def log_worker_choice(worker_name, choice):
    """
    Log user's choice for a worker (YES or NO)
    Format: [timestamp] --- "Worker_name": YES/NO
    """
    choice_text = "YES" if choice else "NO"
    log_message(f'--- "{worker_name}": {choice_text}')

def log_separator():
    """Log a separator line between sessions"""
    try:
        with open(LOG_FILE, 'a') as f:
            f.write("-" * 40 + '\n')
    except Exception as e:
        print(f"Error writing separator: {e}")
