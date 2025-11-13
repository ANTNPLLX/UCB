# Installation Guide

Complete installation instructions for the USB Cleaner Box application.

## Prerequisites

### Hardware Requirements
- Raspberry Pi (Pi 3/4 or Pi Zero 2 W recommended)
- 16x2 I2C LCD display (I2C address: 0x27)
- 3 LEDs (Green, Orange, Red)
- 2 Push buttons
- Passive buzzer
- Power supply (9V battery or USB)

See [Hardware Wiring Guide](HARDWARE_WIRING.md) for complete wiring diagrams.

### System Requirements
- Raspberry Pi OS (Raspbian)
- Python 3.7 or higher
- Internet connection (for initial setup)

---

## Installation Steps

### 1. System Update

```bash
sudo apt-get update
sudo apt-get upgrade -y
```

### 2. Install Python Dependencies

```bash
sudo apt-get install -y python3-rpi.gpio python3-smbus python3-pip
```

### 3. Install ClamAV (Antivirus)

For malware scanning functionality:

```bash
sudo apt-get install -y clamav clamav-daemon
```

Update virus definitions (this may take 10-15 minutes):

```bash
sudo systemctl stop clamav-freshclam
sudo freshclam
sudo systemctl start clamav-freshclam
```

### 4. Install LibreOffice (Optional)

For file vitrification worker (converts Office documents to PDF):

```bash
sudo apt-get install -y libreoffice-writer libreoffice-calc libreoffice-core fonts-liberation fonts-dejavu-core
```

**Note:** The vitrification worker will auto-install LibreOffice and fonts on first run if not present. Manual installation is recommended to avoid delays during USB processing.

### 5. Enable I2C Interface

The LCD uses I2C communication:

```bash
sudo raspi-config
```

Navigate to:
- **Interface Options** → **I2C** → **Enable**

Reboot if prompted:

```bash
sudo reboot
```

### 6. Verify I2C LCD

Check that the LCD is detected:

```bash
sudo i2cdetect -y 1
```

You should see `27` in the output grid (I2C address 0x27).

### 7. Download/Clone the Application

```bash
cd ~
git clone <repository-url> UCB
cd UCB
```

Or if you have the files:

```bash
cd /path/to/UCB
```

### 8. Make Scripts Executable

```bash
chmod +x *.sh
chmod +x *.py
chmod +x workers/*.sh
```

### 9. Test the Application

Run a quick test:

```bash
sudo python3 usb_cleaner_box.py
```

You should see:
- LCD turns on with "USB drive / Cleaner Box"
- LED snake animation
- Startup jingle plays

Press `Ctrl+C` to stop.

---

## Optional: Auto-Start on Boot

### Method 1: Using systemd Service

1. **Edit the service file** to match your installation path:

```bash
nano usb-cleaner-box.service
```

Update these lines:
```
WorkingDirectory=/home/pi/UCB
ExecStart=/usr/bin/python3 /home/pi/UCB/usb_cleaner_box.py
```

2. **Install the service**:

```bash
sudo cp usb-cleaner-box.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable usb-cleaner-box.service
```

3. **Start the service**:

```bash
sudo systemctl start usb-cleaner-box.service
```

4. **Check status**:

```bash
sudo systemctl status usb-cleaner-box.service
```

5. **View logs**:

```bash
sudo journalctl -u usb-cleaner-box.service -f
```

### Method 2: Using rc.local

Add to `/etc/rc.local` before `exit 0`:

```bash
sudo nano /etc/rc.local
```

Add:
```bash
cd /home/pi/UCB && sudo python3 usb_cleaner_box.py &
```

---

## Configuration

### Customizing Workers

Workers are automatically discovered from the `workers/` directory. See [Worker Development Guide](WORKER_GUIDE.md) for creating custom workers.

To enable or disable workers, edit the `WORKER_ENABLED` line in each worker file:

