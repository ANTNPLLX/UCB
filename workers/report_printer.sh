#!/bin/bash
#
# report_printer.sh - Copy session logs to USB drive report
#
# WORKER_QUESTION=Copie rapport?
# WORKER_ORDER=35
# WORKER_DESCRIPTION=Copy all session logs to rapport_UCB.txt on USB drive
# WORKER_ENABLED=true
#

# Configuration
SCAN_LOG="/var/log/usb_malware_scan.log"
# Generate timestamped filename: YYYY-MM-DD_HH-MM_rapport_UCB.txt
TIMESTAMP=$(date '+%Y-%m-%d_%H-%M')
REPORT_FILENAME="${TIMESTAMP}_rapport_UCB.txt"

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
MOUNT_POINT="/media/usb_report_${DEVICE}"

echo -e "${YELLOW}=== Report Printer Started ===${NC}"
log_message "Starting report generation for /dev/$DEVICE"

# Create mount point if it doesn't exist
sudo mkdir -p "$MOUNT_POINT"

# Mount the device
echo "Mounting /dev/${DEVICE}1 to $MOUNT_POINT"
display_on_lcd "Montage..." "Cle USB"

if sudo mount "/dev/${DEVICE}1" "$MOUNT_POINT" 2>/dev/null; then
    log_message "Device mounted successfully at $MOUNT_POINT"

    REPORT_PATH="${MOUNT_POINT}/${REPORT_FILENAME}"

    echo -e "${YELLOW}Creating session report...${NC}"
    display_on_lcd "Creation" "rapport..."

    # Find the last session banner in the log file
    # Session banners are marked by "SESSION START" surrounded by equals signs
    LAST_SESSION_LINE=$(grep -n "SESSION START" "$SCAN_LOG" | tail -1 | cut -d: -f1)

    # Create a temporary file to store session logs
    TEMP_LOGS=$(mktemp)

    if [ -n "$LAST_SESSION_LINE" ] && [ "$LAST_SESSION_LINE" -gt 0 ]; then
        # Extract all lines from the last session banner to the end of file
        # Start from 2 lines before the banner to include the separator
        SESSION_START=$((LAST_SESSION_LINE - 2))
        if [ "$SESSION_START" -lt 1 ]; then
            SESSION_START=1
        fi

        tail -n +${SESSION_START} "$SCAN_LOG" > "$TEMP_LOGS"
        log_message "Found session banner at line $LAST_SESSION_LINE, extracting session logs"
    else
        # No session banner found, use last 30 lines as fallback
        log_message "No session banner found, using last 30 lines"
        tail -30 "$SCAN_LOG" > "$TEMP_LOGS"
    fi

    # Count log lines
    LOG_COUNT=$(wc -l < "$TEMP_LOGS")
    log_message "Report contains $LOG_COUNT log lines"

    # Create report - just copy the session logs as-is
    # The session banner already contains all the device information
    {
        echo "========================================"
        echo "   RAPPORT USB CLEANER BOX"
        echo "========================================"
        echo ""
        echo "Rapport genere: $(date '+%Y-%m-%d %H:%M:%S')"
        echo "Peripherique: /dev/$DEVICE"
        echo ""

        # Extract session logs (includes session banner with all device info)
        cat "$TEMP_LOGS"

        echo ""
        echo "========================================"
        echo "   FIN DU RAPPORT"
        echo "========================================"

    } | sudo tee "$REPORT_PATH" > /dev/null

    # Clean up temporary file
    rm -f "$TEMP_LOGS"

    # Check if report was created successfully
    if [ -f "$REPORT_PATH" ] && [ -s "$REPORT_PATH" ]; then
        # Get line count and file size
        LINE_COUNT=$(wc -l < "$REPORT_PATH")
        FILE_SIZE=$(ls -lh "$REPORT_PATH" | awk '{print $5}')

        echo -e "${GREEN}✓ Report created successfully${NC}"
        echo "Report file: $REPORT_FILENAME"
        echo "Lines: $LINE_COUNT"
        echo "Size: $FILE_SIZE"

        log_message "Report created: $REPORT_PATH ($LINE_COUNT lines, $FILE_SIZE)"

        display_on_lcd "Rapport cree" "$LINE_COUNT lignes"
        sleep 2

        echo "CLEAN: Report generated successfully"

    else
        echo -e "${RED}✗ Failed to create report${NC}"
        log_message "ERROR: Failed to create report at $REPORT_PATH"
        display_on_lcd "Erreur" "Rapport echec"
        sleep 2
        exit 1
    fi

    # Unmount
    echo "Unmounting device..."
    display_on_lcd "Demontage..." "USB"
    sudo umount "$MOUNT_POINT"
    sudo rmdir "$MOUNT_POINT"
    log_message "Device unmounted"

else
    echo -e "${RED}Failed to mount /dev/${DEVICE}1${NC}"
    display_on_lcd "Erreur montage" "USB"
    log_message "ERROR: Failed to mount device for report generation"
    sleep 3
    exit 1
fi

echo -e "${GREEN}=== Report Printer Complete ===${NC}"
log_message "Report generation completed for /dev/$DEVICE"
