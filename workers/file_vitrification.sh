#!/bin/bash
#
# file_vitrification.sh - Convert Office docs to PDF and neutralize other files
#
# WORKER_QUESTION=Vitrification?
# WORKER_ORDER=25
# WORKER_DESCRIPTION=Convert Office docs to PDF, add .hold to other files
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
    echo "Example: $0 sdb"
    exit 1
fi

DEVICE=$1
MOUNT_POINT="/media/usb_vitrify_${DEVICE}"

echo -e "${YELLOW}=== File Vitrification Started ===${NC}"
log_message "Starting file vitrification for /dev/$DEVICE"

# Check if LibreOffice is installed
if ! command -v libreoffice &> /dev/null; then
    echo -e "${YELLOW}LibreOffice not installed. Installing...${NC}"
    display_on_lcd "Installing" "LibreOffice..."
    log_message "Installing LibreOffice for PDF conversion"

    sudo apt-get update -qq
    sudo apt-get install -y libreoffice-writer libreoffice-calc libreoffice-core fonts-liberation

    if [ $? -ne 0 ]; then
        echo -e "${RED}Failed to install LibreOffice${NC}"
        display_on_lcd "Echec install." "Abandon..."
        log_message "ERROR: Failed to install LibreOffice"
        exit 1
    fi

    log_message "LibreOffice installed successfully"
fi

# Ensure fonts are installed (fixes fontconfig errors)
if [ ! -d "/usr/share/fonts/truetype/liberation" ]; then
    echo "Installing missing fonts..."
    display_on_lcd "Installing" "fonts..."
    sudo apt-get install -y fonts-liberation fonts-dejavu-core --no-install-recommends 2>&1 | tee -a "$SCAN_LOG"
    log_message "Fonts installed"
fi

# Create mount point if it doesn't exist
sudo mkdir -p "$MOUNT_POINT"

# Mount the device
echo "Mounting /dev/${DEVICE}1 to $MOUNT_POINT"
display_on_lcd "Montage..." "Cle USB"

