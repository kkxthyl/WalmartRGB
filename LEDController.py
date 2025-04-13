import xled
import io
import struct
import math
import random
import time
import numpy as np

from xled.response import ApplicationResponse

class LEDController:
    """
    A class to encapsulate the LED device control.
    
    This class performs device discovery, LED configuration,
    and pattern display control based on the xled API.
    """

    LEFT = 0
    RIGHT = 1
    TOP = 2
    BACK = 3

    # [0, 168, 170, 299, 301, 469, 471, 599]

    null_lights = [169,300,470]

    LEFT_START = 0
    LEFT_END = 168
    RIGHT_START = 170
    RIGHT_END = 299
    TOP_START = 301
    TOP_END = 469
    BACK_START = 471
    BACK_END = 599

    def __init__(self, host=None, hw_address=None):
        """
        Initialize the LEDController.

        If host and hw_address are not provided, the device is discovered automatically.
        """
        if host is None or hw_address is None:
            discovered_device = xled.discover.discover()
            host = discovered_device.ip_address
            hw_address = discovered_device.hw_address
        self.control = xled.control.ControlInterface(host, hw_address=hw_address)
        self.device_data = self.control.get_device_info().data

    def set_rgb(self, r, g, b, brightness, saturation):
        """
        Set the LED color and adjust brightness and saturation.

        Parameters:
            r, g, b       : Color values.
            brightness    : Desired brightness.
            saturation    : Desired saturation.
        """
        json_payload = {"red": r, "green": g, "blue": b}
        response = self.control.session.post("led/color", json=json_payload)
        app_response = ApplicationResponse(response)
        required_keys = ["code"]
        assert all(key in app_response.keys() for key in required_keys), \
            "Response missing required keys."

        self.control.set_brightness(brightness)
        self.control.set_saturation(saturation)
        return response

    def display_pattern(self, patt):
        """
        Display a pattern in real-time.

        Parameters:
            patt: A list or bytes representing the pattern for the LED frame.
        """
        frame = self.to_movie(patt)
        if self.control.get_mode() != "rt":
            self.control.set_mode("rt")
        print("Current mode:", self.control.get_mode().data)
        return self.control.set_rt_frame_rest(frame)

    def to_movie(self, patlst):
        """
        Convert a pattern list or bytes to a BytesIO movie object.

        Parameters:
            patlst: A list of frames or a byte sequence.

        Returns:
            A BytesIO object representing the movie.
        """
        movie = io.BytesIO()
        if isinstance(patlst, list):
            for ele in patlst:
                if isinstance(ele, list):
                    ele = b"".join(ele)
                movie.write(ele)
        else:
            movie.write(patlst)
        movie.seek(0)
        return movie

    @staticmethod
    def make_pixel(r, g, b, w):
        """
        Create a pixel with color values scaled by brightness.

        Parameters:
            r, g, b: Base color values.
            w      : Brightness (weight) value.

        Returns:
            A bytes object representing the pixel.
        """
        # Scale the colors by the brightness factor w (assumed to be between 0 and 255)
        r = math.ceil(r * (w / 255))
        g = math.ceil(g * (w / 255))
        b = math.ceil(b * (w / 255))
        return struct.pack(">BBB", r, g, b)

    def set_face_pattern(self, face, r, g, b, w):
        """
        Set the color of a specific face of the LED cube.

        Parameters:
            face: The index of the face (0-3).
            r, g, b: Color values.
            w      : Brightness (weight) value.
        """
        if face < 0 or face > 3:
            raise ValueError("Face index must be between 0 and 5.")
        
        patt = [self.make_pixel(0, 0, 0, 0)] * self.device_data["number_of_led"]

        if face == self.LEFT:
            for i in range(self.LEFT_START, self.LEFT_END):
                patt[i] = self.make_pixel(r, g, b, w)
        elif face == self.RIGHT:
            for i in range(self.RIGHT_START, self.RIGHT_END):
                patt[i] = self.make_pixel(r, g, b, w)
        elif face == self.TOP:
            for i in range(self.TOP_START, self.TOP_END):
                patt[i] = self.make_pixel(r, g, b, w)
        elif face == self.BACK:
            for i in range(self.BACK_START, self.BACK_END):
                patt[i] = self.make_pixel(r, g, b, w)
        
        return patt

    def set_all(self, r, g, b, w):
        """
        Set all LEDs to the same color and brightness.

        Parameters:
            r, g, b: Color values.
            w      : Brightness (weight) value.
        """
        patt = [self.make_pixel(r, g, b, w)] * self.device_data["number_of_led"]
        for i in self.null_lights:
            patt[i] = self.make_pixel(0, 0, 0, 0)
        return patt

    def combine_patterns(self, left=[], right=[], top=[], back=[]):
        """
        Combine the provided face patterns into a single LED pattern.

        Each face pattern is expected to be a list of pixels (bytes) exactly matching
        the number of LEDs in that face (calculated as end - start + 1).
        The method inserts the face patterns into their designated regions of the overall pattern.
        The reserved indices (in null_lights) are left as 'off'.

        Parameters:
            left:  Pattern for the left face. Expected length: LEFT_END - LEFT_START + 1.
            right: Pattern for the right face. Expected length: RIGHT_END - RIGHT_START + 1.
            top: Pattern for the top face. Expected length: TOP_END - TOP_START + 1.
            back: Pattern for the back face. Expected length: BACK_END - BACK_START + 1.
            
        Returns:
            A list of pixel bytes for all LEDs with the combined face patterns.
        """
        total_leds = self.device_data["number_of_led"]
        combined = [self.make_pixel(0, 0, 0, 0)] * total_leds

        # Insert left face pattern.
        for i, pixel in enumerate(left):
            combined[self.LEFT_START + i] = pixel

        # Insert right face pattern.
        for i, pixel in enumerate(right):
            combined[self.RIGHT_START + i] = pixel

        # Insert top face pattern.
        for i, pixel in enumerate(top):
            combined[self.TOP_START + i] = pixel

        # Insert back face pattern.
        for i, pixel in enumerate(back):
            combined[self.BACK_START + i] = pixel

        return combined

if __name__ == "__main__":
    # Create an instance of the controller; device discovery happens automatically.
    led = LEDController()

    # Retrieve the number of LEDs from the device data.
    num_leds = led.device_data["number_of_led"]

    # Create a default pattern where all LEDs start turned off.
    # make_pixel(0, 0, 0, 0) creates a black/off pixel.
    patt = [LEDController.make_pixel(0, 0, 0, 0)] * num_leds

    # Set selected LED indices to white at full brightness.
    # List of special indices to activate.
    special_indices = [0, 168, 170, 299, 301, 469, 471, 599]
    for idx in special_indices:
        if idx < num_leds:  # Ensure the index is within range
            patt[idx] = LEDController.make_pixel(255, 255, 255, 255)

    # Display the pattern in real-time mode.
    led.display_pattern(patt)

    # Turn the device off after displaying the pattern.
    led.control.set_mode("off")
