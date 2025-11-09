# Worker System Guide

The USB Cleaner Box uses a dynamic worker system that allows you to easily add custom functionality without modifying the main application code.

## What is a Worker?

A **worker** is a shell script that performs a specific task on a USB device. Workers are automatically discovered and presented to the user as questions on the LCD display.

## How Workers Work

1. **Discovery**: On startup, the main application scans the `workers/` directory
2. **Parsing**: Worker metadata is read from script headers
3. **Ordering**: Workers are sorted by their `WORKER_ORDER` value
4. **Execution**: For each worker, the user is asked if they want to run it
5. **Results**: Worker output is analyzed and feedback is provided via LCD, LEDs, and sound

## Worker Metadata

Each worker must include metadata in its header comments:

```bash
#!/bin/bash
#
# my_worker.sh - Description
#
# WORKER_QUESTION=Your question?
# WORKER_ORDER=50
# WORKER_DESCRIPTION=What this worker does
#
```

### Metadata Fields

| Field | Required | Max Length | Description |
|-------|----------|------------|-------------|
| `WORKER_QUESTION` | **Yes** | 16 chars | Question displayed on LCD |
| `WORKER_ORDER` | No | N/A | Execution order (default: 999) |
| `WORKER_DESCRIPTION` | No | N/A | Brief description |

**Important**: Workers without `WORKER_QUESTION` are ignored!

## Worker Order

Workers are executed in ascending order based on `WORKER_ORDER`:

- **10** - analyze_malware.sh (malware scanning)
- **20** - analyze_executables.sh (executable detection)
- **30** - format_usb.sh (USB formatting)
- **100+** - Custom workers

Use lower numbers to run workers earlier in the sequence.

## Creating a New Worker

### Step 1: Copy the Template

```bash
cd UCB/workers
cp TEMPLATE_worker.sh my_custom_worker.sh
```

### Step 2: Edit Metadata

```bash
# WORKER_QUESTION=Backup files?
# WORKER_ORDER=25
# WORKER_DESCRIPTION=Backup important files from USB
```

**Question Tips:**
- Keep it short (max 16 characters)
- Use abbreviations if needed: "Executable chk?"
- End with "?" to indicate it's a question
- Be clear about what the worker does

### Step 3: Implement Your Logic

The worker receives the USB device name as the first parameter:

```bash
DEVICE=$1          # e.g., "sdb"
DEVICE_PATH="/dev/$DEVICE"  # e.g., "/dev/sdb"
```

Example implementation:

```bash
# Mount the device
MOUNT_POINT="/media/usb_$DEVICE"
sudo mkdir -p "$MOUNT_POINT"
sudo mount "${DEVICE_PATH}1" "$MOUNT_POINT"

# Do your work
find "$MOUNT_POINT" -name "*.doc" -exec cp {} /backup/ \;

# Unmount
sudo umount "$MOUNT_POINT"
sudo rmdir "$MOUNT_POINT"
```

### Step 4: Set Exit Code

Return appropriate exit codes:

```bash
exit 0   # Success
exit 1   # Error/Failure
```

### Step 5: Make Executable

```bash
chmod +x my_custom_worker.sh
```

### Step 6: Test

```bash
sudo python3 usb_cleaner_box.py
```

Your worker will be automatically discovered!

## Worker Examples

### Example 1: File Counter

```bash
#!/bin/bash
#
# count_files.sh - Count files on USB
#
# WORKER_QUESTION=Count files?
# WORKER_ORDER=15
# WORKER_DESCRIPTION=Count total files on USB device
#

DEVICE=$1
MOUNT_POINT="/media/usb_count_$DEVICE"

sudo mkdir -p "$MOUNT_POINT"
sudo mount "/dev/${DEVICE}1" "$MOUNT_POINT"

FILE_COUNT=$(find "$MOUNT_POINT" -type f | wc -l)
echo "Total files found: $FILE_COUNT"

sudo umount "$MOUNT_POINT"
sudo rmdir "$MOUNT_POINT"

exit 0
```

### Example 2: Find Large Files

```bash
#!/bin/bash
#
# find_large_files.sh - Find files over 100MB
#
# WORKER_QUESTION=Find big files?
# WORKER_ORDER=40
# WORKER_DESCRIPTION=Find files larger than 100MB
#

DEVICE=$1
MOUNT_POINT="/media/usb_large_$DEVICE"

sudo mkdir -p "$MOUNT_POINT"
sudo mount "/dev/${DEVICE}1" "$MOUNT_POINT"

echo "Searching for files > 100MB..."
find "$MOUNT_POINT" -type f -size +100M -exec ls -lh {} \;

sudo umount "$MOUNT_POINT"
sudo rmdir "$MOUNT_POINT"

exit 0
```

## Result Analysis

The main application analyzes worker output to determine status:

