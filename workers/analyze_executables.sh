#!/bin/bash
#
# analyze_executables.sh - Check USB device for executable files
#
# WORKER_QUESTION=Executable chk?
# WORKER_ORDER=20
# WORKER_DESCRIPTION=Check for suspicious executable files
# WORKER_ENABLED=true
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
    echo "Example: $0 sda"
    exit 1
fi

DEVICE=$1
MOUNT_POINT="/media/usb_scan_${DEVICE}"

echo -e "${YELLOW}=== Executable File Analysis Started ===${NC}"
log_message "Starting executable file analysis for /dev/$DEVICE"

# Display analyzing message
display_on_lcd "Analyse..." "Executables"

# Check if the device is mounted
if ! mountpoint -q "$MOUNT_POINT"; then
    # Mount the device
    sudo mkdir -p "$MOUNT_POINT"
    echo "Mounting /dev/${DEVICE}1 to $MOUNT_POINT"
    if ! sudo mount "/dev/${DEVICE}1" "$MOUNT_POINT" 2>/dev/null; then
        echo -e "${RED}Failed to mount /dev/${DEVICE}1${NC}"
        display_on_lcd "Echec montage" "Analyse imposs."
        log_message "ERROR: Failed to mount device"
        sleep 3
        exit 1
    fi
    MOUNTED_BY_US=true
else
    echo "Device already mounted at $MOUNT_POINT"
    MOUNTED_BY_US=false
fi

log_message "Device mounted at $MOUNT_POINT"

# Temporary files
TEMP_PE_FILES="/tmp/pe_files_$$"
TEMP_ELF_FILES="/tmp/elf_files_$$"
TEMP_SCRIPT_FILES="/tmp/script_files_$$"

# Search for Windows PE executables (.exe, .dll, .sys, .scr, etc.)
echo "Searching for Windows PE executables..."
display_on_lcd "Recherche..." "Exec Windows"

# Find by extension
sudo find "$MOUNT_POINT" -type f \( \
    -iname "*.exe" -o \
    -iname "*.dll" -o \
    -iname "*.sys" -o \
    -iname "*.scr" -o \
    -iname "*.com" -o \
    -iname "*.bat" -o \
    -iname "*.cmd" -o \
    -iname "*.msi" -o \
    -iname "*.pif" \
\) 2>/dev/null > "$TEMP_PE_FILES"

# Also check for PE files by magic number (MZ header)
echo "Checking file signatures..."
display_on_lcd "Verification..." "Signatures"

# Find files with PE signature (starts with MZ)
sudo find "$MOUNT_POINT" -type f -exec sh -c '
    head -c 2 "$1" 2>/dev/null | grep -q "MZ" && echo "$1"
' _ {} \; 2>/dev/null >> "$TEMP_PE_FILES"

# Search for Linux/Unix executables (ELF files)
echo "Searching for Linux ELF executables..."
display_on_lcd "Recherche..." "Exec Linux"

# Find ELF files by magic number
sudo find "$MOUNT_POINT" -type f -exec sh -c '
    head -c 4 "$1" 2>/dev/null | grep -q "ELF" && echo "$1"
' _ {} \; 2>/dev/null > "$TEMP_ELF_FILES"

# Search for script files that could be malicious
echo "Searching for script files..."
display_on_lcd "Recherche..." "Scripts"

sudo find "$MOUNT_POINT" -type f \( \
    -iname "*.sh" -o \
    -iname "*.bash" -o \
    -iname "*.ps1" -o \
    -iname "*.vbs" -o \
    -iname "*.js" -o \
    -iname "*.wsf" -o \
    -iname "*.hta" \
\) 2>/dev/null > "$TEMP_SCRIPT_FILES"

# Remove duplicates and sort
sort -u "$TEMP_PE_FILES" -o "$TEMP_PE_FILES"
sort -u "$TEMP_ELF_FILES" -o "$TEMP_ELF_FILES"
sort -u "$TEMP_SCRIPT_FILES" -o "$TEMP_SCRIPT_FILES"

# Count findings
PE_COUNT=$(wc -l < "$TEMP_PE_FILES")
ELF_COUNT=$(wc -l < "$TEMP_ELF_FILES")
SCRIPT_COUNT=$(wc -l < "$TEMP_SCRIPT_FILES")
TOTAL_EXECUTABLES=$((PE_COUNT + ELF_COUNT + SCRIPT_COUNT))

echo -e "${YELLOW}Analysis Results:${NC}"
echo "  Windows PE files: $PE_COUNT"
echo "  Linux ELF files: $ELF_COUNT"
echo "  Script files: $SCRIPT_COUNT"
echo "  Total executables: $TOTAL_EXECUTABLES"

