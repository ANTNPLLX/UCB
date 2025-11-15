# Workers Directory

This directory contains worker scripts that perform specific tasks on USB drives. Each worker is a shell script that gets auto-discovered and executed based on user choices.

## Built-in Workers

### 1. **analyze_malware.sh** (Order: 10)
**Question:** "Analyse complete?" / "Full analysis?"
**Purpose:** Scans USB drive for malware using ClamAV antivirus engine
**Enabled:** Configurable (default: enabled)

**What it does:**
- Updates ClamAV virus signatures before scanning
- Checks internet connectivity
- Mounts USB drive and counts files
- Performs full virus scan with real-time progress
- Detects infected files and displays results
- Logs all findings to `/var/log/usb_malware_scan.log`

**Requirements:** ClamAV

**Output:**
- 🟢 Green LED: No malware detected
- 🔴 Red LED: Malware/infected files found
- 🟠 Orange LED: Scan errors or warnings

---

### 2. **analyze_executables.sh** (Order: 20)
**Question:** "Executable chk?" / "recherche fichier Executable?"
**Purpose:** Detects potentially dangerous executable files
**Enabled:** Configurable (default: enabled)

**What it does:**
- Scans for Windows executables (.exe, .dll, .bat, .msi, etc.)
- Detects Linux ELF binaries
- Finds script files (.sh, .ps1, .vbs, .js, etc.)
- Uses both file extensions and magic numbers (MZ, ELF headers)
- Displays summary and details of found executables

**Requirements:** None

**Output:**
- 🟢 Green LED: No executable files found
- 🟠 Orange LED: Suspicious executables detected

---

### 3. **file_vitrification.sh** (Order: 25)
**Question:** "Vitrification?"
**Purpose:** Converts Office documents to safe PDFs and neutralizes other files
**Enabled:** Configurable (default: enabled)

**What it does:**
- **Creates quarantine folder:** `FICHIERS_POTENTIELLEMENT_DANGEREUX/`
  - Stores all original files (not deleted!)
  - Preserves directory structure

- **Step 1A:** Vitrifies existing PDF files (removes malicious content)
  - Processes all .pdf files FIRST
  - Removes JavaScript, embedded files, forms, malicious objects
  - Output: `document.pdf` → `document.pdf_vitrified_.pdf`
  - Skips already vitrified PDFs (ending with `_vitrified_.pdf`)
  - Moves original to quarantine folder

- **Step 1B:** Converts Office documents to clean PDF files
  - Formats: .doc, .docx, .xls, .xlsx, .ppt, .pptx, .odt, .ods, .odp, .rtf
  - Output naming: `original.ext_vitrified_.pdf` (preserves original extension)
  - Removes macros and embedded scripts
  - Moves original to quarantine folder

- **Step 2:** Neutralizes other files with `.hold` extension
  - Prevents execution by renaming (e.g., `malware.exe` → `malware.exe.hold`)
  - Preserves safe formats: .txt, .jpg, .png, .mp3, .mp4, etc.

**Requirements:** LibreOffice (auto-installs if needed)

**Output:**
- 🟢 Green LED: Vitrification completed successfully
- Displays conversion and neutralization counts
- Original files preserved in quarantine folder

**Important:** Original potentially dangerous files are NOT deleted - they are moved to the `FICHIERS_POTENTIELLEMENT_DANGEREUX` folder for review

---

### 4. **format_usb.sh** (Order: 30)
**Question:** "Formatage USB?" / "Format USB?"
**Purpose:** Securely formats USB drive to FAT32
**Enabled:** Configurable (default: enabled)

**What it does:**
- **Safety checks:** Prevents formatting system/root disk
- Unmounts all partitions on the device
- Wipes partition table completely
- Creates new MBR partition table
- Creates single FAT32 partition
- Labels USB as "CLEAN_USB"
- Verifies formatting with multiple methods

**Requirements:** None

**Output:**
- 🟢 Green LED: Format successful
- 🔴 Red LED: Format failed or blocked

**⚠️ WARNING:** Formatting permanently deletes ALL data on the USB drive!

---

### 5. **report_printer.sh** (Order: 35)
**Question:** "Copie rapport?"
**Purpose:** Creates a timestamped report file on the USB drive with current session logs
**Enabled:** Configurable (default: enabled)

**What it does:**
- Mounts USB drive
- Extracts all logs from the current session (after session banner)
- Creates timestamped report file: `YYYY-MM-DD_HH-MM_rapport_UCB.txt`
  - Example: `2025-11-15_14-30_rapport_UCB.txt`
  - Includes session banner with full device details
  - All worker choices and execution logs
  - Formatted report with headers and sections
