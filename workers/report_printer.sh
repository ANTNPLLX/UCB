#!/bin/bash
#
# report_printer.sh - Copy session logs to USB drive report
#
# WORKER_QUESTION=Copie rapport?
# WORKER_ORDER=99
# WORKER_DESCRIPTION=Copy all session logs to rapport_UCB.txt on USB drive
# WORKER_ENABLED=true
#

# Configuration
SCAN_LOG="/var/log/usb_malware_scan.log"
# Generate timestamped filename: YYYY-MM-DD_HH-MM_rapport_UCB.txt
TIMESTAMP=$(date '+%Y-%m-%d_%H-%M')
REPORT_FILENAME="${TIMESTAMP}_rapport_UCB.txt"

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

    # Create a temporary file to store session logs
    TEMP_LOGS=$(mktemp)

    # Find the last session banner that occurred BEFORE this report_printer worker started
    # We need to extract ONLY the current session, not all previous sessions

    # Look for the line where this worker was chosen (contains "report_printer.sh": YES/NO)
    # Use -a flag to handle binary data in log file
    WORKER_CHOICE_LINE=$(grep -a -n '"report_printer.sh":' "$SCAN_LOG" | tail -1 | cut -d: -f1)

    if [ -n "$WORKER_CHOICE_LINE" ] && [ "$WORKER_CHOICE_LINE" -gt 0 ]; then
        # Find ALL "SESSION START" lines in the entire log file with their absolute line numbers
        # Then filter to keep only those BEFORE the worker choice line
        # Finally take the last one
        # Use -a flag to handle binary data in log file
        LAST_SESSION_LINE=$(grep -a -n "SESSION START" "$SCAN_LOG" | \
                           awk -F: -v max="$WORKER_CHOICE_LINE" '$1 < max {print $1}' | \
                           tail -1)

        if [ -n "$LAST_SESSION_LINE" ] && [ "$LAST_SESSION_LINE" -gt 0 ]; then
            # Extract from session banner to worker choice line (current session only)
            SESSION_START=$((LAST_SESSION_LINE - 2))
            if [ "$SESSION_START" -lt 1 ]; then
                SESSION_START=1
            fi

            # Extract lines from SESSION_START to WORKER_CHOICE_LINE
            sed -n "${SESSION_START},${WORKER_CHOICE_LINE}p" "$SCAN_LOG" > "$TEMP_LOGS"
            log_message "Found session banner at line $LAST_SESSION_LINE, extracting current session only"
        else
            # No session banner found before worker choice
            log_message "No session banner found, using lines up to worker choice"
            head -n "$WORKER_CHOICE_LINE" "$SCAN_LOG" | tail -30 > "$TEMP_LOGS"
        fi
    else
        # Fallback: just find the last SESSION START and extract to end of file
        # Use -a flag to handle binary data in log file
        LAST_SESSION_LINE=$(grep -a -n "SESSION START" "$SCAN_LOG" | tail -1 | cut -d: -f1)

        if [ -n "$LAST_SESSION_LINE" ] && [ "$LAST_SESSION_LINE" -gt 0 ]; then
            SESSION_START=$((LAST_SESSION_LINE - 2))
            if [ "$SESSION_START" -lt 1 ]; then
                SESSION_START=1
            fi
            tail -n +${SESSION_START} "$SCAN_LOG" > "$TEMP_LOGS"
            log_message "Found session banner at line $LAST_SESSION_LINE (fallback mode)"
        else
            # No session banner found at all, use last 30 lines
            log_message "No session banner found, using last 30 lines"
            tail -30 "$SCAN_LOG" > "$TEMP_LOGS"
        fi
    fi

    # Count log lines
    LOG_COUNT=$(wc -l < "$TEMP_LOGS")
    log_message "Report contains $LOG_COUNT log lines"

    # Create report - just copy the session logs as-is
    # The session banner already contains all the device information
    {
        echo "================================================================================"
        echo "                            RAPPORT USB CLEANER BOX"
        echo "================================================================================"
        echo ""
        echo "Rapport genere: $(date '+%Y-%m-%d %H:%M:%S')"
        echo "Peripherique: /dev/$DEVICE"
        echo ""

        # Extract session logs (includes session banner with all device info)
        cat "$TEMP_LOGS"

        echo ""
        echo "================================================================================"
        echo "                               FIN DU RAPPORT"
        echo "================================================================================"

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