log_message "Executable analysis - PE: $PE_COUNT, ELF: $ELF_COUNT, Scripts: $SCRIPT_COUNT"

# Display results
if [ "$TOTAL_EXECUTABLES" -eq 0 ]; then
    echo -e "${GREEN}No executable files found${NC}"
    echo "CLEAN: No executable files detected"
    display_on_lcd "Pas de fichier" "executable"
    log_message "Result: CLEAN - No executable files found"
    sleep 3
else
    echo -e "${RED}WARNING: $TOTAL_EXECUTABLES executable file(s) found!${NC}"
    echo "WARNING: $TOTAL_EXECUTABLES suspicious executables detected"
display_on_lcd "SUSPECT!" "$TOTAL_EXECUTABLES exec."
    log_message "Result: SUSPICIOUS - $TOTAL_EXECUTABLES executable files found"
    sleep 3
    
    # Display Windows PE files
    if [ "$PE_COUNT" -gt 0 ]; then
        display_on_lcd "Windows EXE:" "$PE_COUNT fichiers"
        log_message "Windows PE files found:"
        sleep 2
        
        # Show first 5 PE files
        COUNT=0
        while IFS= read -r filepath && [ "$COUNT" -lt 5 ]; do
            filename=$(basename "$filepath")
            echo -e "${RED}  PE: $filename${NC}"
            log_message "  PE: $filepath"
            
            display_on_lcd "Windows EXE:" "${filename:0:16}"
            sleep 2
            
            COUNT=$((COUNT + 1))
        done < "$TEMP_PE_FILES"
        
        # Log all PE files
        if [ "$PE_COUNT" -gt 5 ]; then
            echo -e "${YELLOW}  ... and $((PE_COUNT - 5)) more${NC}"
            tail -n +6 "$TEMP_PE_FILES" >> "$SCAN_LOG"
        fi
    fi
    
    # Display Linux ELF files
    if [ "$ELF_COUNT" -gt 0 ]; then
        display_on_lcd "Linux ELF:" "$ELF_COUNT fichiers"
        log_message "Linux ELF files found:"
        sleep 2
        
        # Show first 5 ELF files
        COUNT=0
        while IFS= read -r filepath && [ "$COUNT" -lt 5 ]; do
            filename=$(basename "$filepath")
            echo -e "${RED}  ELF: $filename${NC}"
            log_message "  ELF: $filepath"
            
            display_on_lcd "Linux ELF:" "${filename:0:16}"
            sleep 2
            
            COUNT=$((COUNT + 1))
        done < "$TEMP_ELF_FILES"
        
        # Log all ELF files
        if [ "$ELF_COUNT" -gt 5 ]; then
            echo -e "${YELLOW}  ... and $((ELF_COUNT - 5)) more${NC}"
            tail -n +6 "$TEMP_ELF_FILES" >> "$SCAN_LOG"
        fi
    fi
    
    # Display Script files
    if [ "$SCRIPT_COUNT" -gt 0 ]; then
        display_on_lcd "Scripts:" "$SCRIPT_COUNT fichiers"
        log_message "Script files found:"
        sleep 2
        
        # Show first 5 script files
        COUNT=0
        while IFS= read -r filepath && [ "$COUNT" -lt 5 ]; do
            filename=$(basename "$filepath")
            echo -e "${RED}  Script: $filename${NC}"
            log_message "  Script: $filepath"
            
            display_on_lcd "Script file:" "${filename:0:16}"
            sleep 2
            
            COUNT=$((COUNT + 1))
        done < "$TEMP_SCRIPT_FILES"
        
        # Log all script files
        if [ "$SCRIPT_COUNT" -gt 5 ]; then
            echo -e "${YELLOW}  ... and $((SCRIPT_COUNT - 5)) more${NC}"
            tail -n +6 "$TEMP_SCRIPT_FILES" >> "$SCAN_LOG"
        fi
    fi
    
    # Final warning
    display_on_lcd "USB SUSPECT" "Verifier!"
    sleep 3
fi

# Cleanup temp files
rm -f "$TEMP_PE_FILES" "$TEMP_ELF_FILES" "$TEMP_SCRIPT_FILES"

# Unmount only if we mounted it
if [ "$MOUNTED_BY_US" = true ]; then
    echo "Unmounting device..."
    sudo umount "$MOUNT_POINT"
    sudo rmdir "$MOUNT_POINT"
    log_message "Device unmounted"
fi

echo -e "${GREEN}=== Executable Analysis Complete ===${NC}"
log_message "Executable file analysis completed for /dev/$DEVICE"
echo "----------------------------------------" >> "$SCAN_LOG"
