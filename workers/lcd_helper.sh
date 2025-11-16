#!/bin/bash
#
# lcd_helper.sh - Helper functions for workers to update LCD display
#

# Get the directory where this script is located
HELPER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Path to Python IPC script (one level up from workers/)
LCD_IPC_SCRIPT="${HELPER_DIR}/../lcd_ipc.py"

# Function to display on LCD via IPC
display_on_lcd() {
    local line1="$1"
    local line2="${2:-}"

    # Send command to LCD via Python IPC
    if [ -f "$LCD_IPC_SCRIPT" ]; then
        python3 "$LCD_IPC_SCRIPT" "$line1" "$line2" 2>/dev/null
        # Small delay to ensure file is written before worker continues
        sleep 0.05
    fi
}
