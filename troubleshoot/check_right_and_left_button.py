import RPi.GPIO as GPIO

# Set up GPIO mode
GPIO.setmode(GPIO.BCM)

# Set up LED pin (GPIO13) and button pin (GPIO20)
BUTTON_PIN_LEFT = 23
BUTTON_PIN_RIGHT = 24


# Set GPIO20 as an input pin for the button with internal pull-up resistor
GPIO.setup(BUTTON_PIN_LEFT, GPIO.IN, pull_up_down=GPIO.PUD_UP)
GPIO.setup(BUTTON_PIN_RIGHT, GPIO.IN, pull_up_down=GPIO.PUD_UP)

try:
    while True:
        # Check if the button is pressed
        if GPIO.input(BUTTON_PIN_RIGHT) == GPIO.LOW:  # Button is pressed (LOW because of pull-up)
            print("RIGHT button pressed")
        if GPIO.input(BUTTON_PIN_LEFT) == GPIO.LOW:  # Button is pressed (LOW because of pull-up)
            print("LEFT button pressed")
#            with open("/home/pi/BNU/sounds/play_sncf_jingle.py") as f:
#                exec(f.read())

except KeyboardInterrupt:
    print("Program exited by user")

finally:
    # Clean up the GPIO settings
    GPIO.cleanup()
