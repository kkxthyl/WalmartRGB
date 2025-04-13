import xled
import io
import struct
import numpy as np
import time
import math
import random
import json

from CameraController import CameraController
from LEDController import LEDController

camera_test = True
led_test = True

calibration_folder = 'calibration_images'

face_mapping = {
    "left": LEDController.LEFT,
    "right": LEDController.RIGHT,
    "top": LEDController.TOP,
    "back": LEDController.BACK
}

with open('cube/color_configs_test.json', 'r') as file:
    data = json.load(file)

# Initialize the camera and LED controllers
camera = CameraController(led_test=led_test)
led = LEDController(camera_test=camera_test)

# Open the camera
try:
    camera.open_camera()
    print("Camera opened successfully.")
except Exception as e:
    print(f"Error opening camera: {e}")

for color_set, sides in data.items():
    print(f"\nColor set: {color_set}")

    num_leds = led.device_data["number_of_led"]

    faces = {
        'top' : [led.make_pixel(0, 0, 0, 0)] * num_leds,
        'bottom' : [led.make_pixel(0, 0, 0, 0)] * num_leds,
        'left' : [led.make_pixel(0, 0, 0, 0)] * num_leds,
        'right' : [led.make_pixel(0, 0, 0, 0)] * num_leds,
    }

    for side, values in sides.items():
        filename = f"{calibration_folder}/{color_set}_{side}.jpg"
        # print(f"Filename: {filename}")

        r = values[0]
        g = values[1]
        b = values[2]

        face_pattern = led.create_face_pattern(face_mapping[side], r, g, b, 100)

        faces[side] = face_pattern

        if not camera_test:
            # Set the LED pattern
            led.display_pattern(face_pattern)

            # Wait for the LED to stabilize
            time.sleep(5)

        # Capture the image
        try:
            camera.capture_image()
            time.sleep(1)  # Delay to ensure the image is saved on the card
        except Exception as e:
            print(f"Error capturing image: {e}")

        # Download the image
        try:
            camera.download_image(filename)
        except Exception as e:
            print(f"Error downloading image: {e}")

    filename = f"{calibration_folder}/{color_set}_combined.jpg"

    # Combine the patterns for all faces
    combined_pattern = led.combine_patterns(
        left=faces['left'],
        right=faces['right'],
        top=faces['top'],
        back=faces['bottom']
    )

    if not camera_test:
        # Set the LED pattern
        led.display_pattern(face_pattern)

        # Wait for the LED to stabilize
        time.sleep(5)

    # Capture the image
    try:
        camera.capture_image()
        time.sleep(1)  # Delay to ensure the image is saved on the card
    except Exception as e:
        print(f"Error capturing image: {e}")

    # Download the image
    try:
        camera.download_image(filename)
    except Exception as e:
        print(f"Error downloading image: {e}")

if not led_test:
    # Close the camera session
    camera.close_camera()

    # Terminate the SDK
    camera.terminate_sdk()
