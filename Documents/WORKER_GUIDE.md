# Worker Development Guide

Complete guide for creating custom workers for the USB Cleaner Box.

## Quick Start

1. Copy the template: `cp workers/TEMPLATE_worker.sh workers/my_worker.sh`
2. Edit metadata (must be max 16 chars for question!)
3. Implement your logic
4. Make executable: `chmod +x workers/my_worker.sh`
5. Done! It will auto-appear on next run

See [WORKER_TEMPLATE.sh](WORKER_TEMPLATE.sh) for the complete template with detailed comments.

---

## Worker Metadata

Each worker must include metadata in header comments:

```bash
# WORKER_QUESTION=Your question?
# WORKER_ORDER=100
# WORKER_DESCRIPTION=Description of what this worker does
# WORKER_ENABLED=true
```

### Fields

| Field | Required | Description | Example |
|-------|----------|-------------|---------|
| `WORKER_QUESTION` | **YES** | Question on LCD (max 16 chars) | `Backup files?` |
| `WORKER_ORDER` | No | Execution order (default: 999) | `25` |
| `WORKER_DESCRIPTION` | No | Brief description | `Backup important files` |
| `WORKER_ENABLED` | No | Enable/disable worker (default: true) | `true` or `false` |

**Important**: Workers without `WORKER_QUESTION` are ignored!

---

## Worker Order

Built-in workers:
- **10** - analyze_malware.sh
- **20** - analyze_executables.sh  
- **30** - format_usb.sh

Use numbers in between or higher for your custom workers.

---

## Worker Interface

### Input

Workers receive the USB device name as first parameter:

```bash
DEVICE=$1          # e.g., "sdb"
DEVICE_PATH="/dev/$DEVICE"  # e.g., "/dev/sdb"
```

### Output

Print status messages to stdout:

```bash
echo "Scanning files..."
echo "CLEAN: No threats found"
echo "WARNING: Suspicious files detected"
echo "INFECTED: Malware found!"
```

### Exit Codes

Return appropriate codes:

```bash
exit 0   # Success
exit 1   # Error/Failure
```

---

## Result Analysis

Main application analyzes output for keywords:

| Output Contains | Status | LED | Sound |
|----------------|--------|-----|-------|
| "infected", "malware", "threat" | THREAT | Red | Failed |
| "suspicious", "warning" | WARNING | Orange | Warning |
| "clean", "safe", "no" | CLEAN | Green | Success |
| (non-zero exit) | ERROR | Red | Failed |

---

## Enabling/Disabling Workers

Workers can be enabled or disabled without deleting them.

### How It Works

- **Enabled workers** (`WORKER_ENABLED=true`): Questions appear on LCD
- **Disabled workers** (`WORKER_ENABLED=false`): Skipped entirely, no LCD prompt

### Use Cases

- **Testing**: Disable workers while developing new ones
- **Maintenance**: Temporarily disable problematic workers
- **Customization**: Only run the workers you need

### How to Disable a Worker

1. **Edit the worker file:**
   ```bash
   nano workers/format_usb.sh
   ```

2. **Change the WORKER_ENABLED line:**
   ```bash
   # From:
   # WORKER_ENABLED=true

   # To:
   # WORKER_ENABLED=false
   ```

3. **Restart the application:**
   ```bash
   sudo systemctl restart usb-cleaner-box.service
   ```

### How to Re-Enable a Worker

1. Change `WORKER_ENABLED=false` back to `WORKER_ENABLED=true`
2. Restart the service

### Example: Disable Format Worker

```bash
# Edit the format worker
sudo nano /home/pi/UCB/workers/format_usb.sh

# Change line 8 to:
# WORKER_ENABLED=false

# Save and restart
sudo systemctl restart usb-cleaner-box.service
```

Now the "Format USB?" question will not appear on the LCD.

### Accepted Values

The following values are recognized (case-insensitive):

| Value | Result |
|-------|--------|
| `true`, `yes`, `1` | Worker enabled |
| `false`, `no`, `0` | Worker disabled |
| (omitted) | Defaults to `true` (enabled) |

---

## Example Workers

### 1. Count Files

```bash
#!/bin/bash
# WORKER_QUESTION=Count files?
# WORKER_ORDER=15
# WORKER_DESCRIPTION=Count total files on USB
# WORKER_ENABLED=true

DEVICE=$1
MOUNT_POINT="/media/count_$DEVICE"

sudo mkdir -p "$MOUNT_POINT"
sudo mount "/dev/${DEVICE}1" "$MOUNT_POINT"

COUNT=$(find "$MOUNT_POINT" -type f | wc -l)
echo "CLEAN: Found $COUNT files"

sudo umount "$MOUNT_POINT"
sudo rmdir "$MOUNT_POINT"
exit 0
```

### 2. Find Large Files

```bash
#!/bin/bash
# WORKER_QUESTION=Find big files?
# WORKER_ORDER=40
# WORKER_DESCRIPTION=Find files > 100MB
# WORKER_ENABLED=true

DEVICE=$1
MOUNT_POINT="/media/large_$DEVICE"

sudo mkdir -p "$MOUNT_POINT"
sudo mount "/dev/${DEVICE}1" "$MOUNT_POINT"

echo "Searching for files > 100MB..."
LARGE=$(find "$MOUNT_POINT" -type f -size +100M)

if [ -z "$LARGE" ]; then
    echo "CLEAN: No large files found"
else
    echo "WARNING: Large files detected"
    echo "$LARGE"
fi

sudo umount "$MOUNT_POINT"
sudo rmdir "$MOUNT_POINT"
exit 0
```

