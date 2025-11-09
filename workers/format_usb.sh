#!/bin/bash
#
# format_usb.sh - Securely format USB device
#
# WORKER_QUESTION=Format USB?
# WORKER_ORDER=30
# WORKER_DESCRIPTION=Securely format USB drive (FAT32)
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
    # LCD updates handled by main Python application
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

echo -e "${YELLOW}=== Secure USB Format Started ===${NC}"
log_message "Starting secure format for $DEVICE_PATH"

# Safety check - prevent formatting system disk
if [ "$DEVICE" = "sda" ]; then
    echo -e "${RED}ERROR: Cannot format sda (system disk)${NC}"
    log_message "ERROR: Attempted to format system disk sda - BLOCKED"
    exit 1
fi

# Check if device exists
if [ ! -b "$DEVICE_PATH" ]; then
    echo -e "${RED}ERROR: Device $DEVICE_PATH does not exist${NC}"
    log_message "ERROR: Device $DEVICE_PATH not found"
    exit 1
fi

# Get device info
DEVICE_SIZE=$(lsblk -no SIZE "$DEVICE_PATH" 2>/dev/null | head -1)
echo -e "${YELLOW}Device: $DEVICE_PATH${NC}"
echo -e "${YELLOW}Size: $DEVICE_SIZE${NC}"
log_message "Formatting device: $DEVICE_PATH (Size: $DEVICE_SIZE)"

# Unmount all partitions on the device
echo "Unmounting all partitions on $DEVICE..."
for partition in ${DEVICE_PATH}*; do
    if [ -b "$partition" ] && [ "$partition" != "$DEVICE_PATH" ]; then
        if mountpoint -q "$partition" 2>/dev/null || mount | grep -q "$partition"; then
            echo "Unmounting $partition..."
            sudo umount "$partition" 2>/dev/null
        fi
    fi
done

# Wait a bit for unmount to complete
sleep 1

# Wipe partition table and create new one
echo -e "${YELLOW}Wiping partition table...${NC}"
log_message "Wiping partition table on $DEVICE_PATH"

# Use wipefs to remove all filesystem signatures
sudo wipefs -a "$DEVICE_PATH" 2>/dev/null

# Create new partition table using fdisk
echo -e "${YELLOW}Creating new partition table...${NC}"
log_message "Creating new MBR partition table"

# Use fdisk to create a new partition
(
echo o      # Create DOS partition table
echo n      # New partition
echo p      # Primary partition
echo 1      # Partition number
echo        # Default - first sector
echo        # Default - last sector
echo t      # Change partition type
echo b      # W95 FAT32 (LBA)
echo w      # Write changes
) | sudo fdisk "$DEVICE_PATH" > /dev/null 2>&1

# Wait for kernel to update partition table
sleep 2

# Check if partition was created
PARTITION="${DEVICE_PATH}1"
if [ ! -b "$PARTITION" ]; then
    echo -e "${RED}ERROR: Failed to create partition${NC}"
    log_message "ERROR: Failed to create partition $PARTITION"
    exit 1
fi

# Format the partition with FAT32
echo -e "${YELLOW}Formatting partition with FAT32...${NC}"
log_message "Formatting $PARTITION with FAT32"

if sudo mkfs.vfat -F 32 -n "CLEAN_USB" "$PARTITION"; then
    echo -e "${GREEN}Format successful!${NC}"
    log_message "Successfully formatted $PARTITION"

    # Verify the format
    echo "Verifying format..."
    FSTYPE=$(lsblk -no FSTYPE "$PARTITION")
    echo "Filesystem type: $FSTYPE"

    if [ "$FSTYPE" = "vfat" ]; then
        echo -e "${GREEN}Verification successful!${NC}"
        log_message "Format verification successful - filesystem: $FSTYPE"
        echo -e "${GREEN}=== USB Format Complete ===${NC}"
        log_message "Secure format completed successfully for $DEVICE_PATH"
        exit 0
    else
        echo -e "${RED}Verification failed - unexpected filesystem type${NC}"
        log_message "ERROR: Format verification failed - filesystem: $FSTYPE"
        exit 1
    fi
else
    echo -e "${RED}Format failed!${NC}"
    log_message "ERROR: Failed to format $PARTITION"
    exit 1
fi
