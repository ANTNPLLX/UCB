# USB Cleaner Box - Usage Guide

## Quick Start

```bash
cd <path_to_downloaded_files>/UCB
sudo ./start.sh
```

## Application Flow

```
┌─────────────────────────────────────────────────────────┐
│                    STARTUP SEQUENCE                     │
├─────────────────────────────────────────────────────────┤
│ LCD:  "USB drive"      / "Cleaner Box"                  │
│ LEDs: Snake animation (Green→Orange→Red→Orange) x2      │
│ Sound: startup jingle                                   │
└─────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────┐
│                  WAITING FOR USB                        │
├─────────────────────────────────────────────────────────┤
│ LCD:  "Insert USB"     / "drive..."                     │
│ LEDs: All OFF                                           │
└─────────────────────────────────────────────────────────┘
                          ↓
                  [USB PLUGGED IN]
                          ↓
┌─────────────────────────────────────────────────────────┐
│                   USB DETECTED                          │
├─────────────────────────────────────────────────────────┤
│ LCD:  "USB detected"   / "[size]"                       │
│ Sound: Warning beeps (3x)                               │
└─────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────┐
│              QUESTION 1: Full Analysis                  │
├─────────────────────────────────────────────────────────┤
│ LCD:  "Full analysis?" / "NO           YES"             │
│                                                         │
│ [LEFT button = NO] ────────┐  [RIGHT button = YES]      │
│         Skip               │         ↓                  │
└────────────────────────────┼─────────────────────────────┘
                             │         ↓
                             │  ┌──────────────────────┐
                             │  │  RUN MALWARE SCAN    │
                             │  │  (ClamAV analysis)   │
                             │  │  LCD: "Analyzing"    │
                             │  │       "malware..."   │
                             │  └──────────────────────┘
                             │         ↓
                             └─────────┴─────────────────────┐
                                                             ↓
┌─────────────────────────────────────────────────────────┐
│           QUESTION 2: Executable Check                  │
├─────────────────────────────────────────────────────────┤
│ LCD:  "Executable chk?" / "NO           YES"            │
│                                                         │
│ [LEFT button = NO] ────────┐  [RIGHT button = YES]     │
│         Skip               │         ↓                  │
└────────────────────────────┼─────────────────────────────┘
                             │         ↓
                             │  ┌──────────────────────┐
                             │  │ CHECK EXECUTABLES    │
                             │  │ (PE/ELF/Scripts)     │
                             │  │ LCD: "Checking"      │
                             │  │      "executables"   │
                             │  └──────────────────────┘
                             │         ↓
                             └─────────┴─────────────────────┐
                                                             ↓
┌─────────────────────────────────────────────────────────┐
│              QUESTION 3: Format USB                     │
├─────────────────────────────────────────────────────────┤
│ LCD:  "Format USB?"    / "NO           YES"             │
│                                                         │
│ [LEFT button = NO] ────────┐  [RIGHT button = YES]      │
│         Skip               │         ↓                  │
└────────────────────────────┼────────────────────────────┘
                             │         ↓
                             │  ┌──────────────────────┐
                             │  │ CONFIRM FORMAT       │
                             │  │ LCD: "Confirm fmt?"  │
                             │  │      "NO        YES" │
                             │  └──────────────────────┘
                             │         ↓
                             │    [YES pressed]
                             │         ↓
                             │  ┌──────────────────────┐
                             │  │   FORMAT USB         │
                             │  │   (FAT32, secure)    │
                             │  │   LCD: "Formatting"  │
                             │  │        "USB drive"   │
                             │  └──────────────────────┘
                             │         ↓
                             └─────────┴─────────────────────┐
                                                             ↓

         ┌──────────────────────────────────────────────────┐
         │               RESULTS DISPLAY                    │
         └──────────────────────────────────────────────────┘
                          ↓
    ┌────────────────────┼────────────────────┐
    ↓                    ↓                    ↓
┌─────────┐      ┌──────────────┐     ┌─────────────┐
│ THREAT  │      │  UNCERTAIN   │     │   CLEAN     │
│ FOUND   │      │              │     │             │
├─────────┤      ├──────────────┤     ├─────────────┤
│ Malware │      │ Scan error / │     │ No threats  │
│   OR    │      │ Timeout /    │     │ No malware  │
│ Executables    │ Incomplete   │     │ No execs    │
├─────────┤      ├──────────────┤     ├─────────────┤
│ LCD:    │      │ LCD:         │     │ LCD:        │
│ "THREAT"│      │ "UNCERTAIN"  │     │ "USB is"    │
│ "DETECTED"     │ "result"     │     │ "CLEAN!"    │
├─────────┤      ├──────────────┤     ├─────────────┤
│ LED:    │      │ LED:         │     │ LED:        │
│ RED     │      │ ORANGE       │     │ GREEN       │
│ blinking│      │ blinking     │     │ blinking    │
│ 5 sec   │      │ 5 sec        │     │ 5 sec       │
├─────────┤      ├──────────────┤     ├─────────────┤
│ Sound:  │      │ Sound:       │     │ Sound:      │
│ Failed  │      │ Warning      │     │ Success     │
│ jingle  │      │ beeps        │     │ jingle      │
├─────────┤      ├──────────────┤     ├─────────────┤
│ Final:  │      │ Final:       │     │ Final:      │
│"DO NOT" │      │ "Use with"   │     │"Safe to use"│
│"USE!"   │      │ "caution"    │     │             │
└─────────┘      └──────────────┘     └─────────────┘
    │                    │                    │
    └────────────────────┴────────────────────┘
                          ↓
              ┌──────────────────────┐
              │  READY FOR NEXT USB  │
              │  (Loop back to wait) │
              └──────────────────────┘
```

