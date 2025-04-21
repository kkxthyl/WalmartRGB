import os
import argparse
import matplotlib.pyplot as plt
import json
import mitsuba as mi
from Utils import SceneUtils

from Utils import SceneUtils as su
from Utils import ConfigUtils as cu
from Configs import Configs as cf

mi.set_variant(cf.mitsuba_variant)

from HDRImap import HDRImap
from setup_calibration import SetupCalibration
from HDRIOptimization import HDRIOptimization as HDRIOpt
from DataCollection import DataCollection
from LEDController import LEDController

config_file = "data/calibrations.json"
calibration_images_folder = "data/calibration_images"
calibration_color_configs = "../assets/color_configs.json"

calibration_light_configs = "data/light_setup.json"
calibration_camera_configs = "data/camera_setup.json"


def get_all_positions(scale=1.0):
    left = su.light_grid("left", cf.LIGHT_ROWS, cf.LIGHT_COLS, scale)
    top = su.light_grid("top", cf.LIGHT_ROWS, cf.LIGHT_COLS, scale)
    back = su.light_grid("back", cf.LIGHT_ROWS, cf.LIGHT_COLS, scale)
    right = su.light_grid("right", cf.LIGHT_ROWS, cf.LIGHT_COLS, scale)

    return left + top + back + right