- Displays line count and file size
- Unmounts drive after completion

**Session Detection:**
- Primary: Finds last "SESSION START" banner in logs
- Extracts everything from that banner to end of file
- Fallback: Last 30 lines if no session banner found

**Note:** Each report has a unique filename to prevent overwriting previous reports

**Requirements:** None

**Output:**
- 🟢 Green LED: Report created successfully
- 🔴 Red LED: Report creation failed
- Displays report statistics (line count)

---

### 6. **TEMPLATE_worker.sh**
**Purpose:** Template for creating new custom workers
**Enabled:** No (template only, not discovered)

This is not an active worker but a template file for developers to create new workers.

---

## Worker Metadata

Each worker contains metadata in its header:

```bash
# WORKER_QUESTION=Your question?      # Max 16 characters (displayed on LCD)
# WORKER_ORDER=100                    # Execution order (lower = earlier)
# WORKER_DESCRIPTION=Description      # Brief description
# WORKER_ENABLED=true                 # Enable/disable worker
```

---

## Enabling/Disabling Workers

To disable a worker without deleting it:

```bash
# Edit the worker file
nano workers/analyze_malware.sh

# Change WORKER_ENABLED to false
# WORKER_ENABLED=false

# Restart service
sudo systemctl restart usb-cleaner-box.service
```

Disabled workers are skipped - their questions won't appear on the LCD.

---

## Creating Custom Workers

1. **Copy the template:**
   ```bash
   cp workers/TEMPLATE_worker.sh workers/my_worker.sh
   ```

2. **Edit metadata:**
   ```bash
   # WORKER_QUESTION=My question?   # Max 16 chars!
   # WORKER_ORDER=25                # Between existing workers
   # WORKER_DESCRIPTION=What it does
   # WORKER_ENABLED=true
   ```

3. **Implement your logic:**
   - Worker receives device name as `$1` (e.g., "sdb")
   - Mount device, perform operations, unmount
   - Output keywords: `CLEAN`, `WARNING`, `INFECTED`
   - Return exit code 0 for success, non-zero for failure

4. **Make executable:**
   ```bash
   chmod +x workers/my_worker.sh
   ```

5. **Restart service:**
   ```bash
   sudo systemctl restart usb-cleaner-box.service
   ```

Worker will be auto-discovered on next run!

---

## Result Keywords

Main application analyzes worker output for keywords:

| Output Contains | Status | LED Color | Sound |
|----------------|--------|-----------|-------|
| `infected`, `malware`, `threat` | THREAT | 🔴 Red | Failed |
| `suspicious`, `warning:` | WARNING | 🟠 Orange | Warning |
| `clean:`, `safe`, `no` | CLEAN | 🟢 Green | Success |
| (non-zero exit code) | ERROR | 🔴 Red | Failed |

---

## Logs

All worker operations are logged to:
```
/var/log/usb_malware_scan.log
```

### Log Structure

Each session starts with a **session banner** containing:
- Timestamp
- Device path (/dev/sdX)
- Size, label, filesystem type
- Vendor, model, serial number

Example session banner:
```
================================================================================
                                 SESSION START
================================================================================
Timestamp:   2025-11-15 14:30:15
Device:      /dev/sda
Size:        58.6G
Label:       CLEAN_USB
Filesystem:  vfat
Vendor:      SanDisk
Model:       Ultra_USB_3.0
Serial:      4C530001234567890123
================================================================================
```

### Worker Choice Logging

Each worker prompt is logged:
```
[2025-11-15 14:30:20] --- "analyze_executables.sh": YES
[2025-11-15 14:30:35] --- "file_vitrification.sh": NO
[2025-11-15 14:30:40] --- "format_usb.sh": YES
```

### View Logs

View live logs:
```bash
sudo tail -f /var/log/usb_malware_scan.log
```

View last session:
```bash
sudo grep -A 999 "SESSION START" /var/log/usb_malware_scan.log | tail -100
```

---

## Worker Order

Workers are executed in order based on `WORKER_ORDER`:

1. **10** - Malware scan (detect threats first)
2. **20** - Executable check (identify suspicious files)
3. **25** - Vitrification (convert to safe formats)
4. **30** - Format (nuclear option - wipes everything)
5. **35** - Report printer (copy session logs to USB)

You can insert custom workers between these by using intermediate order numbers (e.g., 15, 22, 28, 32).

---

## More Information

- **Full documentation:** [../Documents/WORKER_GUIDE.md](../Documents/WORKER_GUIDE.md)
- **Template with examples:** [TEMPLATE_worker.sh](TEMPLATE_worker.sh)
- **Main README:** [../README.md](../README.md)

---

**Made with ❤️ for USB security**
