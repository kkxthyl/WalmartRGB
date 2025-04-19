from Utils import SceneUtils as su
import Configs as cf
import mitsuba as mi
import matplotlib.pyplot as plt

def main():

    return


if __name__ == '__main__':
    scene_dict = su.get_base_scene_dict()

    scale = 0.6
    CONST = (scale / 2) + (scale / 5)
    left  = su.light_grid("left",  10, 15, -CONST, scale)
    top   = su.light_grid("top",   10, 15,  CONST, scale)
    back  = su.light_grid("back",  10, 15, -CONST, scale)
    right = su.light_grid("right", 10, 15,  CONST, scale)
    all_pos = left + top + back + right
    main()