def main(hdri_name, calibrate_flag, calibrate_physical, show_debug=False):
    # =======================================
    #                SETUP
    # =======================================
    print("\n1. Setup") if show_debug else None

    hdri_path = os.path.join("hdri", hdri_name)

    # ensure valid HDRI path
    if not os.path.isfile(hdri_path):
        print(f"ERROR: {hdri_name} does not exist, try:")
        for file in os.listdir("hdri"):
            if file.endswith(".exr"):
                print("  -", file)
        exit(1)
    print(f"ENVMAP '{hdri_path}' retrieved successfully.")

    all_pos = get_all_positions(scale=0.6)
    print(all_pos[0])

    ConfigFile = cu(config_file)
    calibration_idx = ConfigFile.get_calibration_idx()

    if calibrate_flag:

        calibration_idx += 1
        ConfigFile.set_calibration_idx(calibration_idx)
        # calibration_color_configs = open(calibration_color_, "r")

        # =======================================
        #            DATA COLLECTION
        # =======================================
        print("\n2. Data Collection") if show_debug else None
        if calibrate_physical:
            
            CollectionController = DataCollection(led_test=False, camera_test=False, calibration_folder=calibration_images_folder)

            # Capture Mask Images
            CollectionController.take_mask_images()

            # Capture Calibration Images
            CollectionController.capture_optimization_images(config_path=calibration_color_configs)

            # Close the camera SDK
            CollectionController.close_sdk()

            exit()

        # =======================================
        #          CAMERA OPTIMIZATION
        # =======================================
        print("\n3. Camera Optimization") if show_debug else None
        run_optimization = calibrate_physical or calibrate_flag
        try:
            camera_setup = SetupCalibration.open_camera_parameters(config_file)
        except KeyError:
            run_optimization = True

        if run_optimization:
            camera_setup = SetupCalibration.optimize_camera(all_pos, calibration_images_folder, calibration_color_configs, config_file)
            if show_debug:
                print("Camera setup:")
                for k, v in camera_setup.items():
                    print(f"  {k, v}")
            

        # =======================================
        #    TRANSFORM OPTIMIZATION
        # =======================================
        print("\n4. Transform Optimization") if show_debug else None
        run_optimization = calibrate_physical or calibrate_flag
        try:
            light_setup = SetupCalibration.open_light_parameters(config_file)
        except KeyError:
            run_optimization = True
        
        if run_optimization:
            light_setup = SetupCalibration.optimize_lights(all_pos, calibration_images_folder,
                                                        calibration_color_configs, calibration_light_configs, camera_setup, config_file)
            if show_debug:
                print("Light setup:")
                for k, v in light_setup.items():
                    print(f"  {k, v}")

        # Build transformation
        emitters = SetupCalibration.get_emitters(all_pos, 'WHITE', calibration_color_configs)

        translation = json.loads(light_setup['translation'])[0]
        scale = json.loads(light_setup['scale'])[0]
        roll = json.loads(light_setup['roll'])[0]
        pitch = json.loads(light_setup['pitch'])[0]
        yaw = json.loads(light_setup['yaw'])[0]

        emitters = SceneUtils.update_emitters(
            emitters,
            translation,
            scale,
            [roll, pitch, yaw]
        )

        # =======================================
        #             HDRI MAPPING
        # =======================================
        print("\n5. HDRI Mapping") if show_debug else None
        HDRImap.apply_hdri(
            emitters,
            hdri_path,
            [pos for _, pos in all_pos],
            light_cfg=config_file,
            hidr_scale_factor=0.003,
            n_clusters=598,
            scale=0.6,
            verbose=show_debug
        )

        HDRImap.export_hdrimap_to_json(
            emitters,
            config_file
        )

    # =======================================
    #           HDRI OPTIMIZATION
    # =======================================
    print("\n6. HDRI Optimization") if show_debug else None

    if not os.path.exists(f"src/data/optimized_hdri/optimized_{hdri_name}_{calibration_idx}.json"):
        print('Loading initial RGB values from calibration file.') if show_debug else None
        calibration = json.load(open("data/calibrations.json", "r"))
        initial_rgbs = calibration.get("hdri_mapping", {})
        reference = HDRIOpt.get_reference_hdri_scene(hdri_path, sample_count=512, hide_hdri=True)

        # assign mapped intensities to fresh emitters
        print("Initializing HDRI-mapped emitters.") if show_debug else None
        optim_emitters = {}
        for i, (face, pos) in enumerate(all_pos):
            rgb = initial_rgbs.get(f"light_{i}", {}).get("rgb", [0.0, 0.0, 0.0])
            optim_emitters[f'light_{i}'] = {
                "type": "point",
                "position": pos,
                "intensity": {
                    "type": "rgb",
                    "value": rgb
                }
            }
        base_scene_dict = su.get_base_scene_dict(low_res=True)
        base_scene_dict = su.add_checkerboard_to_scene_dict(base_scene_dict)

        base_scene_dict.update(optim_emitters)
        base_scene = mi.load_dict(base_scene_dict)
        print("Optimizing mapped light intensities.") if show_debug else None
        _, loss_hist, best_idx = HDRIOpt.optimize_light_intensities(
            scene=base_scene,
            emitters=optim_emitters,
            reference_scene=reference,
            cam_cfg=config_file,
            lr=0.00025,
            n_epochs=100,
            spp=16,
            patience=3,
            visualize_steps=debug_flag
        )

        print("Final optimization loss:", loss_hist[best_idx]) if show_debug else None

        with open(f"data/optimized_hdri/optimized_{hdri_name[:-4]}_{calibration_idx}.json", "w") as f:
            json.dump(optim_emitters, f, indent=4)

    # =======================================
    #            PHYSICAL MAPPING
    # =======================================
    print("\n7. Physical Mapping") if show_debug else None

    # led = LEDController()
    #
    # led_emitters = led.get_emitters_from_json(f"src/data/optimized_hdri/optimized_{hdri_name}_{calibration_idx}.json")
    # patt = led.get_pattern_from_emitters(led_emitters)
    #
    # led.display_pattern(patt)

    # scene_dict = su.get_base_scene_dict()


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--hdri', type=str, default="indoor.exr",
                        help="Name of the HDRI file (e.g., 'indoor.exr')")
    parser.add_argument('--calibrate', action='store_true',
                        help="Enable calibration mode")
    # parser.add_argument('--v', action='store_true',
    #                     help="Show more output for debugging purposes")
    parser.add_argument('--calibrate_physical', action='store_true',
                        help="Capture camera calibration images")

    args = parser.parse_args()

    debug_flag = True

    print(f"HDRI FILE: {args.hdri}") if debug_flag else None
    print(f"CALIBRATION FLAG: {args.calibrate}") if debug_flag else None
    print(f"PHYSICAL CALIBRATION FLAG: {args.calibrate_physical}") if debug_flag else None

    main(args.hdri, args.calibrate, args.calibrate_physical, debug_flag)
