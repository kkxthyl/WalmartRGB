from CameraController import CameraController
from LEDController import LEDController
import json
import time

class DataCollection:

    face_mapping = {
        "left": LEDController.LEFT,
        "right": LEDController.RIGHT,
        "top": LEDController.TOP,
        "back": LEDController.BACK
    }

    def __init__(
            self, 
            led_test=False, 
            camera_test=False, 
            calibration_folder="calibration_images"):
        
        self.camera = CameraController(led_test=led_test)
        self.led = LEDController(camera_test=camera_test)
        self.calibration_folder = calibration_folder
        self.color_configs = None

    def get_color_configs(self, config_path='assets/color_configs_test.json'):
        with open(config_path, 'r') as file:
            self.color_configs = json.load(file)
        return self.color_configs

    def take_image(self, iso=88, aperture=76, shutter_speed=56):
        # Take Image
        try:
            # Open the camera
            try:
                self.camera.open_camera()
                print("Camera opened successfully.")
            except Exception as e:
                print(f"Error opening camera: {e}")

            self.camera.set_aperture(aperture)
            self.camera.set_shutter_speed(shutter_speed)
            self.camera.set_iso(iso)
            self.camera.capture_image()
            time.sleep(1)  # Delay to ensure the image is saved on the card

            try:
                # Close the camera session
                self.camera.close_camera()
            except Exception as e:
                print(f"Error closing camera: {e}")

        except Exception as e:
            print(f"Error capturing image: {e}")

    def download_latest_image(self, filename):
        # Download the image
        try:

            # Open the camera
            try:
                self.camera.open_camera()
                print("Camera opened successfully.")
            except Exception as e:
                print(f"Error opening camera: {e}")

            self.camera.download_image(filename)

            try:
                # Close the camera session
                self.camera.close_camera()
            except Exception as e:
                print(f"Error closing camera: {e}")


        except Exception as e:
            print(f"Error downloading image: {e}")

    def take_mask_images(self):
        mask_led_patt = self.led.get_empty_pattern()
        for i in range(0, len(mask_led_patt)):
            mask_led_patt[i] = self.led.make_pixel(255, 255, 255, 255)

        self.led.display_pattern(mask_led_patt)

        print("----- Taking Image of Empty Scene -----")

        filename = f"{self.calibration_folder}/mask_no_obj.jpg"

        print("----- Taking Image of Empty Scene -----")

        self.take_image()
        self.download_latest_image(filename)

        print("----- Place Calibration Object then press Enter to take the image -----")

        filename = f"{self.calibration_folder}/mask_obj.jpg"

        input("Press Enter to continue…")
        
        print("----- Taking Image of Scene With Object -----")

        self.take_image()
        self.download_latest_image(filename)

    def capture_optimization_images(self, config_path='assets/color_configs_test.json'):
        if self.color_configs is None:
            self.get_color_configs(config_path)
        
        for color_set, sides in self.color_configs.items():
            print(f"\nColor set: {color_set}")

            # num_leds = self.led.device_data["number_of_led"]

            faces = {
                'top' : self.led.get_empty_pattern(),
                'back' : self.led.get_empty_pattern(),
                'left' : self.led.get_empty_pattern(),
                'right' : self.led.get_empty_pattern(),
            }
            for side, values in sides.items():
                filename = f"{self.calibration_folder}/{color_set}_{side}.jpg"
                
                r = values[0] * 255
                g = values[1] * 255
                b = values[2] * 255

                face_pattern = self.led.create_face_pattern(self.face_mapping[side], r, g, b, 255)

                faces[side] = face_pattern

                if not self.camera_test:
                    # Set the LED pattern
                    self.led.display_pattern(face_pattern)

                    # Wait for the LED to stabilize
                    time.sleep(5)

                self.take_image()
                self.download_latest_image(filename)

            filename = f"{self.calibration_folder}/{color_set}_combined.jpg"
            combined_pattern = self.led.combine_patterns(
                left=faces['left'],
                right=faces['right'],
                top=faces['top'],
                back=faces['back']
            )

            if not self.camera_test:
                # Set the LED pattern
                self.led.display_pattern(combined_pattern)

                # Wait for the LED to stabilize
                time.sleep(2)

            self.take_image()
            self.download_latest_image(filename)
            print(f"----- Finished taking {color_set} images -----")

    def close_sdk(self):
        self.camera.terminate_sdk()