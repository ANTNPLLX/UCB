# Frequently Asked Questions (FAQ)

Common questions and answers about the USB Cleaner Box.

## General Questions

### What is the USB Cleaner Box?

The USB Cleaner Box is an interactive USB security scanning and cleaning system built on Raspberry Pi. It allows you to scan USB drives for malware, check for suspicious executables, and securely format drives - all through a simple LCD interface with button controls.

### Who is this for?

- IT professionals who need to scan USB drives regularly
- Security-conscious users who want to check unknown USB drives
- Anyone who handles USB drives from untrusted sources
- Educational institutions teaching cybersecurity
- Home users who want extra protection

### How does it work?

1. Insert a USB drive
2. Answer YES/NO questions on the LCD display
3. Workers (scripts) run based on your choices
4. Results shown via LED colors, sounds, and LCD messages
5. Remove USB when prompted

### Is it safe to use?

Yes! The device is designed for safety:
- Read-only scanning by default
- Format only with confirmation
- All operations logged
- No network connection required
- Open-source code you can review

---

## Hardware Questions

### What hardware do I need?

**Minimum**:
- Raspberry Pi (Pi 3/4 or Zero 2 W)
- 16x2 I2C LCD display
- 3 LEDs (green, orange, red)
- 2 push buttons
- Passive buzzer
- Power supply (9V battery or USB)

See [Hardware Guide](HARDWARE.md) for complete list.

### Can I use a Raspberry Pi Zero W?

Yes, but it will be slower. Pi Zero 2 W is recommended for better performance. Regular Pi Zero (without W) works but you'll lose wireless capabilities.

### What if my LCD has a different I2C address?

Edit `lcd_helper.py` and change:
```python
I2C_ADDR = 0x27  # Change to your address
```

Find your address with:
```bash
sudo i2cdetect -y 1
```

### Can I use different GPIO pins?

Yes! Edit the respective Python modules to change pin assignments. Make sure to update both code and wiring.

### How much power does it use?

- Idle: ~150mA (~0.75W)
- Scanning: ~500mA (~2.5W)
- Peak: ~700mA (~3.5W)

Use a 2A power supply to be safe.

### How long does a 9V battery last?

Typical 9V alkaline battery (500-600mAh):
- 4-6 hours of active use
- Longer with rechargeable NiMH batteries
- Use DC-DC converter for better efficiency

---

## Software Questions

### What operating system do I need?

Raspberry Pi OS (formerly Raspbian). The latest version is recommended.

### Do I need internet connection?

Only for initial setup and updating virus definitions. The device works offline for scanning.

### How do I update virus definitions?

```bash
sudo freshclam
```

Run this weekly for best protection.

### Can I add my own workers?

Yes! The worker system is extensible. Create a shell script in `workers/` directory with proper metadata. See [Worker Guide](WORKER_GUIDE.md).

### Where are scan results stored?

Log file: `/var/log/usb_malware_scan.log`

View with:
```bash
sudo tail -f /var/log/usb_malware_scan.log
```

### Can I run this without the LCD?

Technically yes, but you won't see prompts or results. The LCD is essential for the interactive interface. You could modify the code to use only terminal output.

---

## Usage Questions

### How long does a scan take?

Depends on USB size and worker:
- **Executable check**: 30-120 seconds
- **Small USB (< 1GB)**: 2-5 minutes
- **Medium USB (1-8GB)**: 5-10 minutes
- **Large USB (> 8GB)**: 10-30 minutes
- **Format**: 30-120 seconds

### What file types can it detect?

**Malware scan** (ClamAV):
- Viruses, trojans, worms
- Ransomware
- Adware, spyware
- Malicious scripts
- And more (5+ million signatures)

**Executable check**:
- Windows: .exe, .dll, .sys, .scr, .com, .bat, .cmd, .msi
- Linux: ELF binaries
- Scripts: .sh, .ps1, .vbs, .js, .wsf, .hta

### Does it clean infected files?

No, it only detects them. The recommended action is to format the USB drive if malware is detected.

