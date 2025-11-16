#!/bin/bash
#
# secure_erase.sh - Securely erase USB drive by overwriting with random data
#
# WORKER_QUESTION=Effacage secure?
# WORKER_ORDER=40
# WORKER_DESCRIPTION=Securely erase USB drive by overwriting with random data
# WORKER_ENABLED=true
#

# Configuration
SCAN_LOG="/var/log/usb_malware_scan.log"

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source LCD helper for display_on_lcd function
source "${SCRIPT_DIR}/lcd_helper.sh"

# Color codes for terminal output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

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

echo -e "${YELLOW}=== Secure Erase Started ===${NC}"
log_message "Starting secure erase for $DEVICE_PATH"

# Safety check: prevent erasing system disk
ROOT_DEVICE=$(lsblk -no PKNAME $(findmnt -n -o SOURCE /) 2>/dev/null)

if [ "$DEVICE" = "$ROOT_DEVICE" ]; then
    echo -e "${RED}CRITICAL ERROR: Attempted to erase system disk!${NC}"
    display_on_lcd "ERREUR!" "Disque systeme"
    log_message "ERROR: Attempted to erase system disk $DEVICE - BLOCKED"
    sleep 3
    exit 1
fi

# Check if device is mounted on critical system paths
if mount | grep "^${DEVICE_PATH}" | grep -E '(/ |/boot|/home|/usr|/var)' > /dev/null 2>&1; then
    echo -e "${RED}CRITICAL ERROR: Device has system partitions mounted!${NC}"
    display_on_lcd "ERREUR!" "Partition sys."
    log_message "ERROR: System partition detected on $DEVICE - BLOCKED"
    sleep 3
    exit 1
fi

# Check if device exists
if [ ! -b "$DEVICE_PATH" ]; then
    echo -e "${RED}ERROR: Device $DEVICE_PATH does not exist${NC}"
    display_on_lcd "ERREUR!" "Perif. absent"
    log_message "ERROR: Device $DEVICE_PATH not found"
    exit 1
fi

# Get device size
DEVICE_SIZE=$(lsblk -no SIZE "$DEVICE_PATH" 2>/dev/null | head -1)
DEVICE_SIZE_BYTES=$(lsblk -bno SIZE "$DEVICE_PATH" 2>/dev/null | head -1)

echo -e "${YELLOW}Device: $DEVICE_PATH${NC}"
echo -e "${YELLOW}Size: $DEVICE_SIZE${NC}"
log_message "Secure erasing device: $DEVICE_PATH (Size: $DEVICE_SIZE)"

# Warning display
echo -e "${RED}═══════════════════════════════════════════════${NC}"
echo -e "${RED}  WARNING: SECURE ERASE WILL PERMANENTLY      ${NC}"
echo -e "${RED}  DESTROY ALL DATA ON THE DEVICE!             ${NC}"
echo -e "${RED}═══════════════════════════════════════════════${NC}"

display_on_lcd "ATTENTION!" "Effacement total"
sleep 3

# Unmount all partitions on the device
echo "Unmounting all partitions on $DEVICE_PATH..."
display_on_lcd "Demontage..." "Partitions"

for part in ${DEVICE_PATH}*; do
    if [ -b "$part" ] && [ "$part" != "$DEVICE_PATH" ]; then
        sudo umount "$part" 2>/dev/null
        echo "Unmounted: $part"
    fi
done

log_message "All partitions unmounted"

# Start secure erase with dd
echo -e "${YELLOW}Starting secure erase with random data...${NC}"
display_on_lcd "Effacement" "En cours..."
log_message "Starting dd overwrite with random data"

# Calculate approximate time (assuming 20 MB/s write speed)
if [ -n "$DEVICE_SIZE_BYTES" ]; then
    ESTIMATED_SECONDS=$((DEVICE_SIZE_BYTES / 20 / 1024 / 1024))
    ESTIMATED_MINUTES=$((ESTIMATED_SECONDS / 60))
    echo "Estimated time: ~${ESTIMATED_MINUTES} minutes"
    log_message "Estimated time: ~${ESTIMATED_MINUTES} minutes"
fi

# Run dd in background to monitor progress
sudo dd if=/dev/urandom of="$DEVICE_PATH" bs=4M status=progress 2>&1 | while IFS= read -r line; do
    # Extract progress information
    if echo "$line" | grep -q "bytes"; then
        BYTES_WRITTEN=$(echo "$line" | awk '{print $1}')

        if [ -n "$DEVICE_SIZE_BYTES" ] && [ -n "$BYTES_WRITTEN" ]; then
            PERCENTAGE=$((BYTES_WRITTEN * 100 / DEVICE_SIZE_BYTES))

            # Update LCD every 5%
            if [ $((PERCENTAGE % 5)) -eq 0 ]; then
                display_on_lcd "Effacement..." "$PERCENTAGE%"
                echo -ne "\rProgress: $PERCENTAGE%"
            fi
        fi
    fi

    # Log the line
    echo "$line" | tee -a "$SCAN_LOG"
done

DD_EXIT_CODE=${PIPESTATUS[0]}

echo "" # New line after progress

# Check if dd completed successfully
if [ $DD_EXIT_CODE -eq 0 ]; then
    echo -e "${GREEN}Secure erase completed successfully!${NC}"
    display_on_lcd "Effacement OK!" "100%"
    log_message "Secure erase completed successfully"
    sleep 2

    # Now format the device with FAT32
    echo -e "${YELLOW}Formatting device to FAT32...${NC}"
    display_on_lcd "Formatage..." "FAT32"
    log_message "Formatting device to FAT32"

    # Create new partition table
    sudo parted -s "$DEVICE_PATH" mklabel msdos

    # Create FAT32 partition
    sudo parted -s "$DEVICE_PATH" mkpart primary fat32 1MiB 100%

    # Wait for partition to be created
    sleep 2

    PARTITION="${DEVICE_PATH}1"

    # Format with FAT32
    if sudo mkfs.vfat -F 32 -n "CLEAN_USB" "$PARTITION" 2>&1 | tee -a "$SCAN_LOG"; then
        echo -e "${GREEN}Device formatted successfully!${NC}"
        display_on_lcd "Format OK!" "CLEAN_USB"
        log_message "Device formatted to FAT32 successfully"
        sleep 2

        echo "CLEAN: Secure erase and format completed successfully"
    else
        echo -e "${RED}Format failed!${NC}"
        display_on_lcd "Echec format" "Erase OK"
        log_message "WARNING: Secure erase OK but format failed"
    fi

else
    echo -e "${RED}Secure erase failed!${NC}"
    display_on_lcd "Echec!" "Effacement"
    log_message "ERROR: Secure erase failed with exit code $DD_EXIT_CODE"
    exit 1
fi

echo -e "${GREEN}=== Secure Erase Complete ===${NC}"
log_message "Secure erase completed for $DEVICE_PATH"
log_message "----------------------------------------"