if sudo mount "/dev/${DEVICE}1" "$MOUNT_POINT" 2>/dev/null; then
    log_message "Device mounted successfully at $MOUNT_POINT"

    # Create quarantine folder for potentially dangerous files
    QUARANTINE_FOLDER="${MOUNT_POINT}/FICHIERS_POTENTIELLEMENT_DANGEREUX"
    sudo mkdir -p "$QUARANTINE_FOLDER"
    log_message "Created quarantine folder: $QUARANTINE_FOLDER"

    # Arrays to track results
    CONVERTED_COUNT=0
    HOLD_COUNT=0
    ERROR_COUNT=0

    # Office document extensions to convert to PDF (excluding PDF itself)
    OFFICE_EXTENSIONS=("doc" "docx" "xls" "xlsx" "ppt" "pptx" "odt" "ods" "odp" "rtf")

    # Extensions to skip (safe media files that don't need vitrification)
    SKIP_EXTENSIONS=("txt" "md" "jpg" "jpeg" "png" "gif" "bmp" "mp3" "mp4" "avi" "mkv")

    echo -e "${YELLOW}Step 1A: Vitrifying existing PDF files (removes malicious content)${NC}"
    display_on_lcd "Vitrification" "PDFs..."

    # Process PDF files FIRST to avoid double-vitrification
    while IFS= read -r file; do
        if [ -f "$file" ]; then
            # Skip files in quarantine folder
            if [[ "$file" == *"/FICHIERS_POTENTIELLEMENT_DANGEREUX/"* ]]; then
                continue
            fi

            filename=$(basename "$file")

            # Skip already vitrified PDFs
            if [[ "$filename" == *"_vitrified_.pdf" ]]; then
                continue
            fi

            dirname=$(dirname "$file")
            filename_no_ext="${filename%.*}"

            echo "Vitrifying PDF: $filename"
            display_on_lcd "Vitrif..." "${filename:0:16}"

            # LibreOffice creates filename_no_ext.pdf by default
            TEMP_PDF_OUTPUT="${dirname}/${filename_no_ext}.pdf"
            # Final vitrified filename with original extension preserved
            FINAL_PDF_OUTPUT="${dirname}/${filename}_vitrified_.pdf"

            # Convert PDF to clean PDF using LibreOffice
            CONVERT_OUTPUT=$(sudo libreoffice --headless --convert-to pdf --outdir "$dirname" "$file" 2>&1)

            # Check if PDF was actually created
            if [ -f "$TEMP_PDF_OUTPUT" ] && [ -s "$TEMP_PDF_OUTPUT" ]; then
                # Rename to vitrified format: original.pdf_vitrified_.pdf
                sudo mv "$TEMP_PDF_OUTPUT" "$FINAL_PDF_OUTPUT"

                echo -e "${GREEN}✓ Vitrified PDF: $filename -> ${filename}_vitrified_.pdf${NC}"
                log_message "Vitrified PDF: $file -> ${filename}_vitrified_.pdf"

                # Move original file to quarantine folder (preserve directory structure)
                RELATIVE_PATH="${file#$MOUNT_POINT/}"
                QUARANTINE_PATH="${QUARANTINE_FOLDER}/${RELATIVE_PATH}"
                QUARANTINE_DIR=$(dirname "$QUARANTINE_PATH")

                sudo mkdir -p "$QUARANTINE_DIR"
                sudo mv "$file" "$QUARANTINE_PATH"
                log_message "Moved original PDF to quarantine: $QUARANTINE_PATH"

                CONVERTED_COUNT=$((CONVERTED_COUNT + 1))
            else
                echo -e "${RED}✗ Failed to vitrify PDF: $filename${NC}"
                echo "  LibreOffice output: $CONVERT_OUTPUT"
                log_message "ERROR: Failed to vitrify PDF $file - PDF not created"
                log_message "LibreOffice error: $CONVERT_OUTPUT"
                ERROR_COUNT=$((ERROR_COUNT + 1))
            fi

            sleep 0.2
        fi
    done < <(sudo find "$MOUNT_POINT" -type f -iname "*.pdf" 2>/dev/null)

    echo -e "${YELLOW}Step 1B: Converting Office documents to clean PDF${NC}"
    display_on_lcd "Conversion" "documents..."

    # Find and convert Office documents (NOT PDF - already done above)
    for ext in "${OFFICE_EXTENSIONS[@]}"; do
        echo "Searching for *.${ext} files..."

        while IFS= read -r file; do
            if [ -f "$file" ]; then
                # Skip files in quarantine folder
                if [[ "$file" == *"/FICHIERS_POTENTIELLEMENT_DANGEREUX/"* ]]; then
                    continue
                fi

                filename=$(basename "$file")
                dirname=$(dirname "$file")
                filename_no_ext="${filename%.*}"

                echo "Converting: $filename"
                display_on_lcd "Conversion..." "${filename:0:16}"

                # LibreOffice creates filename_no_ext.pdf by default
                TEMP_PDF_OUTPUT="${dirname}/${filename_no_ext}.pdf"
                # Final vitrified filename with original extension preserved
                FINAL_PDF_OUTPUT="${dirname}/${filename}_vitrified_.pdf"

                # Convert to PDF using LibreOffice in headless mode
                # Suppress stderr to avoid font config errors cluttering logs
                CONVERT_OUTPUT=$(sudo libreoffice --headless --convert-to pdf --outdir "$dirname" "$file" 2>&1)

                # Check if PDF was actually created
                if [ -f "$TEMP_PDF_OUTPUT" ] && [ -s "$TEMP_PDF_OUTPUT" ]; then
                    # Rename to vitrified format: original.ext_vitrified_.pdf
                    sudo mv "$TEMP_PDF_OUTPUT" "$FINAL_PDF_OUTPUT"

                    echo -e "${GREEN}✓ Converted: $filename -> ${filename}_vitrified_.pdf${NC}"
                    log_message "Converted: $file -> ${filename}_vitrified_.pdf"

                    # Move original file to quarantine folder (preserve directory structure)
                    RELATIVE_PATH="${file#$MOUNT_POINT/}"
                    QUARANTINE_PATH="${QUARANTINE_FOLDER}/${RELATIVE_PATH}"
                    QUARANTINE_DIR=$(dirname "$QUARANTINE_PATH")

                    sudo mkdir -p "$QUARANTINE_DIR"
                    sudo mv "$file" "$QUARANTINE_PATH"
                    log_message "Moved original to quarantine: $QUARANTINE_PATH"

                    CONVERTED_COUNT=$((CONVERTED_COUNT + 1))
                else
                    echo -e "${RED}✗ Failed to convert: $filename${NC}"
                    echo "  LibreOffice output: $CONVERT_OUTPUT"
                    log_message "ERROR: Failed to convert $file - PDF not created"
                    log_message "LibreOffice error: $CONVERT_OUTPUT"
                    ERROR_COUNT=$((ERROR_COUNT + 1))
                fi

                sleep 0.2
            fi
        done < <(sudo find "$MOUNT_POINT" -type f -iname "*.${ext}" 2>/dev/null)
    done

    echo -e "${YELLOW}Step 2: Neutralizing other files with .hold extension${NC}"
    display_on_lcd "Neutralisation" "Autres fichiers"

    # Find all remaining files (excluding vitrified PDFs and safe extensions)
    while IFS= read -r file; do
        if [ -f "$file" ]; then
            # Skip files in quarantine folder
            if [[ "$file" == *"/FICHIERS_POTENTIELLEMENT_DANGEREUX/"* ]]; then
                continue
            fi

            filename=$(basename "$file")
            extension="${filename##*.}"
            extension_lower=$(echo "$extension" | tr '[:upper:]' '[:lower:]')

            # Skip vitrified PDFs (already clean)
            if [[ "$filename" == *"_vitrified_.pdf" ]]; then
                continue
            fi

            # Check if extension should be skipped
            skip=false
            for skip_ext in "${SKIP_EXTENSIONS[@]}"; do
                if [ "$extension_lower" = "$skip_ext" ]; then
                    skip=true
                    break
                fi
            done

            if [ "$skip" = false ]; then
                echo "Neutralizing: $filename"
                display_on_lcd "Neutralis..." "${filename:0:16}"

                # Add .hold extension
                if sudo mv "$file" "${file}.hold" 2>/dev/null; then
                    echo -e "${GREEN}✓ Neutralized: $filename -> ${filename}.hold${NC}"
                    log_message "Neutralized: $file -> ${file}.hold"
                    HOLD_COUNT=$((HOLD_COUNT + 1))
                else
                    echo -e "${RED}✗ Failed to neutralize: $filename${NC}"
                    log_message "ERROR: Failed to neutralize $file"
                    ERROR_COUNT=$((ERROR_COUNT + 1))
                fi

                sleep 0.1
            fi
        fi
    done < <(sudo find "$MOUNT_POINT" -type f 2>/dev/null)

    # Display summary
    echo -e "${YELLOW}=== Vitrification Summary ===${NC}"
    echo "Office docs converted to PDF: $CONVERTED_COUNT"
    echo "Files neutralized (.hold): $HOLD_COUNT"
    echo "Errors: $ERROR_COUNT"

    log_message "Vitrification complete - Converted: $CONVERTED_COUNT, Neutralized: $HOLD_COUNT, Errors: $ERROR_COUNT"

    # Display results on LCD
    if [ "$ERROR_COUNT" -gt 0 ]; then
        echo -e "${RED}WARNING: Some files could not be processed${NC}"
        display_on_lcd "ALERTE" "$ERROR_COUNT erreurs"
        sleep 2
    fi

    display_on_lcd "Vitrification" "Terminee!"
    sleep 2

    display_on_lcd "Converti: $CONVERTED_COUNT" "Neutral: $HOLD_COUNT"
    sleep 3

    if [ $((CONVERTED_COUNT + HOLD_COUNT)) -gt 0 ]; then
        echo "CLEAN: Files vitrified successfully"
    else
        echo "CLEAN: No files needed vitrification"
    fi

    # Unmount
    echo "Unmounting device..."
    sudo umount "$MOUNT_POINT"
    sudo rmdir "$MOUNT_POINT"
    log_message "Device unmounted"

else
    echo -e "${RED}Failed to mount /dev/${DEVICE}1${NC}"
    display_on_lcd "Echec montage" "Vitrif. imposs"
    log_message "ERROR: Failed to mount device"
    sleep 3
    exit 1
fi

echo -e "${GREEN}=== File Vitrification Complete ===${NC}"
log_message "File vitrification completed for /dev/$DEVICE"