### Can it recover deleted files?

No, this is a security scanner, not a recovery tool. However, you could create a custom worker for file recovery.

### What if the scan times out?

The worker has a 10-minute timeout. For very large USB drives:
- Split the scan across multiple runs
- Increase timeout in `worker_manager.py`
- Use a faster Raspberry Pi model

### Can I scan multiple USBs in a row?

Yes! After each USB:
1. Wait for "Bye bye! / Remove USB"
2. Remove first USB
3. Insert next USB
4. Process repeats

---

## Troubleshooting

### LCD shows garbage characters

**Causes**:
- Wrong I2C address
- Poor I2C connections
- Electromagnetic interference

**Solutions**:
1. Check I2C address with `sudo i2cdetect -y 1`
2. Update address in `lcd_helper.py`
3. Check SDA/SCL wiring
4. Add pull-up resistors (4.7kΩ) to I2C lines

### USB not detected

**Causes**:
- USB not recognized by system
- Permission issues
- Auto-mount conflict

**Solutions**:
1. Run with sudo: `sudo python3 usb_cleaner_box.py`
2. Check `lsblk` to see if USB appears
3. Disable auto-mount in Raspberry Pi OS
4. Check debug output in terminal

### Buttons don't respond

**Causes**:
- Wrong wiring
- Button not momentary
- GPIO conflict

**Solutions**:
1. Verify one terminal to GPIO, other to GND
2. Use momentary (not latching) buttons
3. Test buttons with simple script
4. Check internal pull-ups are enabled

### No sound from buzzer

**Causes**:
- Active buzzer instead of passive
- Missing transistor driver
- Wrong polarity

**Solutions**:
1. Use passive buzzer (not active)
2. Add NPN transistor driver circuit
3. Check buzzer polarity
4. Test buzzer directly with 5V

### ClamAV not working

**Causes**:
- Not installed
- Out of date definitions
- Insufficient memory

**Solutions**:
1. Install: `sudo apt-get install clamav`
2. Update: `sudo freshclam`
3. Use Pi with more RAM (1GB+)
4. Close other applications

### Device randomly reboots

**Causes**:
- Insufficient power
- Voltage drops
- Overheating

**Solutions**:
1. Use 2A+ power supply
2. Use shorter/thicker power cables
3. Add heatsink to voltage regulator
4. Improve ventilation

---

## Advanced Questions

### Can I run workers in parallel?

No, workers run sequentially to avoid resource conflicts and ensure accurate results.

### Can I write workers in Python?

Yes! Make the script executable with `#!/usr/bin/env python3` shebang and proper metadata. See template.

### Can I access the GPIO from workers?

Not recommended. GPIO is managed by the main application. Workers should focus on file system operations.

### Can I modify the main application?

Yes! It's open source. However, using the worker system is recommended for extensibility.

### How do I create a worker that asks multiple questions?

Workers only get one YES/NO question. For complex workflows, create multiple workers or use the worker to launch an interactive script.

### Can I disable specific built-in workers?

Remove execute permission:
```bash
chmod -x workers/worker_name.sh
```

Or delete the `# WORKER_QUESTION=` line from the worker script.

### Can this detect zero-day malware?

No. ClamAV uses signature-based detection. It can't detect brand-new, unknown malware. However, it's still effective against most threats.

### Is the formatting secure (DoD wipe)?

No, it's a quick format. For secure wiping, create a custom worker using `shred` or similar tools.

### Can I add a database of results?

Yes, create a custom worker that logs to a database. Workers have full access to the file system.

### Can I use this commercially?

Check the license. The hardware designs are open source. The software follows its own license terms.

---

## Error Messages

### "ERROR: Device /dev/sdX does not exist"

**Meaning**: USB device not found

**Solution**: Verify USB is plugged in, check `lsblk`

### "ERROR: Failed to mount device"

**Meaning**: Cannot access USB filesystem

**Solution**: USB may be corrupted, try different USB, check permissions

### "WARNING: ClamAV is not installed"

**Meaning**: Antivirus software missing

