#!/bin/bash
#
# TEMPLATE_worker.sh - Template for creating new workers
#
# WORKER_QUESTION=Your question?   <-- UNCOMMENT THIS LINE TO ENABLE
# WORKER_ORDER=100
# WORKER_DESCRIPTION=Description of what this worker does
#
# Instructions:
# 1. Copy this template to a new file (e.g., my_worker.sh)
# 2. Update the metadata above:
#    - WORKER_QUESTION: Max 16 characters, displayed on LCD
#    - WORKER_ORDER: Number to control execution order (lower = earlier)
#    - WORKER_DESCRIPTION: Brief description of the worker
# 3. Implement your logic in the main section below
# 4. Make the script executable: chmod +x workers/my_worker.sh
# 5. The worker will be automatically discovered on next run
#
# Worker receives the USB device name as first parameter (e.g., "sdb")
# Return exit code 0 for success, non-zero for failure/error
#

# Configuration
SCAN_LOG="/var/log/usb_malware_scan.log"

# Color codes for terminal output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to display on LCD (disabled - handled by main app)
display_on_lcd() {
    # LCD updates are handled by the main Python application
    # Do not modify this function
    return 0
}

# Function to log with timestamp
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$SCAN_LOG"
}

# Check if device parameter is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <device>"
    echo "Example: $0 sdb"
    exit 1
fi

DEVICE=$1
DEVICE_PATH="/dev/$DEVICE"

# ============================================================
# MAIN WORKER LOGIC - Implement your functionality here
# ============================================================

echo -e "${YELLOW}=== Template Worker Started ===${NC}"
log_message "Template worker executing for device: $DEVICE"

# Example: Check if device exists
if [ ! -b "$DEVICE_PATH" ]; then
    echo -e "${RED}ERROR: Device $DEVICE_PATH does not exist${NC}"
    log_message "ERROR: Device $DEVICE_PATH not found"
    exit 1
fi

# Example: Get device information
DEVICE_SIZE=$(lsblk -no SIZE "$DEVICE_PATH" 2>/dev/null | head -1)
echo "Device: $DEVICE_PATH"
echo "Size: $DEVICE_SIZE"
log_message "Processing device $DEVICE_PATH (Size: $DEVICE_SIZE)"

# TODO: Add your worker logic here
# Examples:
# - Mount the device and scan files
# - Run custom security checks
# - Perform data recovery
# - Create backups
# - etc.

echo -e "${YELLOW}Performing custom checks...${NC}"
sleep 2  # Simulate work

# Example: Successful completion
echo -e "${GREEN}Template worker completed successfully!${NC}"
log_message "Template worker completed for $DEVICE"

# Exit with success code
exit 0

# ============================================================
# EXIT CODES
# ============================================================
# 0  = Success / Clean
# 1  = Error / Failure
# Other codes can be used for custom meanings
