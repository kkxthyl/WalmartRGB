import os
import argparse
import matplotlib.pyplot as plt
import json
import mitsuba as mi
mi.set_variant('llvm_rgb')

from Utils import SceneUtils as su
from Utils import ConfigUtils as cu
from Configs import Configs as cf
from HDRImap import HDRImap
from setup_calibration import SetupCalibration
from HDRIOptimization import HDRIOptimization as HDRIOpt
from DataCollection import DataCollection
from LEDController import LEDController

config_file = "src/data/calibrations.json"
calibration_images_folder = "src/data/calibration_images"
calibration_color_configs = "assets/color_configs.json"


def get_all_positions(scale=1.0):
    left = su.light_grid("left", cf.LIGHT_ROWS, cf.LIGHT_COLS, scale)
    top = su.light_grid("top", cf.LIGHT_ROWS, cf.LIGHT_COLS, scale)
    back = su.light_grid("back", cf.LIGHT_ROWS, cf.LIGHT_COLS, scale)
    right = su.light_grid("right", cf.LIGHT_ROWS, cf.LIGHT_COLS, scale)

    return left + top + back + right


def main(hdri_name, calibrate_flag):
    # =======================================
    #                SETUP
    # =======================================

    hdri_path = os.path.join("hdri", hdri_name)

    # ensure valid HDRI path
    if not os.path.isfile(hdri_path):
        print(f"ERROR: {hdri_name} does not exist, try:")
        for file in os.listdir("hdri"):
            if file.endswith(".exr"):
                print("  -", file)
        exit(1)
    print(f"Envmap {hdri_path} retrieved successfully.")

    all_pos = get_all_positions(scale=0.6)
    
    ConfigFile = cu(config_file)
    calibration_idx = ConfigFile.get_calibration_idx()

    if calibrate_flag:
        
        calibration_idx += 1
        ConfigFile.set_calibration_idx(calibration_idx)

        # =======================================
        #            DATA COLLECTION 
        # =======================================
        
        CollectionController = DataCollection(led_test=False, camera_test=False, calibration_folder=calibration_images_folder)

        # Capture Mask Images
        CollectionController.take_mask_images()

        # Capture Calibration Images
        CollectionController.capture_optimization_images(config_path=calibration_color_configs)

        # Close the camera SDK
        CollectionController.close_sdk()

        # =======================================
        #          CAMERA OPTIMIZATION
        # =======================================

        # TODO: Add camera parameters file to check first before attempting optimization
        camera_setup = None
        if camera_setup is None:
            camera_setup = SetupCalibration.optimize_camera()
            
        # =======================================
        #    TRANSFORM OPTIMIZATION    
        # =======================================

        light_setup = SetupCalibration.open_light_parameters(config_file)
        if light_setup is None:
            light_setup = SetupCalibration.optimize_lights(calibration_images_folder, config_file)


        for k, v in light_setup.items():
            print(k, v)


        # =======================================
        #             HDRI MAPPING
        # =======================================
        HDRImap.apply_hdri(
            emitters,
            hdri_path,
            [pos for _, pos in all_pos],
            hidr_scale_factor=0.003,
            n_clusters=598,
            scale=0.6
        )

        HDRImap.export_hdrimap_to_json(
            emitters, 
            os.path.join("intermediary_data/2_HDRI_mapping_results", "hdrimap.json")
        )

    # =======================================
    #           HDRI OPTIMIZATION
    # =======================================

    if not os.path.exists(f"src/data/optimized_hdri/optimized_{hdri_name}_{calibration_idx}.json"):
        initial_rgbs = json.load("intermediary_data/2_HDRI_mapping_results/hdrimap.json")
        reference = HDRIOpt.get_reference_hdri_scene(hdri_path, spp=64)
        emitters = {}
        for i, (face, pos) in enumerate(all_pos):
            rgb = initial_rgbs.get(f"light_{i}", {}).get("rgb", [0.0, 0.0, 0.0])
            emitters[f'light_{i}'] = {
                "type": "point",
                "position": pos,
                "intensity": {
                    "type": "rgb",
                    "value": rgb
                }
            }
        base_scene = su.get_base_scene_dict(emitters=emitters)
            
        optimized_colors, best_loss = HDRIOpt.optimize_light_intensities(
            scene=base_scene,
            emitters=emitters,
            reference_scene=reference,
            lr=0.00025,
            n_epochs=200,
        )
        
        with open(f"src/data/optimized_hdri/optimized_{hdri_name}_{calibration_idx}.json", "w") as f:
            json.dump(emitters, f, indent=4)

    # =======================================
    #            PHYSICAL MAPPING
    # =======================================

    led = LEDController()

    led_emitters = led.get_emitters_from_json(f"src/data/optimized_hdri/optimized_{hdri_name}_{calibration_idx}.json")
    patt = led.get_pattern_from_emitters(led_emitters)
    
    led.display_pattern(patt)

    # scene_dict = su.get_base_scene_dict()



if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--hdri', type=str, default="sample_hdri.exr",
                        help="Name of the HDRI file (e.g., 'studio.exr')")
    parser.add_argument('--calibrate', action='store_true',
                        help="Enable calibration mode")

    args = parser.parse_args()

    print(args.hdri)
    print(args.calibrate)

    main(args.hdri, args.calibrate)