**Solution**: `sudo apt-get install clamav clamav-daemon`

### "Worker timeout after 10 minutes"

**Meaning**: Operation took too long

**Solution**: USB too large or slow, increase timeout or use faster Pi

### "Permission denied"

**Meaning**: Insufficient privileges

**Solution**: Run with sudo: `sudo python3 usb_cleaner_box.py`

---

## Performance

### How can I speed up scans?

1. Use faster Raspberry Pi (Pi 4 > Pi 3 > Pi Zero)
2. Use faster USB 3.0 drives
3. Update ClamAV to latest version
4. Reduce workers to only essential ones
5. Use faster SD card in Raspberry Pi

### Why is formatting slow?

FAT32 formatting is quick (30-120 sec). If it's slower:
- Large USB drive
- Bad sectors on USB
- Slow USB controller
- Underpowered Pi

### Can I overclock the Pi?

Yes, but not recommended:
- May cause instability during scans
- Higher power consumption
- Increased heat
- Shorter hardware lifespan

---

## Safety & Security

### Is my data at risk?

No, unless you choose to format:
- Scanning is read-only
- No files are modified
- All operations logged
- Format requires confirmation

### Can infected USB harm the device?

No. The device only scans files, doesn't execute them. Raspberry Pi OS provides isolation.

### Should I trust the results?

ClamAV is industry-standard and reliable, but:
- No antivirus is 100% accurate
- Update definitions regularly
- Use multiple security tools for critical checks
- Trust red LED warnings

### What if I accidentally format?

Data is unrecoverable with standard tools. Backup important data before using USB Cleaner Box.

### Can this device get infected?

Extremely unlikely:
- Scanning doesn't execute files
- Pi OS provides sandboxing
- No auto-run features
- Regular updates prevent vulnerabilities

---

## Customization

### Can I change the startup jingle?

Yes! Edit `sound_helper.py` and modify the `play_sncf_jingle()` function with your own note frequencies.

### Can I add more LEDs?

Yes! Add GPIO connections and update `led_control.py`. You could add status LEDs, battery indicators, etc.

### Can I use an OLED display instead?

Yes, but requires code changes. Replace LCD calls with OLED library calls. OLEDs offer more display options.

### Can I add a battery level indicator?

Yes! Add voltage divider circuit and read with ADC. Display on LCD or add status LED.

### Can I remote control it over network?

Yes, you could create a web interface or SSH access. However, physical isolation is a security feature.

---

## Support & Community

### Where can I get help?

1. Check this FAQ
2. Review documentation in `Documents/` folder
3. Check log files for errors
4. Open an issue on GitHub (if applicable)

### How do I report a bug?

Include:
- Hardware configuration
- Software version
- Steps to reproduce
- Error messages
- Log files

### Can I contribute?

Yes! Contributions welcome:
- New workers
- Bug fixes
- Documentation improvements
- Hardware designs
- Translations

### Where are updates posted?

Check the GitHub repository for:
- New releases
- Bug fixes
- Feature additions
- Security updates

---

## Glossary

**ClamAV**: Open-source antivirus engine for detecting malware

**Worker**: Modular script that performs specific tasks on USB drives

**I2C**: Communication protocol used by LCD display

**GPIO**: General Purpose Input/Output pins on Raspberry Pi

**FAT32**: File system format compatible with most devices

**Malware**: Malicious software (viruses, trojans, ransomware, etc.)

**Executable**: File that can run code (potentially dangerous)

**BCM**: Broadcom pin numbering system for Raspberry Pi GPIO

**Pull-up resistor**: Resistor that keeps GPIO pin at HIGH when button not pressed

**Passive buzzer**: Buzzer requiring frequency signal (unlike active buzzer)

---

Still have questions? Check the other documentation:
- [Usage Guide](USAGE.md)
- [Installation Guide](INSTALLATION.md)
- [Hardware Guide](HARDWARE.md)
- [Hardware Wiring](HARDWARE_WIRING.md)
- [Worker Development](WORKER_GUIDE.md)
