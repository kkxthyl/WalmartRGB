import os
import argparse
from Utils import SceneUtils as su
from Configs import Configs as cf
import mitsuba as mi
import matplotlib.pyplot as plt


def get_all_positions(scale=1.0):
    left = su.light_grid("left", 10, 15, scale)
    top = su.light_grid("top", 10, 15, scale)
    back = su.light_grid("back", 10, 15, scale)
    right = su.light_grid("right", 10, 15, scale)

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

    # =======================================
    #       DATA COLLECTION (OPTIONAL)
    # =======================================

    data_dir = os.path.join("<JOHN'S DATA>")

    # =======================================
    #         CAMERA OPTIMIZATION
    # =======================================

    # =======================================
    #        TRANSFORM OPTIMIZATION
    # =======================================

    # =======================================
    #             HDRI MAPPING
    # =======================================

    # =======================================
    #           HDRI OPTIMIZATION
    # =======================================

    # =======================================
    #            PHYSICAL MAPPING
    # =======================================

    scene_dict = su.get_base_scene_dict()

    all_pos = get_all_positions(scale=0.6)


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
