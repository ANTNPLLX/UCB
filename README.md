# USB Cleaner Box (UCB)

A comprehensive USB security scanning and cleaning system for Raspberry Pi with LCD display, LED indicators, button controls, and audio feedback.

## Features

- **USB Auto-Detection**: Automatically detects when a USB drive is plugged in
- **Malware Scanning**: Full malware analysis using ClamAV
- **Executable Analysis**: Detects suspicious executable files (Windows PE, Linux ELF, scripts)
- **Secure Formatting**: Safely formats USB drives with FAT32 filesystem
- **Interactive Interface**:
  - 16x2 LCD display for status and questions
  - Left/Right button controls for YES/NO responses
  - RGB LED indicators (Green/Orange/Red)
  - Audio feedback with buzzer

## Hardware Requirements

- Raspberry Pi (tested on Raspberry Pi 3/4)
- 16x2 LCD display (I2C interface at address 0x27)
- 3 LEDs (Green: GPIO16, Orange: GPIO20, Red: GPIO21)
- 2 Push buttons (Left: GPIO23, Right: GPIO24)
- Buzzer (GPIO26)

## File Structure

```
UCB/
├── usb_cleaner_box.py      # Main application script
├── lcd_helper.py            # LCD display controller
├── led_control.py           # LED management
├── sound_helper.py          # Sound/buzzer controller
├── button_input.py          # Button input handler
├── usb_detection.py         # USB device detection
├── format_usb.sh            # USB formatting script
└── README.md                # This file
```

## Dependencies

The application uses existing BNU scripts:
- `/home/antoine/raspberry/BNU/analyze_malware.sh` - ClamAV malware scanner
- `/home/antoine/raspberry/BNU/analyze_executables.sh` - Executable file detector

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
chmod +x /home/antoine/raspberry/BNU/UCB/*.sh
chmod +x /home/antoine/raspberry/BNU/UCB/*.py
```

## Usage

Run the main application:
```bash
sudo python3 /home/antoine/raspberry/BNU/UCB/usb_cleaner_box.py
```

Or make it run at startup by adding to `/etc/rc.local`:
```bash
sudo python3 /home/antoine/raspberry/BNU/UCB/usb_cleaner_box.py &
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

4. **Interactive Questions**
   Each question displays:
   - Line 1: The question
   - Line 2: "NO           YES"
   - Use LEFT button for NO, RIGHT button for YES

   Questions asked:
   - "Full analysis?" - Run ClamAV malware scan
   - "Executable chk?" - Check for executable files
   - "Format USB?" - Format the USB drive
     - If YES: "Confirm format?" - Double confirmation

5. **Results Display**
   Based on analysis results:

   - **Malware/Executables Found** (RED):
     - LCD: "THREAT" / "DETECTED!"
     - LED: Red blinking (5 seconds)
     - Sound: Failure jingle
     - LCD: "DO NOT USE" / "this USB!"

   - **Uncertain/Error** (ORANGE):
     - LCD: "UNCERTAIN" / "result"
     - LED: Orange blinking (5 seconds)
     - Sound: Warning beeps
     - LCD: "Use with" / "caution"

   - **Clean** (GREEN):
     - LCD: "USB is" / "CLEAN!"
     - LED: Green blinking (5 seconds)
     - Sound: Success jingle
     - LCD: "Safe to use!" / ""

6. **Loop**
   - Returns to "Waiting for USB" state
   - Ready for next device

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

Created for the BNU (Boitier Nettoyeur USB) project.
Built using existing BNU infrastructure and scripts.

## License

Part of the BNU project.
