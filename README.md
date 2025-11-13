# USB Cleaner Box

![Status](https://img.shields.io/badge/status-active-success.svg)
![Platform](https://img.shields.io/badge/platform-Raspberry%20Pi-red.svg)
![Python](https://img.shields.io/badge/python-3.7+-blue.svg)
![License](https://img.shields.io/badge/license-Open%20Source-green.svg)

An interactive USB security scanning and cleaning system for Raspberry Pi with LCD display, LED indicators, button controls, and audio feedback.

## Features

- 🔍 **Malware Scanning** - ClamAV virus detection
- 🔒 **Executable Detection** - Find suspicious files
- 💾 **Secure Formatting** - Clean USB drives safely
- 🔌 **Plug & Play** - Auto-detects USB devices
- 🎛️ **Interactive Interface** - LCD + Buttons + LEDs + Sound
- 🧩 **Extensible** - Add custom workers without modifying code
- 📊 **Logging** - All operations logged for review

## Quick Start

```bash
# 1. Clone or download
git clone <repository-url> UCB
cd UCB

# 2. Install dependencies
sudo apt-get update
sudo apt-get install -y python3-rpi.gpio python3-smbus clamav

# 3. Enable I2C
sudo raspi-config
# Interface Options → I2C → Enable

# 4. Make executable
chmod +x *.sh workers/*.sh

# 5. Run
sudo python3 usb_cleaner_box.py
```

## How It Works

1. **Insert USB** - Device auto-detects
2. **Answer Questions** - Use LEFT (NO) / RIGHT (YES) buttons
3. **Review Results** - LED colors show status:
   - 🟢 Green = Safe/Clean
   - 🟠 Orange = Warning/Processing
   - 🔴 Red = Threat/Error
4. **Remove USB** - When prompted "Bye bye!"

## Hardware Requirements

| Component | Specification |
|-----------|--------------|
| **Microcontroller** | Raspberry Pi 3/4 or Zero 2 W |
| **Display** | 16x2 I2C LCD (address 0x27) |
| **LEDs** | 3x 5mm (Green, Orange, Red) |
| **Buttons** | 2x Tactile push buttons |
| **Buzzer** | Passive piezo buzzer (5V) |
| **Power** | 9V battery or USB 5V/2A |

**Total Cost**: ~$110-117 (see [Hardware Wiring Guide](Documents/HARDWARE_WIRING.md) for detailed BOM with pricing)

## Documentation

📚 **Complete documentation available in `Documents/` folder:**

| Document | Description |
|----------|-------------|
| **[Installation Guide](Documents/INSTALLATION.md)** | Step-by-step setup instructions, dependencies, systemd service configuration |
| **[Usage Guide](Documents/USAGE.md)** | How to use the device with ASCII flow diagrams, button controls, and workflows |
| **[Worker Development](Documents/WORKER_GUIDE.md)** | Create custom workers with examples, templates, and best practices |
| **[Hardware Guide](Documents/HARDWARE.md)** | Component specifications, testing procedures, and hardware troubleshooting |
| **[Hardware Wiring](Documents/HARDWARE_WIRING.md)** | Complete wiring diagrams (9V battery & USB powered) with BOM and prices |
| **[FAQ](Documents/FAQ.md)** | 50+ common questions, troubleshooting tips, and detailed answers |

## Worker System

The USB Cleaner Box uses a **dynamic worker system** for extensibility:

- **Workers** are shell scripts in the `workers/` directory
- Each worker = one YES/NO question on the LCD
- Auto-discovered on startup (no code changes needed)
- Can be enabled/disabled individually
- Executed based on user choices
- Results analyzed and displayed automatically

### Built-in Workers

| Order | Question | Description | Requirements |
|-------|----------|-------------|--------------|
| 10 | "Full analysis?" | ClamAV malware scanning | ClamAV |
| 20 | "Executable chk?" | Detect suspicious executables | - |
| 25 | "Vitrification?" | Convert Office docs to PDF, neutralize other files | LibreOffice |
| 30 | "Format USB?" | Secure USB formatting (FAT32) | - |

### Create Custom Workers

```bash
# 1. Copy template
cp workers/TEMPLATE_worker.sh workers/my_worker.sh

# 2. Edit metadata (max 16 chars for question!)
# WORKER_QUESTION=My question?
# WORKER_ORDER=25
# WORKER_ENABLED=true

# 3. Implement logic (receives device name as $1)

# 4. Make executable
chmod +x workers/my_worker.sh

# Done! Auto-discovered on next run
```

### Enable/Disable Workers

To disable a worker without deleting it:

```bash
# Edit the worker file
nano workers/format_usb.sh

# Change WORKER_ENABLED to false
# WORKER_ENABLED=false

# Restart service
sudo systemctl restart usb-cleaner-box.service
```

Disabled workers are skipped - their questions won't appear on the LCD.

See [Worker Development Guide](Documents/WORKER_GUIDE.md) for details and examples.

## Project Structure

```
UCB/
├── usb_cleaner_box.py       # Main application
├── worker_manager.py        # Worker discovery engine
├── lcd_helper.py            # LCD controller
├── led_control.py           # LED management
├── sound_helper.py          # Buzzer/audio
├── button_input.py          # Button handling
├── usb_detection.py         # USB auto-detection
├── start.sh                 # Launcher script
├── workers/                 # Worker scripts
│   ├── analyze_malware.sh
│   ├── analyze_executables.sh
│   ├── format_usb.sh
│   └── TEMPLATE_worker.sh   # Template for new workers
├── Documents/               # Complete documentation
│   ├── INSTALLATION.md
│   ├── USAGE.md
│   ├── WORKER_GUIDE.md
│   ├── HARDWARE.md
│   ├── HARDWARE_WIRING.md
│   ├── FAQ.md
│   └── WORKER_TEMPLATE.sh
└── README.md                # This file
```

## GPIO Pin Assignments

| Component | GPIO (BCM) | Physical Pin |
|-----------|------------|--------------|
| Green LED | GPIO16 | Pin 36 |
| Orange LED | GPIO20 | Pin 38 |
| Red LED | GPIO21 | Pin 40 |
| Left Button | GPIO23 | Pin 16 |
| Right Button | GPIO24 | Pin 18 |
| Buzzer | GPIO26 | Pin 37 |
| LCD Power | GPIO4 | Pin 7 |
| LCD SDA | GPIO2 | Pin 3 |
| LCD SCL | GPIO3 | Pin 5 |

## Requirements

### Software
- Raspberry Pi OS (Raspbian)
- Python 3.7+
- RPi.GPIO library
- smbus library (I2C)
- ClamAV (for malware scanning worker)
- LibreOffice (for vitrification worker - auto-installs if needed)

### Hardware
- See [Hardware Guide](Documents/HARDWARE.md) or [Hardware Wiring](Documents/HARDWARE_WIRING.md)

## Auto-Start on Boot

Install as systemd service:

```bash
# Edit service file paths
nano usb-cleaner-box.service

# Install
sudo cp usb-cleaner-box.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable usb-cleaner-box.service
sudo systemctl start usb-cleaner-box.service

# Check status
sudo systemctl status usb-cleaner-box.service
```

## Logs

All operations are logged:

```bash
# View logs
sudo tail -f /var/log/usb_malware_scan.log
```

## Troubleshooting

### Quick Fixes

| Problem | Solution |
|---------|----------|
| LCD blank | Check I2C: `sudo i2cdetect -y 1` |
| USB not detected | Run with sudo |
| LEDs not working | Check polarity and resistors |
| No sound | Verify passive buzzer + transistor driver |
| ClamAV errors | Update: `sudo freshclam` |

See [FAQ](Documents/FAQ.md) for detailed troubleshooting.

## Contributing

Contributions welcome!

- **New workers** - Add functionality
- **Bug fixes** - Improve stability
- **Documentation** - Help others
- **Hardware designs** - Alternative builds
- **Translations** - Make it global

## Safety & Security

⚠️ **Important**:
- Always run with sudo (required for device access)
- Formatting **permanently deletes all data**
- Red LED = Do not use that USB drive!
- Keep virus definitions updated
- Review logs for detailed information

## License

Open source hardware and software. See individual files for specific licenses.

## Support

- 📖 Read the [Documentation](Documents/)
- 🐛 Check [FAQ](Documents/FAQ.md)
- 📝 Review [Logs](#logs)
- 💬 Open an issue (if applicable)

## Acknowledgments

- **ClamAV** - Open-source antivirus engine
- **Raspberry Pi Foundation** - Incredible platform
- **Community** - Contributors and testers

---

**Quick Links:**
- [Installation](Documents/INSTALLATION.md) | [Usage Guide](Documents/USAGE.md) | [Worker Development](Documents/WORKER_GUIDE.md) | [Hardware](Documents/HARDWARE.md) | [Hardware Wiring](Documents/HARDWARE_WIRING.md) | [FAQ](Documents/FAQ.md)

---

Made with ❤️ for security and privacy