```bash
# Disable a worker
nano workers/format_usb.sh
# Change: WORKER_ENABLED=false

# Restart service
sudo systemctl restart usb-cleaner-box.service
```

### LCD I2C Address

If your LCD uses a different I2C address, edit `lcd_helper.py`:

```python
I2C_ADDR = 0x27  # Change to your LCD address
```

### GPIO Pin Configuration

Default GPIO pin assignments in the code:

| Component | GPIO Pin |
|-----------|----------|
| Green LED | GPIO16 |
| Orange LED | GPIO20 |
| Red LED | GPIO21 |
| Left Button | GPIO23 |
| Right Button | GPIO24 |
| Buzzer | GPIO26 |
| LCD Power | GPIO4 |

To change pins, edit the respective Python modules.

---

## Troubleshooting

### LCD Not Displaying

**Problem**: LCD is blank or shows random characters

**Solutions**:
1. Check I2C connection:
   ```bash
   sudo i2cdetect -y 1
   ```
2. Verify GPIO4 is powering the LCD
3. Check LCD I2C address in code
4. Verify I2C is enabled in `raspi-config`

### LEDs Not Working

**Problem**: LEDs don't light up

**Solutions**:
1. Check LED polarity (long leg = positive)
2. Verify resistor values (220Ω recommended)
3. Test LEDs separately with simple script
4. Check GPIO pin connections

### Buttons Not Responding

**Problem**: Buttons don't trigger actions

**Solutions**:
1. Verify button connections (one side to GPIO, other to GND)
2. Check pull-up resistors are configured (internal or external)
3. Test buttons with simple script
4. Ensure buttons are momentary, not latching

### No Sound from Buzzer

**Problem**: Buzzer is silent

**Solutions**:
1. Verify buzzer is passive (not active)
2. Check transistor driver circuit
3. Test buzzer separately at 5V
4. Verify GPIO26 connection

### USB Not Detected

**Problem**: Application doesn't detect plugged USB

**Solutions**:
1. Check USB device appears in `lsblk`
2. Run with sudo (required for device access)
3. Check debug output in terminal
4. Verify USB is not auto-mounting elsewhere

### ClamAV Errors

**Problem**: Malware scanning fails

**Solutions**:
1. Update virus definitions:
   ```bash
   sudo freshclam
   ```
2. Check ClamAV is installed:
   ```bash
   clamscan --version
   ```
3. Verify worker script permissions
4. Check system has enough RAM (1GB+ recommended)

### Permission Errors

**Problem**: "Permission denied" errors

**Solutions**:
1. Run with sudo:
   ```bash
   sudo python3 usb_cleaner_box.py
   ```
2. Check script permissions:
   ```bash
   ls -l workers/
   ```
3. Make scripts executable:
   ```bash
   chmod +x workers/*.sh
   ```

---

## Updating

### Update Application Code

```bash
cd ~/UCB
git pull
chmod +x *.sh workers/*.sh
```

### Update ClamAV Definitions

```bash
sudo freshclam
```

### Update System

```bash
sudo apt-get update
sudo apt-get upgrade
```

---

## Uninstallation

### Stop and Disable Service

```bash
sudo systemctl stop usb-cleaner-box.service
sudo systemctl disable usb-cleaner-box.service
sudo rm /etc/systemd/system/usb-cleaner-box.service
sudo systemctl daemon-reload
```

### Remove Application

```bash
rm -rf ~/UCB
```

### Remove Dependencies (Optional)

```bash
sudo apt-get remove clamav clamav-daemon
sudo apt-get autoremove
```

---

## Next Steps

- **Usage**: See [Usage Guide](USAGE.md)
- **Worker Development**: See [Worker Guide](WORKER_GUIDE.md)
- **Hardware**: See [Hardware Guide](HARDWARE.md)
- **Hardware Wiring**: See [Hardware Wiring](HARDWARE_WIRING.md)
- **Troubleshooting**: See [FAQ](FAQ.md)