### Keywords Detected

| Output Contains | Status | LED | Sound |
|----------------|--------|-----|-------|
| "infected", "malware", "threat" | **THREAT** | Red blink | Failed |
| "suspicious", "warning" | **WARNING** | Orange blink | Warning |
| "clean", "safe", "no" | **CLEAN** | Green blink | Success |
| (error/non-zero exit) | **ERROR** | Red blink | Failed |
| (other) | **UNCERTAIN** | Green blink | Success |

### Output Best Practices

Include clear status messages in your worker output:

```bash
# Good examples:
echo "CLEAN: No threats found"
echo "WARNING: 3 suspicious files detected"
echo "INFECTED: Malware found!"

# Avoid ambiguous messages:
echo "Done"  # Unclear status
```

## Worker Capabilities

Workers can perform any operation, such as:

### Security Operations
- Virus/malware scanning
- Rootkit detection
- Suspicious file analysis
- Permission auditing

### Data Operations
- File backup
- Data recovery
- Duplicate detection
- File organization

### Maintenance Operations
- Disk repair
- Bad sector checking
- Filesystem verification
- Quota checking

### Custom Operations
- File encryption
- Compression
- Format conversion
- Metadata extraction

## Logging

Use the provided logging function:

```bash
log_message "Worker started for device $DEVICE"
log_message "Found 10 suspicious files"
```

Logs are written to: `/var/log/usb_malware_scan.log`

## LCD Display

**Do NOT** try to update the LCD from workers. The function `display_on_lcd()` is disabled:

```bash
# This won't work in workers:
display_on_lcd "My message" "Line 2"
```

The main application handles all LCD updates based on:
- Worker questions (from metadata)
- Worker status ("Processing...", "Completed", etc.)
- Worker results (analyzed from output)

## Debugging Workers

### Test a Worker Manually

```bash
# Run worker directly with device name
sudo ./workers/my_worker.sh sdb
```

### Check Worker Discovery

The main application prints discovered workers:

```
Discovered worker: Worker(analyze_malware.sh, order=10, question='Full analysis?')
Discovered worker: Worker(my_worker.sh, order=50, question='My question?')
Total workers discovered: 2
```

### Common Issues

| Problem | Solution |
|---------|----------|
| Worker not discovered | Check `WORKER_QUESTION` is uncommented |
| Wrong order | Adjust `WORKER_ORDER` value |
| Question too long | Limit to 16 characters |
| Script won't run | Make it executable: `chmod +x` |
| LCD not updating | Don't use `display_on_lcd()` in workers |

## Worker Restrictions

### Security
- Workers run with sudo privileges
- Be careful with destructive operations
- Always validate input
- Don't execute untrusted code

### System Resources
- Workers have 10-minute timeout
- Avoid infinite loops
- Clean up temporary files
- Unmount devices when done

### Hardware
- Don't access GPIO pins (conflicts with main app)
- Don't write to I2C bus (used by LCD)
- Don't modify system audio (buzzer in use)

## Advanced Tips

### Conditional Execution

Make workers skip if conditions aren't met:

```bash
# Only run on large USBs
SIZE=$(lsblk -no SIZE -b "/dev/$DEVICE" | head -1)
if [ "$SIZE" -lt 1000000000 ]; then
    echo "SKIPPED: USB too small for this operation"
    exit 0
fi
```

### Worker Dependencies

Check if required tools are installed:

```bash
if ! command -v someapp &> /dev/null; then
    echo "ERROR: someapp not installed"
    exit 1
fi
```

### Progress Reporting

Print progress to help user understand long operations:

```bash
for i in {1..100}; do
    echo "Progress: $i%"
    # Do work
    sleep 0.1
done
```

## FAQ

**Q: Can workers ask additional questions?**
A: No, workers only get one YES/NO question from their metadata.

**Q: Can workers access the internet?**
A: Yes, but ensure the Raspberry Pi has network access.

**Q: Can I write workers in Python?**
A: Yes! Make the script executable with `#!/usr/bin/env python3` shebang.

**Q: How do I disable a worker?**
A: Remove execute permission: `chmod -x workers/worker.sh` or delete it.

**Q: Can workers modify the USB content?**
A: Yes, if run with appropriate permissions.

**Q: What if a worker crashes?**
A: The main app will catch the error and continue with other workers.

## Examples Repository

Check the `workers/` directory for working examples:
- `analyze_malware.sh` - ClamAV scanning
- `analyze_executables.sh` - Executable detection
- `format_usb.sh` - Secure formatting
- `TEMPLATE_worker.sh` - Template for new workers

## Support

For issues or questions about the worker system:
1. Check worker output: `sudo ./workers/my_worker.sh sdb`
2. Review logs: `tail -f /var/log/usb_malware_scan.log`
3. Check main app output for discovery messages
