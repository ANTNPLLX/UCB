#!/bin/bash
#
# start.sh - USB Cleaner Box launcher script
#

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MAIN_SCRIPT="$SCRIPT_DIR/usb_cleaner_box.py"

echo "========================================"
echo "  USB Cleaner Box Launcher"
echo "========================================"
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "This script requires root privileges."
    echo "Restarting with sudo..."
    echo ""
    exec sudo "$0" "$@"
fi

# Check if main script exists
if [ ! -f "$MAIN_SCRIPT" ]; then
    echo "ERROR: Main script not found at $MAIN_SCRIPT"
    exit 1
fi

# Check if required scripts exist
if [ ! -f "$SCRIPT_DIR/workers/analyze_malware.sh" ]; then
    echo "WARNING: workers/analyze_malware.sh not found"
fi

if [ ! -f "$SCRIPT_DIR/workers/analyze_executables.sh" ]; then
    echo "WARNING: workers/analyze_executables.sh not found"
fi

# Start the application
echo "Starting USB Cleaner Box..."
echo ""
python3 "$MAIN_SCRIPT"

echo ""
echo "USB Cleaner Box stopped."
