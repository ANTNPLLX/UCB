 #!/usr/bin/env python3
import sys
import os
import time
import RPi.GPIO as GPIO

# Get the directory where this script is located
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, SCRIPT_DIR)

from sound_helper import SoundPlayer

# Clean up any existing GPIO setup
try:
    GPIO.cleanup()
except:
    pass

try:
    sound = SoundPlayer()

#    print("Testing beep...")
#    sound.play_beep()
#    time.sleep(1)

#    print("Testing success...")
#    sound.play_success()
#    time.sleep(1)

#    print("Testing failed...")
#    sound.play_failed()
#    time.sleep(1)

    print("Testing warning...")
    sound.play_warning()
    time.sleep(1)

#    print("Testing SNCF jingle...")
#    sound.play_sncf_jingle()
#    time.sleep(1)

    print("All tests complete!")

except Exception as e:
    print(f"Error: {e}")
    import traceback
    traceback.print_exc()

finally:
    try:
        sound.cleanup()
    except:
        pass
    GPIO.cleanup()

