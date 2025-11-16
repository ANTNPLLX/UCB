# USB Cleaning Box - User Guide

## Step 1: Starting the Device
1. **Connect the power supply** - Plug the power cable into the device
2. **Wait for initialization** - Please wait approximately 20 seconds
3. **Device ready** - The screen displays: "Inserer une / clé USB..."

## Step 2: Insert the USB Drive
- Insert the USB drive into the USB port of the device

## Step 3: Choose the Treatments
For each available treatment, the screen displays a question
- **LEFT BUTTON (NO)** - Skip to the next treatment
- **RIGHT BUTTON (YES)** - Start the treatment

---

### Treatment Explanations
## "Executable chk?"
Detects potentially dangerous files (Windows .exe programs, scripts, Linux binaries).


## "Vitrification?"
Converts Office documents and PDFs into cleaned PDF files (removes macros, JavaScript, malicious objects). Original files are moved to the "FICHIERS_POTENTIELLEMENT_DANGEREUX" folder.

**Results:**
- Cleaned files: renamed to `filename.ext_vitrified_.pdf`
- Original files: moved to `FICHIERS_POTENTIELLEMENT_DANGEREUX/`
- Other files: renamed with `.hold` extension

## "Formatage USB?"
Erases ALL data and formats the USB drive to FAT32 (label "CLEAN_USB").

**⚠️ WARNING: This operation PERMANENTLY DELETES all data!**


## "Effacage secure?"
Securely erases the USB drive by overwriting ALL data with random data with this command 'dd if=/dev/urandom of="$DEVICE_PATH" bs=4M'.
This operation makes the data nearly impossible to recover.
Duration: approximately 50 minutes for a 64 GB drive

**⚠️ CRITICAL WARNING:**
- This operation PERMANENTLY DESTROYS all data

## "Copie rapport?"
Creates a report file on the USB drive with all logs from the current session: detailed information about the USB drive, treatments performed, analysis results, detected or processed files.

**File created:** `YYYY-MM-DD_HH-MM_rapport_UCB.txt`

## "Recommencer?"
After all treatments, the device offers to start over:
- **YES** - Restart the questions for the same USB drive
- **NO** - Proceed to the end message

---

### Step 4: Remove the Drive
- When the screen displays "Au revoir / Retirer cle USB"
- Remove the USB drive from the device
- The device is ready for a new drive


