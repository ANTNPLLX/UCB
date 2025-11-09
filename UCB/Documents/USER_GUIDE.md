# User Guide

How to use the USB Cleaner Box for scanning and cleaning USB drives.

## Quick Start

1. **Power On** - The device starts automatically
2. **Wait for Ready** - LCD shows "Insert USB / drive..."
3. **Plug USB** - Insert USB drive to scan
4. **Answer Questions** - Use LEFT (NO) and RIGHT (YES) buttons
5. **Review Results** - Check LED colors and LCD messages
6. **Remove USB** - When prompted "Bye bye! / Remove USB"

---

## Startup Sequence

When the device powers on:

1. **LCD Display**
   - Line 1: "USB drive"
   - Line 2: "Cleaner Box"

2. **LED Animation**
   - Snake pattern: Green → Orange → Red → Orange (repeats 2x)

3. **Startup Sound**
   - SNCF jingle plays (4 musical notes)

4. **Ready State**
   - LCD: "Insert USB / drive..."
   - LEDs: All OFF
   - Status: Waiting for USB device

---

## Using the Device

### Step 1: Insert USB Drive

1. Plug USB drive into Raspberry Pi USB port
2. Device detects USB within 1-2 seconds
3. LCD shows: "USB detected / [size]"
4. Warning beeps play (3 short beeps)

### Step 2: Worker Questions

The device will ask about each available worker:

**Example Questions:**
- "Full analysis?" - Run virus/malware scan
- "Executable chk?" - Check for suspicious executables
- "Format USB?" - Erase and format the USB drive

**For each question:**
- LCD Line 1: The question (max 16 characters)
- LCD Line 2: "NO           YES"
- LED: Orange (waiting for input)

**Button Controls:**
- **LEFT button** = NO (skip this worker)
- **RIGHT button** = YES (run this worker)

### Step 3: Worker Execution

When you press YES:

1. **Processing**
   - LCD: "Processing... / Please wait"
   - LED: Orange (working)
   - Worker script runs in background

2. **Duration**
   - Quick checks: 5-30 seconds
   - Full malware scan: 2-10 minutes (depends on USB size)
   - Format: 30-120 seconds

### Step 4: Results Display

After each worker completes:

#### ✅ Success/Clean Result
- **LCD**: "Completed / Success!"
- **LED**: Green blinking (3 seconds)
- **Sound**: Success jingle (ascending notes)

#### ⚠️ Warning Result
- **LCD**: "WARNING / Check results"
- **LED**: Orange blinking (3 seconds)
- **Sound**: Warning beeps

#### ❌ Threat Detected
- **LCD**: "THREAT / DETECTED!"
- **LED**: Red blinking (3 seconds)
- **Sound**: Failure jingle (descending notes)

#### ⛔ Error
- **LCD**: "ERROR / Worker failed"
- **LED**: Red blinking (3 seconds)
- **Sound**: Failure jingle

### Step 5: Run Another Worker?

After all workers complete:

- **LCD**: "Run another? / NO           YES"
- **YES** = Return to worker questions (Step 2)
- **NO** = Proceed to goodbye

### Step 6: Goodbye

- **LCD**: "Bye bye! / Remove USB"
- **LED**: Snake animation (2 seconds)
- **Action**: Remove USB drive
- **Next**: Returns to "Insert USB / drive..." (Step 1)

---

## Button Reference

### LEFT Button (GPIO23)
- **Function**: NO / Cancel / Skip
- **Position**: Usually left side of device
- **Press**: Short press, no need to hold

### RIGHT Button (GPIO24)
- **Function**: YES / Confirm / Proceed
- **Position**: Usually right side of device
- **Press**: Short press, no need to hold

**Tips:**
- Buttons respond immediately
- No need to press multiple times
- Wait for LED color change to confirm press

---

## LED Status Indicators

### LED Colors

| Color | Meaning | When Displayed |
|-------|---------|----------------|
| 🟢 **Green** | Success / Clean / Safe | Successful operations, clean scan |
| 🟠 **Orange** | Processing / Warning / Question | Working, waiting for input, uncertain |
| 🔴 **Red** | Threat / Error / Danger | Malware found, errors, critical issues |

### LED Patterns

| Pattern | Meaning |
|---------|---------|
| **All OFF** | Waiting for USB |
| **Solid Orange** | Waiting for button press |
| **Solid Green** | YES button pressed |
| **Solid Red** | NO button pressed |
| **Blinking Green** | Success/Clean result |
| **Blinking Orange** | Warning/Uncertain |
| **Blinking Red** | Threat/Error detected |
| **Snake Animation** | Startup / Goodbye |

---

## Sound Signals

### Jingles

| Sound | When | Meaning |
|-------|------|---------|
| **SNCF Jingle** | Startup | 4 musical notes, device ready |
| **Success Jingle** | After worker | Ascending notes, operation successful |
| **Failure Jingle** | After worker | Descending notes, threat or error |

### Beeps

| Sound | When | Meaning |
|-------|------|---------|
| **3 Short Beeps** | USB detected | Warning that USB was detected |
| **Warning Beeps** | After worker | Uncertain result, check manually |

---

## Worker Types

### 1. Full Analysis (Malware Scan)

**Question**: "Full analysis?"

**What it does**:
- Scans USB with ClamAV antivirus
- Checks all files for malware signatures
- Detects viruses, trojans, ransomware, etc.

**Duration**: 2-10 minutes (depends on USB size)

**Results**:
- ✅ Clean: No malware found
- ❌ Infected: Malware detected (DO NOT USE USB!)
- ⚠️ Uncertain: Scan incomplete or timeout

**Recommendation**: Run on all unknown USB drives

