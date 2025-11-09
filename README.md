# USB Cleaner Box

A comprehensive USB security scanning and cleaning system for Raspberry Pi with LCD display, LED indicators, button controls, and audio feedback.

![Français](https://img.shields.io/badge/lang-fr-blue)
![English](https://img.shields.io/badge/lang-en-blue)
![Language](https://img.shields.io/github/languages/top/username/repository)
![License](https://img.shields.io/badge/license-MIT-blue)


## Features

- **USB Auto-Detection**: Automatically detects when a USB drive is plugged in
- **Dynamic Worker System**: Extensible plugin architecture for custom operations
- **Built-in Workers**:
  - Malware scanning with ClamAV
  - Executable file detection (Windows PE, Linux ELF, scripts)
  - Secure USB formatting (FAT32)
- **Interactive Interface**:
  - 16x2 LCD display for status and questions
  - Left/Right button controls for YES/NO responses
  - RGB LED indicators (Green/Orange/Red)
  - Audio feedback with buzzer
- **Extensibility**: Easy to add custom workers without modifying core code

## Hardware Requirements

- Raspberry Pi (tested on Raspberry Pi 3/4)
- 16x2 LCD display (I2C interface at address 0x27)
- 3 LEDs (Green: GPIO16, Orange: GPIO20, Red: GPIO21)
- 2 Push buttons (Left: GPIO23, Right: GPIO24)
- Buzzer (GPIO26)

## File Structure

```
UCB/
├── usb_cleaner_box.py       # Main application script
├── worker_manager.py        # Worker discovery and management
├── lcd_helper.py            # LCD display controller
├── led_control.py           # LED management
├── sound_helper.py          # Sound/buzzer controller
├── button_input.py          # Button input handler
├── usb_detection.py         # USB device detection
├── start.sh                 # Launcher script
├── workers/                 # Worker scripts directory
│   ├── analyze_malware.sh   # Malware scanner (order: 10)
│   ├── analyze_executables.sh  # Executable detector (order: 20)
│   ├── format_usb.sh        # USB formatter (order: 30)
│   └── TEMPLATE_worker.sh   # Template for new workers
├── README.md                # This file
├── USAGE.md                 # Usage guide
└── WORKER_GUIDE.md          # Worker development guide
```

## Worker System

The application uses a **dynamic worker system** for extensibility:

- Workers are shell scripts in the `workers/` directory
- Each worker is presented as a YES/NO question on the LCD
- Workers are auto-discovered and executed based on metadata
- Easy to add custom workers without modifying core code

See **[WORKER_GUIDE.md](WORKER_GUIDE.md)** for creating custom workers.

### Built-in Workers

1. **Full analysis?** (`analyze_malware.sh`) - ClamAV virus scanning
2. **Executable chk?** (`analyze_executables.sh`) - Detects suspicious executables
3. **Format USB?** (`format_usb.sh`) - Securely formats the USB drive

## Installation

1. Install required Python packages:
```bash
sudo apt-get update
sudo apt-get install python3-rpi.gpio python3-smbus
```

2. Install ClamAV (if not already installed):
```bash
sudo apt-get install clamav clamav-daemon
sudo freshclam  # Update virus definitions
```

3. Ensure all scripts are executable:
```bash
chmod +x UCB/*.sh
chmod +x UCB/*.py
chmod +x UCB/workers/*.sh
```

## Usage

Run the main application:
```bash
cd UCB
sudo python3 usb_cleaner_box.py
```

Or use the convenient launcher:
```bash
cd UCB
sudo ./start.sh
```

## Operation Flow

1. **Startup**
   - LCD displays: "USB drive" / "Cleaner Box"
   - Plays SNCF startup jingle
   - LED snake animation (2 cycles)

2. **Waiting for USB**
   - LCD displays: "Insert USB" / "drive..."
   - LEDs off
   - Waits for USB device to be plugged in

3. **USB Detected**
   - LCD displays: "USB detected" / "[size]"
   - Plays warning beep
   - Proceeds to questions

4. **Worker Questions**
   For each discovered worker (in order):
   - LCD displays worker question (max 16 chars)
   - Line 2: "NO           YES"
   - LEFT button = NO (skip worker)
   - RIGHT button = YES (run worker)

   Example flow:
   - "Full analysis?" → YES → Runs malware scan
   - "Executable chk?" → NO → Skips
   - "Format USB?" → YES → Runs formatting

5. **Worker Execution**
   - LCD: "Processing..." / "Please wait"
   - LED: Orange (processing)
   - Worker script runs with device name as parameter

6. **Worker Results**
   Based on worker output:

   - **THREAT** (keywords: infected, malware, threat):
     - LCD: "THREAT" / "DETECTED!"
     - LED: Red blinking (3 seconds)
     - Sound: Failure jingle

   - **WARNING** (keywords: suspicious, warning):
     - LCD: "WARNING" / "Check results"
     - LED: Orange blinking (3 seconds)
     - Sound: Warning beeps

   - **SUCCESS** (keywords: clean, safe, or exit 0):
     - LCD: "Completed" / "Success!"
     - LED: Green blinking (3 seconds)
     - Sound: Success jingle

   - **ERROR** (non-zero exit):
     - LCD: "ERROR" / "Worker failed"
     - LED: Red blinking (3 seconds)
     - Sound: Failure jingle

7. **Run Another?**
   - LCD: "Run another?" / "NO           YES"
   - If YES: Returns to step 4 (ask all workers again)
   - If NO: Proceeds to goodbye

8. **Goodbye**
   - LCD: "Bye bye!" / "Remove USB"
   - LED: Snake animation
   - Returns to "Waiting for USB" state

## Button Controls

- **LEFT Button (GPIO23)**: NO / Cancel
- **RIGHT Button (GPIO24)**: YES / Confirm

## LED Indicators

- **Green LED (GPIO16)**: Clean/Safe status
- **Orange LED (GPIO20)**: Warning/Processing
- **Red LED (GPIO21)**: Threat/Danger
- **Snake Animation**: Startup sequence (Green → Orange → Red → Orange)

## Audio Feedback

- **Startup**: SNCF jingle (4 notes)
- **USB Detected**: Warning beeps (3 short)
- **Clean Result**: Success jingle (ascending notes)
- **Threat Result**: Failure jingle (descending notes)

## Safety Features

- Cannot format system disk (sda is blocked)
- Double confirmation required for formatting
- Comprehensive error handling
- Device unmounting after operations
- GPIO cleanup on exit

## Troubleshooting

### LCD not displaying
- Check I2C address: `sudo i2cdetect -y 1`
- Verify I2C is enabled: `sudo raspi-config` → Interface Options → I2C

### USB not detected
- Check USB device appears: `lsblk`
- Verify permissions: Run with `sudo`

### LEDs not working
- Check GPIO pin connections
- Verify pin numbers in `led_control.py`

### Sound not playing
- Check buzzer connection to GPIO26
- Test buzzer separately

### Buttons not responding
- Check button connections (GPIO23, GPIO24)
- Verify pull-up resistors are configured

## Logs

Activity is logged to: `/var/log/usb_malware_scan.log`

View logs:
```bash
sudo tail -f /var/log/usb_malware_scan.log
```

## Credits

USB Cleaner Box - Interactive USB security scanning system for Raspberry Pi.

## License

Open source project.