## Button Reference

```
┌─────────────────────────────────────────┐
│  LEFT Button (GPIO23)  │ RIGHT Button  │
│                        │   (GPIO24)    │
├────────────────────────┼───────────────┤
│        NO              │      YES      │
│      Cancel            │    Confirm    │
│       Skip             │    Proceed    │
└────────────────────────┴───────────────┘
```

## LED Status Meanings

```
┌──────────┬─────────────────────────────────┐
│   LED    │          Meaning                │
├──────────┼─────────────────────────────────┤
│  GREEN   │ Safe / Clean / Success          │
│  ORANGE  │ Processing / Warning / Uncertain│
│  RED     │ Threat / Danger / Error         │
│  Snake   │ Startup animation               │
└──────────┴─────────────────────────────────┘
```

## Sound Signals

```
┌────────────────┬──────────────────────────┐
│     Sound      │         When             │
├────────────────┼──────────────────────────┤
│ SNCF Jingle    │ Application startup      │
│ Warning Beeps  │ USB detected / Uncertain │
│ Success Jingle │ Clean scan result        │
│ Failed Jingle  │ Threat detected          │
└────────────────┴──────────────────────────┘
```

## Example Session

**User plugs in USB drive:**

1. LCD shows: "USB detected" / "8.0G"
2. Beep beep beep (warning sound)
3. LCD shows: "Full analysis?" / "NO           YES"
4. User presses RIGHT button (YES)
5. LCD shows: "Analyzing" / "malware..."
   - Progress updates during scan
6. LCD shows: "Executable chk?" / "NO           YES"
7. User presses RIGHT button (YES)
8. LCD shows: "Checking" / "executables..."
9. LCD shows: "Format USB?" / "NO           YES"
10. User presses LEFT button (NO)
11. LCD shows: "USB is" / "CLEAN!"
12. GREEN LED blinks for 5 seconds
13. Success jingle plays
14. LCD shows: "Safe to use!" / ""
15. Back to: "Insert USB" / "drive..."

## Installation as Service

To run USB Cleaner Box automatically at boot:

```bash
# Copy service file
sudo cp /home/antoine/raspberry/BNU/UCB/usb-cleaner-box.service /etc/systemd/system/

# Reload systemd
sudo systemctl daemon-reload

# Enable service
sudo systemctl enable usb-cleaner-box.service

# Start service
sudo systemctl start usb-cleaner-box.service

# Check status
sudo systemctl status usb-cleaner-box.service

# View logs
sudo journalctl -u usb-cleaner-box.service -f
```

## Manual Run (for testing)

```bash
cd /home/antoine/raspberry/BNU/UCB
sudo python3 usb_cleaner_box.py
```

## Stopping the Application

- Press `Ctrl+C` in the terminal
- Or if running as service: `sudo systemctl stop usb-cleaner-box.service`

## Tips

1. **First time setup**: Test each component separately
   - LCD: `python3 lcd_helper.py`
   - LEDs: Check with existing LED test scripts
   - Buttons: Use the button test script
   - Sound: Test with play_sncf_jingle.py

2. **Always run with sudo**: GPIO access requires root privileges

3. **Update virus definitions regularly**:
   ```bash
   sudo systemctl stop clamav-freshclam
   sudo freshclam
   sudo systemctl start clamav-freshclam
   ```

4. **Monitor logs**: Keep an eye on `/var/log/usb_malware_scan.log`

5. **Testing without USB**: You can modify the code to simulate USB insertion for testing

## Troubleshooting Quick Reference

| Issue | Solution |
|-------|----------|
| LCD blank | Check I2C: `sudo i2cdetect -y 1` |
| No USB detection | Run with sudo, check `lsblk` |
| LEDs not working | Verify GPIO pin numbers |
| No sound | Check buzzer on GPIO26 |
| Buttons unresponsive | Check GPIO23/24 connections |
| Scan fails | Ensure ClamAV installed: `clamscan --version` |
| Format fails | Check USB not mounted elsewhere |