### 2. Executable Check

**Question**: "Executable chk?"

**What it does**:
- Finds Windows executables (.exe, .dll, .bat, etc.)
- Finds Linux executables (ELF binaries)
- Finds script files (.sh, .ps1, .vbs, etc.)

**Duration**: 30-120 seconds

**Results**:
- ✅ Clean: No executables found
- ⚠️ Suspicious: Executables detected
- ❌ Error: Scan failed

**Recommendation**: Run if USB should only contain data files

### 3. Format USB

**Question**: "Format USB?"

**What it does**:
- **ERASES ALL DATA** on the USB drive
- Creates new FAT32 filesystem
- Makes USB clean and ready to use

**Duration**: 30-120 seconds

**Results**:
- ✅ Success: USB formatted successfully
- ❌ Error: Format failed

**⚠️ WARNING**: This PERMANENTLY DELETES all files!

**Recommendation**: Use only if:
- USB is infected and you want to clean it
- USB has file system errors
- You want to wipe the USB completely

---

## Common Scenarios

### Scenario 1: Scanning a Found USB Drive

1. Insert USB
2. "Full analysis?" → YES
3. Wait for scan (2-10 minutes)
4. Check result:
   - ✅ Green = Safe to use
   - ❌ Red = Infected, do NOT use!
5. "Executable chk?" → YES (optional)
6. "Format USB?" → NO (unless infected)
7. "Run another?" → NO
8. Remove USB

### Scenario 2: Cleaning an Infected USB

1. Insert infected USB
2. "Full analysis?" → YES
3. Result: ❌ Red (malware detected)
4. "Executable chk?" → Skip (NO)
5. "Format USB?" → YES
6. **WARNING DISPLAYED**
7. Confirm: YES
8. Wait for format
9. Result: ✅ Green (USB now clean)
10. Remove USB

### Scenario 3: Quick Executable Check

1. Insert USB
2. "Full analysis?" → NO (skip if trusted source)
3. "Executable chk?" → YES
4. Result:
   - ✅ Green = No executables
   - ⚠️ Orange = Executables found (suspicious)
5. "Format USB?" → NO
6. Remove USB

### Scenario 4: Reformatting a USB

1. Insert USB
2. Skip all scans (NO to all)
3. "Format USB?" → YES
4. LCD: Confirmation warning
5. Confirm with YES
6. Wait for format
7. Result: ✅ Green
8. USB is now blank and ready
9. Remove USB

---

## Safety Guidelines

### ⚠️ DO NOT

- ❌ Unplug USB during scanning or formatting
- ❌ Power off device during operation
- ❌ Use USB with Red LED result (malware detected)
- ❌ Press buttons repeatedly
- ❌ Block ventilation holes
- ❌ Expose device to water or moisture

### ✅ DO

- ✓ Wait for "Bye bye! / Remove USB" before unplugging
- ✓ Keep device on stable surface
- ✓ Check LED color before using USB
- ✓ Run full analysis on unknown USB drives
- ✓ Format infected USB drives before use
- ✓ Keep virus definitions updated

---

## Interpreting Results

### Green LED Results

**Meaning**: Safe, clean, successful

**Actions**:
- USB is safe to use
- Operation completed successfully
- No threats detected

### Orange LED Results

**Meaning**: Warning, uncertain, review needed

**Actions**:
- Check terminal output for details
- Review scan logs: `/var/log/usb_malware_scan.log`
- Use caution when using USB
- Consider running analysis again
- May want to scan on computer

### Red LED Results

**Meaning**: Danger, threat, error

**Actions**:
- **DO NOT USE THIS USB**
- Malware or threats detected
- Format the USB or destroy it
- Do not plug into other computers
- Report findings if necessary

---

## Maintenance

### Daily Use

- No maintenance required
- Device ready to use anytime
- Just plug USB and follow prompts

### Weekly (if used frequently)

- Check virus definition updates
- Review scan logs if needed

### Monthly

- Update virus definitions:
  ```bash
  sudo freshclam
  ```
- Clean device exterior
- Check connections

---

## Tips & Best Practices

### For Best Results

1. **Scan Unknown USB Drives**
   - Always run "Full analysis?" on drives from untrusted sources
   - Better safe than sorry!

2. **Don't Skip Executables Check**
   - If USB should only have documents, run executable check
   - Helps detect hidden malware

3. **Format When Unsure**
   - If red LED shows malware, always format
   - Formatting is the only way to guarantee clean USB

4. **Keep Logs**
   - Scan results are logged to `/var/log/usb_malware_scan.log`
   - Review if you need details

5. **Update Regularly**
   - Keep ClamAV virus definitions current
   - Update system packages monthly

### Avoid These Mistakes

1. **Don't Remove USB Too Early**
   - Wait for "Bye bye!" message
   - Removing during scan can corrupt USB

2. **Don't Ignore Red LEDs**
   - Red = danger, do not use!
   - Format or discard infected USB

3. **Don't Format Without Backup**
   - Format ERASES ALL DATA
   - Backup important files first

---

## Need Help?

- **Installation Issues**: See [Installation Guide](INSTALLATION.md)
- **Hardware Problems**: See [Hardware Guide](HARDWARE.md)
- **Creating Workers**: See [Worker Guide](WORKER_GUIDE.md)
- **Common Issues**: See [FAQ](FAQ.md)

---

## Log Files

Scan results and activities are logged:

**Location**: `/var/log/usb_malware_scan.log`

**View logs**:
```bash
sudo tail -f /var/log/usb_malware_scan.log
```

**Log contents**:
- Scan timestamps
- Devices scanned
- Malware findings
- Worker execution results
- Errors and warnings
