# LCD IPC System - Worker to Main App Communication

## Overview

The USB Cleaner Box uses an Inter-Process Communication (IPC) mechanism to allow worker bash scripts to update the LCD display. This is necessary because workers run as separate processes and cannot directly call Python methods.

## Architecture

```
┌─────────────────┐
│ Worker Script   │
│ (bash)          │
└────────┬────────┘
         │
         │ display_on_lcd "Line 1" "Line 2"
         │
         ▼
┌─────────────────┐
│ lcd_helper.sh   │  (sources into worker)
└────────┬────────┘
         │
         │ Calls python3 lcd_ipc.py
         │
         ▼
┌─────────────────┐
│ lcd_ipc.py      │  (writes to /tmp/ucb_lcd_command)
└────────┬────────┘
         │
         │ JSON: {"line1": "...", "line2": "..."}
         │
         ▼
┌─────────────────┐
│ /tmp/           │
│ ucb_lcd_command │  (temp file)
└────────┬────────┘
         │
         │ Monitor thread checks every 100ms
         │
         ▼
┌─────────────────┐
│ LCDIPCMonitor   │  (background thread in main app)
│ (Python)        │
└────────┬────────┘
         │
         │ Reads file, parses JSON
         │
         ▼
┌─────────────────┐
│ LCD.display()   │  (actual hardware update)
│ (Python)        │
└─────────────────┘
```

## Components

### 1. `lcd_ipc.py`
Python module providing:
- **`LCDIPCMonitor`**: Background thread that monitors `/tmp/ucb_lcd_command`
- **`send_lcd_command()`**: Helper function to send LCD commands

### 2. `workers/lcd_helper.sh`
Bash helper script that workers source. Provides:
- **`display_on_lcd(line1, line2)`**: Function callable from bash

### 3. `/tmp/ucb_lcd_command`
Temporary file used for IPC:
- Written by workers via `lcd_ipc.py`
- Read by `LCDIPCMonitor` thread
- JSON format: `{"line1": "text", "line2": "text"}`

## Usage in Workers

All worker scripts automatically have access to `display_on_lcd()`:

```bash
#!/bin/bash

# Configuration
SCAN_LOG="/var/log/usb_malware_scan.log"

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source LCD helper for display_on_lcd function
source "${SCRIPT_DIR}/lcd_helper.sh"

# Now you can use display_on_lcd anywhere in the script
display_on_lcd "Scanning..." "Please wait"

# Do some work...

display_on_lcd "Scan complete" "Found: 0 files"
```

## Timing and Synchronization

- **Write latency**: ~10ms (file write + flush)
- **Monitor polling**: 100ms interval
- **Update latency**: Typically 10-200ms
- **Non-blocking**: Workers don't wait for LCD update

This means LCD updates appear nearly instantly but don't slow down worker execution.

## Error Handling

All IPC operations are designed to fail silently:
- If LCD monitor is not running, commands are ignored
- If file write fails, worker continues normally
- No error messages are shown to avoid disrupting operation

## Testing

### Test from Python:
```python
from lcd_ipc import send_lcd_command
send_lcd_command("Python Test", "Line 2")
```

### Test from Bash:
```bash
source /home/antoine/raspberry/UCB/workers/lcd_helper.sh
display_on_lcd "Bash Test" "Line 2"
```

### Verify command file:
```bash
cat /tmp/ucb_lcd_command
# Should show: {"line1": "...", "line2": "..."}
```

## Lifecycle

1. **Startup**: Main app starts `LCDIPCMonitor` thread
2. **Worker execution**: Workers call `display_on_lcd()`
3. **Update**: Monitor detects file change and updates LCD
4. **Cleanup**: Monitor thread stops on app shutdown

## Performance

- **Memory**: Minimal (~1KB for JSON command)
- **CPU**: Negligible (100ms polling interval)
- **Disk I/O**: Minimal (small file writes to /tmp - RAM-based)

## Alternatives Considered

1. **Named pipes (FIFO)**: More complex, blocking behavior
2. **Unix sockets**: Requires connection management
3. **Shared memory**: Platform-specific, complex
4. **File-based IPC**: ✅ Simple, reliable, portable

## Troubleshooting

### LCD not updating from workers:

1. Check monitor is running:
   ```bash
   ps aux | grep lcd_ipc
   ```

2. Check command file exists after worker call:
   ```bash
   ls -l /tmp/ucb_lcd_command
   cat /tmp/ucb_lcd_command
   ```

3. Test manually:
   ```bash
   python3 /home/antoine/raspberry/UCB/lcd_ipc.py "Test 1" "Test 2"
   ```

4. Check main app logs for errors

### Stale LCD display:

- Monitor only updates on file modification
- Touch the file to force update:
  ```bash
  touch /tmp/ucb_lcd_command
  ```

## Future Enhancements

Possible improvements:
- Add command queue for multiple rapid updates
- Support for LCD clear, backlight control
- Bidirectional communication (responses to workers)
- Multiple worker coordination