### 3. File Vitrification (Office to PDF)

```bash
#!/bin/bash
# WORKER_QUESTION=Vitrification?
# WORKER_ORDER=25
# WORKER_DESCRIPTION=Convert Office docs to PDF, neutralize other files
# WORKER_ENABLED=true

DEVICE=$1
MOUNT_POINT="/media/vitrify_$DEVICE"

# Check if LibreOffice is installed
if ! command -v libreoffice &> /dev/null; then
    echo "Installing LibreOffice..."
    sudo apt-get update -qq
    sudo apt-get install -y libreoffice --no-install-recommends
fi

sudo mkdir -p "$MOUNT_POINT"
sudo mount "/dev/${DEVICE}1" "$MOUNT_POINT"

# Convert Office documents to PDF
CONVERTED=0
for file in $(sudo find "$MOUNT_POINT" -type f -iname "*.doc*" -o -iname "*.xls*" -o -iname "*.ppt*"); do
    dirname=$(dirname "$file")
    if sudo -u pi libreoffice --headless --convert-to pdf --outdir "$dirname" "$file" 2>&1; then
        sudo rm "$file"
        CONVERTED=$((CONVERTED + 1))
    fi
done

# Neutralize other files with .hold extension
NEUTRALIZED=0
for file in $(sudo find "$MOUNT_POINT" -type f ! -iname "*.pdf" ! -iname "*.txt" ! -iname "*.jpg"); do
    sudo mv "$file" "${file}.hold"
    NEUTRALIZED=$((NEUTRALIZED + 1))
done

echo "CLEAN: Converted $CONVERTED docs, neutralized $NEUTRALIZED files"

sudo umount "$MOUNT_POINT"
sudo rmdir "$MOUNT_POINT"
exit 0
```

**Note:** Requires LibreOffice. Auto-installs on first run if not present.

---

## Best Practices

### Questions
- Keep under 16 characters
- Be clear and concise
- Use "?" at the end
- Use abbreviations: "Executable chk?" not "Check Executables?"

### Output
- Print progress for long operations
- Use keywords: CLEAN, WARNING, INFECTED
- Be informative in messages
- Log to `/var/log/usb_malware_scan.log`

### Error Handling
- Check if device exists
- Verify mount successful
- Handle timeouts gracefully
- Clean up on errors

### Cleanup
- Always unmount devices
- Remove temporary files
- Free resources

---

## Restrictions

### Don't Do This
- ❌ Access GPIO pins (conflicts with main app)
- ❌ Write to I2C bus (used by LCD)
- ❌ Use `display_on_lcd()` function (disabled)
- ❌ Modify system audio settings
- ❌ Run indefinitely (10-minute timeout)

### Do This
- ✅ Use provided logging functions
- ✅ Mount and unmount properly
- ✅ Check device exists first
- ✅ Print clear status messages
- ✅ Handle errors gracefully

---

## Testing

### Test Manually

```bash
sudo ./workers/my_worker.sh sdb
```

### Check Discovery

```bash
sudo python3 usb_cleaner_box.py
# Look for "Discovered worker" messages
```

### Debug Output

Workers can print debug info:

```bash
echo "[DEBUG] Mounting device..."
echo "[DEBUG] Files found: $COUNT"
```

---

## Advanced Topics

### Mounting

```bash
# Create mount point
MOUNT_POINT="/media/worker_$DEVICE"
sudo mkdir -p "$MOUNT_POINT"

# Mount first partition
sudo mount "/dev/${DEVICE}1" "$MOUNT_POINT"

# Do work...

# Always unmount
sudo umount "$MOUNT_POINT"
sudo rmdir "$MOUNT_POINT"
```

### Logging

```bash
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a /var/log/usb_malware_scan.log
}

log_message "Worker started for $DEVICE"
```

### Progress Reporting

```bash
TOTAL=100
for i in $(seq 1 $TOTAL); do
    echo "Progress: $i/$TOTAL"
    # Do work
done
```

### Dependencies

Check if tools are installed:

```bash
if ! command -v some_tool &> /dev/null; then
    echo "ERROR: some_tool not installed"
    exit 1
fi
```

**Example - Auto-install LibreOffice:**

```bash
if ! command -v libreoffice &> /dev/null; then
    echo "Installing LibreOffice..."
    sudo apt-get update -qq
    sudo apt-get install -y libreoffice --no-install-recommends
fi
```

---

## Worker Ideas

- **File vitrification** - Convert docs to PDF, neutralize executables (built-in)
- File backup to network/cloud
- Duplicate file finder
- Photo organizer
- Document converter
- Encryption/decryption
- Hash verification
- File recovery
- Disk health check
- Permission fixer
- Metadata cleaner

---

For the complete template with all comments and examples, see [WORKER_TEMPLATE.sh](WORKER_TEMPLATE.sh).
