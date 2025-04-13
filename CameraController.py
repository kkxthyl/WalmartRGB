import ctypes
import os
import sys
import time

class CameraController:
    # Constants used by the SDK.
    EDS_MAX_NAME = 256

    # Shutter command constants (verify these with your EDSDK headers)
    kEdsCameraCommand_PressShutterButton = 0x00000000
    kEdsCameraCommand_ShutterButton_Completely = 0x00000001
    kEdsCameraCommand_ShutterButton_OFF = 0x00000000

    # File stream constants
    kEdsFileCreateDisposition_CreateAlways = 2
    kEdsAccess_ReadWrite = 2

    # Define the Directory Item Structure (for file information)
    class EdsDirectoryItemInfo(ctypes.Structure):
        _fields_ = [
            ("size", ctypes.c_uint32),  # File size in bytes.
            ("isFolder", ctypes.c_uint32),  # Non-zero if the object is a folder.
            ("szFileName", ctypes.c_char * 256) # File name (C string).
        ]
    
    def __init__(self):
        """
        Initialize the CameraController instance.
        Loads the EDSDK library and sets up the function prototypes.
        """
        # Load the EDSDK library based on the operating system.
        if sys.platform == 'darwin':
            self.edsdk = ctypes.CDLL(
                'CANON_SDK/EDSDK_v13.19.0_Macintosh/EDSDK/Framework/EDSDK.framework/EDSDK'
            )
        else:
            self.edsdk = ctypes.CDLL('CANON_SDK/EDSDK_v13.19.0_Windows/EDSDK/Dll/EDSDK.dll')

        self.camera = None
        self._init_function_prototypes()

    def _check(self, err):
        """Helper function to check for errors returned by the SDK functions."""
        if err != 0:
            raise Exception("Error: 0x{:08X}".format(err))

    def _init_function_prototypes(self):
        """
        Define the argument and return types for the functions used from the EDSDK.
        """
        self.edsdk.EdsInitializeSDK.argtypes = []
        self.edsdk.EdsInitializeSDK.restype = ctypes.c_int

        self.edsdk.EdsTerminateSDK.argtypes = []
        self.edsdk.EdsTerminateSDK.restype = ctypes.c_int

        self.edsdk.EdsGetCameraList.argtypes = [ctypes.POINTER(ctypes.c_void_p)]
        self.edsdk.EdsGetCameraList.restype = ctypes.c_int

        self.edsdk.EdsGetChildCount.argtypes = [ctypes.c_void_p, ctypes.POINTER(ctypes.c_uint)]
        self.edsdk.EdsGetChildCount.restype = ctypes.c_int

        self.edsdk.EdsGetChildAtIndex.argtypes = [ctypes.c_void_p, ctypes.c_uint, ctypes.POINTER(ctypes.c_void_p)]
        self.edsdk.EdsGetChildAtIndex.restype = ctypes.c_int

        self.edsdk.EdsOpenSession.argtypes = [ctypes.c_void_p]
        self.edsdk.EdsOpenSession.restype = ctypes.c_int

        self.edsdk.EdsCloseSession.argtypes = [ctypes.c_void_p]
        self.edsdk.EdsCloseSession.restype = ctypes.c_int

        self.edsdk.EdsSendCommand.argtypes = [ctypes.c_void_p, ctypes.c_uint, ctypes.c_uint]
        self.edsdk.EdsSendCommand.restype = ctypes.c_int

        self.edsdk.EdsCreateFileStream.argtypes = [
            ctypes.c_char_p, ctypes.c_uint, ctypes.c_uint, ctypes.POINTER(ctypes.c_void_p)
        ]
        self.edsdk.EdsCreateFileStream.restype = ctypes.c_int

        self.edsdk.EdsDownload.argtypes = [ctypes.c_void_p, ctypes.c_uint, ctypes.c_void_p]
        self.edsdk.EdsDownload.restype = ctypes.c_int

        self.edsdk.EdsDownloadComplete.argtypes = [ctypes.c_void_p]
        self.edsdk.EdsDownloadComplete.restype = ctypes.c_int

        self.edsdk.EdsGetDirectoryItemInfo.argtypes = [
            ctypes.c_void_p, ctypes.POINTER(self.EdsDirectoryItemInfo)
        ]
        self.edsdk.EdsGetDirectoryItemInfo.restype = ctypes.c_int

    def open_camera(self):
        """
        Initialize the SDK, retrieve the first available camera,
        and open a session with it.
        """
        # Initialize the SDK.
        self._check(self.edsdk.EdsInitializeSDK())
        print("EDSDK initialized.")

        # Retrieve the camera list.
        camList = ctypes.c_void_p()
        self._check(self.edsdk.EdsGetCameraList(ctypes.byref(camList)))
        
        # Get the count of connected cameras.
        camCount = ctypes.c_uint(0)
        self._check(self.edsdk.EdsGetChildCount(camList, ctypes.byref(camCount)))
        if camCount.value == 0:
            raise Exception("No cameras found!")
        print(f"Found {camCount.value} camera(s).")

        # Retrieve the first camera.
        cam = ctypes.c_void_p()
        self._check(self.edsdk.EdsGetChildAtIndex(camList, 0, ctypes.byref(cam)))
        self.camera = cam
        print("Camera obtained.")

        # Open a session with the camera.
        self._check(self.edsdk.EdsOpenSession(self.camera))
        print("Session opened with camera.")

    def capture_image(self):
        """
        Trigger the camera shutter to capture an image.
        Make sure the camera session is open before calling this method.
        """
        if self.camera is None:
            raise Exception("Camera is not open. Call open_camera() first.")
        
        self._check(self.edsdk.EdsSendCommand(
            self.camera,
            self.kEdsCameraCommand_PressShutterButton,
            self.kEdsCameraCommand_ShutterButton_Completely
        ))
        print("Capture triggered.")

    def download_image(self, local_filename="downloaded_image.jpg"):
        """
        Download the most recent image from the camera's storage (SD card).
        This method navigates the folder structure (volume -> DCIM -> folder)
        and downloads the last file in the folder.
        """
        if self.camera is None:
            raise Exception("Camera is not open. Call open_camera() first.")
        
        # Retrieve the SD card volume (assumed at index 0).
        volume = ctypes.c_void_p()
        self._check(self.edsdk.EdsGetChildAtIndex(self.camera, 0, ctypes.byref(volume)))
        print("Volume (SD card) obtained.")

        # Access the DCIM folder (assumed at index 0 of volume).
        dcim_folder = ctypes.c_void_p()
        self._check(self.edsdk.EdsGetChildAtIndex(volume, 0, ctypes.byref(dcim_folder)))
        print("DCIM folder obtained.")

        # Access the folder containing images (for example, 'canon100' assumed at index 0).
        image_folder = ctypes.c_void_p()
        self._check(self.edsdk.EdsGetChildAtIndex(dcim_folder, 0, ctypes.byref(image_folder)))
        print("Image folder obtained.")

        # Get the file count in the folder.
        image_count = ctypes.c_uint(0)
        self._check(self.edsdk.EdsGetChildCount(image_folder, ctypes.byref(image_count)))
        print("Initial file count in folder:", image_count.value)
        if image_count.value == 0:
            raise Exception("No images found in folder.")

        # Get the most recent file (last index).
        file_index = image_count.value - 1
        file_ref = ctypes.c_void_p()
        self._check(self.edsdk.EdsGetChildAtIndex(image_folder, file_index, ctypes.byref(file_ref)))
        print("Most recent file reference obtained.")

        # Retrieve file information.
        dir_info = self.EdsDirectoryItemInfo()
        self._check(self.edsdk.EdsGetDirectoryItemInfo(file_ref, ctypes.byref(dir_info)))
        file_size = dir_info.size
        file_name = dir_info.szFileName.decode('utf-8', errors='ignore')
        print(f"File Info: {file_name} ({file_size} bytes).")

        # Prepare a local file stream.
        # Ensure the file exists (an empty file is created if necessary).
        local_filename_bytes = local_filename.encode('utf-8')
        with open(local_filename, "wb") as f:
            pass

        file_stream = ctypes.c_void_p()
        self._check(self.edsdk.EdsCreateFileStream(
            local_filename_bytes,
            self.kEdsFileCreateDisposition_CreateAlways,
            self.kEdsAccess_ReadWrite,
            ctypes.byref(file_stream)
        ))
        print(f"Local file stream created: {local_filename}")

        # Download the file.
        self._check(self.edsdk.EdsDownload(file_ref, file_size, file_stream))
        self._check(self.edsdk.EdsDownloadComplete(file_ref))
        print("Download complete.")

    def close_camera(self):
        """
        Close the camera session and terminate the SDK.
        """
        if self.camera is not None:
            try:
                self._check(self.edsdk.EdsCloseSession(self.camera))
                print("Session closed.")
            except Exception as e:
                print("Error closing session:", e)
            self.camera = None

    def terminate_sdk(self):
        try:
            self._check(self.edsdk.EdsTerminateSDK())
            print("EDSDK terminated.")
        except Exception as e:
            print("Error terminating SDK:", e)


# ================================
# Example usage:
# ================================
if __name__ == "__main__":
    cam_ctrl = CameraController()
    try:
        cam_ctrl.open_camera()         # Open camera and session
        cam_ctrl.capture_image()       # Trigger image capture
        # You may want to wait a bit for the capture to complete.
        time.sleep(1)                  # Delay to ensure the image is saved on the card
        
        cam_ctrl.download_image("calibration_images/test_img.jpg")  # Download the most recent image
    except Exception as e:
        print("An error occurred:", e)
    finally:
        cam_ctrl.close_camera()        # Clean up resources
