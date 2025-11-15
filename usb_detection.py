#!/usr/bin/env python3
"""
usb_detection.py - USB detection module for USB Cleaner Box
"""

import subprocess
import time
import os

class USBDetector:
    """USB detection and management class"""

    def __init__(self):
        self.current_devices = self.get_usb_devices()

    def get_usb_devices(self):
        """Get list of current USB storage devices"""
        try:
            # Look for sd* devices (USB drives typically show as sda, sdb, etc.)
            result = subprocess.run(
                ['lsblk', '-ndo', 'NAME,TYPE'],
                capture_output=True,
                text=True,
                check=True
            )

            devices = []
            print(f"[DEBUG] lsblk output:\n{result.stdout}")

            for line in result.stdout.strip().split('\n'):
                if line:
                    parts = line.split()
                    if len(parts) >= 2:
                        name, dev_type = parts[0], parts[1]
                        print(f"[DEBUG] Found device: {name} type: {dev_type}")
                        # Look for disk type devices starting with 'sd'
                        # Don't exclude any sd device - let user handle it
                        if dev_type == 'disk' and name.startswith('sd'):
                            devices.append(name)
                            print(f"[DEBUG] Added device: {name}")

            print(f"[DEBUG] Total devices found: {devices}")
            return set(devices)
        except Exception as e:
            print(f"Error detecting USB devices: {e}")
            return set()

    def wait_for_usb(self, timeout=None):
        """
        Wait for a USB device to be plugged in.
        Returns: device name (e.g., 'sdb') or None if timeout
        """
        start_time = time.time()
        print(f"[DEBUG] Initial devices: {self.current_devices}")

        while True:
            current = self.get_usb_devices()
            new_devices = current - self.current_devices

            print(f"[DEBUG] Current devices: {current}")
            print(f"[DEBUG] New devices: {new_devices}")

            if new_devices:
                # New device detected
                device = list(new_devices)[0]
                print(f"[DEBUG] New USB device detected: {device}")
                self.current_devices = current
                # Wait a bit for the device to be fully recognized
                time.sleep(1)
                return device

            # Check timeout
            if timeout and (time.time() - start_time) > timeout:
                return None

            time.sleep(0.5)

    def is_mounted(self, device):
        """Check if a device is mounted"""
        try:
            result = subprocess.run(
                ['mount'],
                capture_output=True,
                text=True,
                check=True
            )
            return f'/dev/{device}' in result.stdout
        except Exception:
            return False

    def get_mount_point(self, device):
        """Get mount point of a device"""
        try:
            result = subprocess.run(
                ['findmnt', '-n', '-o', 'TARGET', f'/dev/{device}1'],
                capture_output=True,
                text=True,
                check=False
            )
            if result.returncode == 0:
                return result.stdout.strip()
            return None
        except Exception:
            return None

    def mount_device(self, device, mount_point=None):
        """
        Mount a USB device.
        Returns: mount point or None on failure
        """
        if mount_point is None:
            mount_point = f"/media/usb_{device}"

        try:
            # Create mount point if it doesn't exist
            os.makedirs(mount_point, exist_ok=True)

            # Try to mount the first partition
            subprocess.run(
                ['sudo', 'mount', f'/dev/{device}1', mount_point],
                check=True,
                capture_output=True
            )

            return mount_point
        except Exception as e:
            print(f"Error mounting device: {e}")
            return None

    def unmount_device(self, device):
        """Unmount a USB device"""
        try:
            subprocess.run(
                ['sudo', 'umount', f'/dev/{device}1'],
                check=True,
                capture_output=True
            )
            return True
        except Exception as e:
            print(f"Error unmounting device: {e}")
            return False

    def get_device_info(self, device):
        """Get comprehensive device information"""
        info = {
            'device': device,
            'size': 'Unknown',
            'label': 'No label',
            'fstype': 'Unknown',
            'vendor': 'Unknown',
            'model': 'Unknown',
            'serial': 'Unknown'
        }

        try:
            # Get size from the main device
            result = subprocess.run(
                ['lsblk', '-no', 'SIZE', f'/dev/{device}'],
                capture_output=True,
                text=True,
                check=True
            )
            lines = result.stdout.strip().split('\n')
            if lines:
                info['size'] = lines[0].strip()
        except Exception as e:
            print(f"Error getting device size: {e}")

        try:
            # Get label and filesystem type from the first partition
            result = subprocess.run(
                ['lsblk', '-no', 'LABEL,FSTYPE', f'/dev/{device}1'],
                capture_output=True,
                text=True,
                check=True
            )
            output = result.stdout.strip()
            if output:
                parts = output.split(None, 1)
                if len(parts) >= 1:
                    # First part could be label or fstype (if no label)
                    # Check if it looks like a filesystem type
                    if parts[0] in ['vfat', 'ntfs', 'exfat', 'ext4', 'ext3', 'ext2']:
                        info['fstype'] = parts[0]
                        info['label'] = 'No label'
                    else:
                        info['label'] = parts[0]
                        if len(parts) >= 2:
                            info['fstype'] = parts[1]
                elif len(parts) >= 2:
                    info['label'] = parts[0] if parts[0] else 'No label'
                    info['fstype'] = parts[1]
        except Exception as e:
            print(f"Error getting device label/fstype: {e}")

        try:
            # Get vendor and model from udev
            result = subprocess.run(
                ['udevadm', 'info', '--query=property', f'/dev/{device}'],
                capture_output=True,
                text=True,
                check=True
            )
            for line in result.stdout.split('\n'):
                # ID_VENDOR_ID and ID_MODEL_ID are the actual names from USB
                if line.startswith('ID_VENDOR_FROM_DATABASE='):
                    info['vendor'] = line.split('=', 1)[1].strip()
                elif line.startswith('ID_VENDOR=') and info['vendor'] == 'Unknown':
                    # Fallback to ID_VENDOR if no database entry
                    info['vendor'] = line.split('=', 1)[1].strip()
                elif line.startswith('ID_MODEL_FROM_DATABASE='):
                    info['model'] = line.split('=', 1)[1].strip()
                elif line.startswith('ID_MODEL=') and info['model'] == 'Unknown':
                    # Fallback to ID_MODEL if no database entry
                    info['model'] = line.split('=', 1)[1].strip()
                elif line.startswith('ID_SERIAL_SHORT='):
                    info['serial'] = line.split('=', 1)[1].strip()
        except Exception as e:
            print(f"Error getting device vendor/model: {e}")

        return info

    def update_device_list(self):
        """Update the current device list"""
        self.current_devices = self.get_usb_devices()
