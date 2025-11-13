#!/usr/bin/env python3
"""
usb_cleaner_box.py - Main USB Cleaner Box application

This application provides an interactive USB security scanning and cleaning system
with a dynamic worker system for extensibility.
"""

import sys
import os
import time
import RPi.GPIO as GPIO

# Add current directory to path
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from lcd_helper import LCD
from led_control import LEDController
from sound_helper import SoundPlayer
from button_input import ButtonInput
from usb_detection import USBDetector
from worker_manager import WorkerManager

# Get script directory
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
WORKERS_DIR = os.path.join(SCRIPT_DIR, "workers")

class USBCleanerBox:
    """Main USB Cleaner Box application class"""

    def __init__(self):
        """Initialize all hardware components"""
        print("Initializing USB Cleaner Box...")

        # Initialize hardware components
        self.lcd = LCD()
        self.leds = LEDController()
        self.sound = SoundPlayer()
        self.buttons = ButtonInput()
        self.usb = USBDetector()

        # Initialize worker manager
        self.worker_manager = WorkerManager(WORKERS_DIR)

        # State variables
        self.current_device = None

    def startup_sequence(self):
        """Perform startup sequence with LCD, LEDs, and sound"""
        print("Running startup sequence...")

        # Turn on LCD and display welcome message
        self.lcd.init()
        self.lcd.display("    BOITIER     ", " NETTOYAGE USB  ")

        # Play startup jingle
        self.sound.play_sncf_jingle()

        # Run LED snake animation (2 times, 4 seconds total)
        self.leds.snake_blocking(duration=4.0, speed=0.2)

        print("Startup complete!")

    def wait_for_usb(self):
        """Wait for USB device to be plugged in"""
        print("Waiting for USB device...")
        self.lcd.display("  Inserer une   ", "    clé USB...  ")
        self.leds.all_off()

        # Wait for USB device
        device = self.usb.wait_for_usb()

        if device:
            print(f"USB device detected: {device}")
            self.current_device = device

            # Get device info
            info = self.usb.get_device_info(device)
            print(f"Device info: {info}")

            # Display detection message
            self.lcd.display("USB detectee", f"{info['size']}")
            self.sound.play_beep()
            time.sleep(2)

            return True
        return False

    def ask_question(self, question):
        """
        Ask a yes/no question on LCD and wait for button input.
        Returns: True (YES), False (NO)
        """
        # Ensure question is max 16 chars
        question = question[:16]

        # Display question
        self.lcd.display(question, "NON         OUI")

        # Orange LED for question
        self.leds.orange_on()

        print(f"Question: {question}")
        print("Waiting for user input (LEFT=NO, RIGHT=YES)...")

        # Wait for button press
        answer = self.buttons.wait_for_yes_no()

        if answer is True:
            print("User answered: YES")
            self.leds.green_on()
            time.sleep(0.3)
            return True
        else:
            print("User answered: NO")
            self.leds.red_on()
            time.sleep(0.3)
            return False

    def run_worker(self, worker):
        """Run a worker script"""
        print(f"\n{'='*50}")
        print(f"Running worker: {worker.name}")
        print(f"Description: {worker.description}")
        print(f"{'='*50}\n")

        self.lcd.display("  Traitement   ", "  En cours...  ")
        self.leds.orange_on()

        # Run the worker
        result = worker.run(self.current_device)

        print(f"\nWorker completed: {worker.name}")
        print(f"Success: {result['success']}")
        print(f"Return code: {result['returncode']}")

        if result['stdout']:
            print(f"Output:\n{result['stdout']}")

        if result['stderr']:
            print(f"Errors:\n{result['stderr']}")

        return result

    def analyze_worker_result(self, worker, result):
        """Analyze worker result and return status"""
        if not result['success']:
            return 'error'

        # Check output for keywords
        output = result['stdout'].lower()

        # Check for malware/threats first (highest priority)
        if 'infected' in output or 'malware' in output or 'threat' in output:
            return 'threat'

        # Check for clean/success (before checking warnings)
        if 'clean:' in output or 'safe' in output:
            return 'clean'

        # Check for "no ... found" pattern (clean result)
        if 'found' in output and 'no' in output:
            # Check if "no" appears before "found" in the text
            if output.find('no') < output.find('found'):
                return 'clean'

        # Check for suspicious findings
        if 'suspicious' in output or 'warning:' in output:
            return 'warning'

        # Check for general "no" in output (clean)
        if 'no' in output and 'warning' not in output:
            return 'clean'

        # Default to uncertain
        return 'uncertain'

    def show_worker_result(self, worker, result):
        """Show result of a worker with LED and sound feedback"""
        status = self.analyze_worker_result(worker, result)

        print(f"\n=== WORKER RESULT: {status.upper()} ===")

        if status == 'threat':
            # Threat detected - RED blinking
            self.lcd.display("THREAT", "DETECTED!")
            self.leds.blink_red(duration=3.0, speed=0.3)
            self.sound.play_failed()
            time.sleep(2)

        elif status == 'warning':
            # Warning - ORANGE blinking
            self.lcd.display("WARNING", "Check results")
            self.leds.blink_orange(duration=3.0, speed=0.5)
            self.sound.play_warning()
            time.sleep(2)

        elif status == 'error':
            # Error - RED blinking
            self.lcd.display("ERROR", "Worker failed")
            self.leds.blink_red(duration=3.0, speed=0.5)
            self.sound.play_failed()
            time.sleep(2)

        else:
            # Clean or uncertain - GREEN blinking
            self.lcd.display("Completed", "Success!")
            self.leds.blink_green(duration=3.0, speed=0.5)
            self.sound.play_success()
            time.sleep(2)

    def process_usb(self):
        """Process USB with available workers"""
        # Get only enabled workers
        workers = self.worker_manager.get_workers(include_disabled=False)

        if not workers:
            print("No enabled workers available!")
            self.lcd.display("No workers", "available")
            time.sleep(2)
            return

        print(f"\nEnabled workers: {len(workers)}")
        for worker in workers:
            print(f"  - {worker}")

        # Process each worker
        for worker in workers:
            # Ask if user wants to run this worker
            if self.ask_question(worker.question):
                # Run the worker
                result = self.run_worker(worker)

                # Show result
                self.show_worker_result(worker, result)
            else:
                print(f"Skipping worker: {worker.name}")

            # Small delay between workers
            time.sleep(0.5)

    def goodbye_sequence(self):
        """Show goodbye message and cleanup"""
        print("\n=== Goodbye ===")
        self.lcd.display("   Au revoir    ", "Retirer cle USB")
        self.leds.snake_blocking(duration=2.0, speed=0.2)
        time.sleep(2)

    def main_loop(self):
        """Main application loop"""
        print("\n=== Entering main loop ===")

        while True:
            try:
                # Reset state
                self.current_device = None

                # Wait for USB device
                if not self.wait_for_usb():
                    continue

                # Process USB with workers
                self.process_usb()

                # Ask if user wants to run another worker
                while True:
                    if self.ask_question("Recommencer?"):
                        # Ask which workers to run again
                        self.process_usb()
                    else:
                        break

                # Update device list before goodbye (to track current state)
                self.usb.update_device_list()

                # Goodbye sequence
                self.goodbye_sequence()

                # Wait for USB to be removed before continuing
                print("Waiting for USB to be removed...")
                while self.current_device in self.usb.get_usb_devices():
                    time.sleep(0.5)

                # Update device list after removal
                self.usb.update_device_list()

                print("\n=== Ready for next USB device ===\n")

            except KeyboardInterrupt:
                print("\nShutdown requested by user")
                break
            except Exception as e:
                print(f"Error in main loop: {e}")
                import traceback
                traceback.print_exc()
                try:
                    self.lcd.display("Erreur System", "Redemarrage...")
                    time.sleep(2)
                except:
                    pass

    def cleanup(self):
        """Cleanup all resources"""
        print("Cleaning up...")
        try:
            self.leds.cleanup()
        except Exception as e:
            print(f"Warning: LED cleanup error: {e}")

        try:
            self.sound.cleanup()
        except Exception as e:
            print(f"Warning: Sound cleanup error: {e}")

        try:
            self.buttons.cleanup()
        except Exception as e:
            print(f"Warning: Button cleanup error: {e}")

        try:
            self.lcd.off()
        except Exception as e:
            print(f"Warning: LCD cleanup error: {e}")

        try:
            GPIO.cleanup()
        except Exception as e:
            print(f"Warning: GPIO cleanup error: {e}")

        print("Cleanup complete")

    def run(self):
        """Run the complete application"""
        try:
            # Startup sequence
            self.startup_sequence()

            # Enter main loop
            self.main_loop()

        except KeyboardInterrupt:
            print("\nApplication interrupted by user")
        except Exception as e:
            print(f"Fatal error: {e}")
            import traceback
            traceback.print_exc()
            try:
                self.lcd.display("Erreur Fatale", "Arret systeme")
                time.sleep(2)
            except:
                # LCD not available, just continue to cleanup
                pass
        finally:
            # Always cleanup
            self.cleanup()


def main():
    """Main entry point"""
    print("=" * 50)
    print("USB Cleaner Box - Starting...")
    print("=" * 50)

    app = USBCleanerBox()
    app.run()

    print("=" * 50)
    print("USB Cleaner Box - Shutdown complete")
    print("=" * 50)


if __name__ == '__main__':
    main()
