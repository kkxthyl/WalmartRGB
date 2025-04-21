import mitsuba as mi
import matplotlib.pyplot as plt
import numpy as np
import cv2
import json

class SceneUtils:

    @staticmethod
    def light_grid_old(face, n1, n2, const_val, scale=1.0):
        positions = []
        half = scale / 2

        if face == "top":
            xs = np.linspace(-half, half, n1)
            zs = np.linspace(-half, half, n2)[::-1]

            for row_idx, z in enumerate(zs):
                if row_idx % 2 == 0:
                    x_iter = xs[::-1]
                else:
                    x_iter = xs

                for x in x_iter:
                    positions.append((face, [x, const_val, z]))

        elif face == "back":
            xs = np.linspace(-half, half, n1)
            ys = np.linspace(-half, half, n2)[::-1]

            for row_idx, x in enumerate(xs):
                if row_idx % 2 == 0:
                    y_iter = ys[::-1]
                else:
                    y_iter = ys

                for y in y_iter:
                    positions.append((face, [x, y, const_val]))

        elif face == "left":
            ys = np.linspace(-half, half, n1)
            zs = np.linspace(-half, half, n2)

            for row_idx, z in enumerate(zs):
                if row_idx >= 10:
                    continue
                if row_idx % 2 == 0:
                    y_iter = ys[::-1]
                else:
                    y_iter = ys

                for y in y_iter:
                    positions.append((face, [const_val, y, z]))

        elif face == "right":
            ys = np.linspace(-half, half, n1)
            zs = np.linspace(-half, half, n2)

            for row_idx, z in enumerate(zs):
                if row_idx >= 10:
                    continue
                if row_idx % 2 == 0:
                    y_iter = ys[::-1]
                else:
                    y_iter = ys

                for y in y_iter:
                    positions.append((face, [const_val, y, z]))
        return positions
        
    @staticmethod
    def light_grid(face, n1, n2, scale=1.0):
        positions = []
        half = scale / 2

        const_val_n1 = (scale/2) + (scale/(n1+2))
        const_val_n2 = (scale/2) + (scale/(n2+2))

        if face == "top":
            xs = np.linspace(-half, half, n1)
            zs = np.linspace(-half, half, n2)[::-1]

            for row_idx, z in enumerate(zs):
                if row_idx % 2 == 0:
                    x_iter = xs[::-1]
                else:
                    x_iter = xs

                for x in x_iter:
                    positions.append((face, [float(val) for val in [x, const_val_n2, z]]))

        elif face == "back":
            xs = np.linspace(-half, half, n1)
            ys = np.linspace(-half, half, n2)[::-1]

            for row_idx, x in enumerate(xs):
                if row_idx % 2 == 0:
                    y_iter = ys[::-1]
                else:
                    y_iter = ys

                for y in y_iter:
                    positions.append((face, [float(val) for val in [x, y, -const_val_n2]]))

        elif face == "left":
            ys = np.linspace(-half, half, n1)
            zs = np.linspace(-half, half, n2)

            for row_idx, z in enumerate(zs):
                if row_idx >= 10:
                    continue
                if row_idx % 2 == 0:
                    y_iter = ys[::-1]
                else:
                    y_iter = ys

                for y in y_iter:
                    positions.append((face, [float(val) for val in [-const_val_n1, y, z]]))

        elif face == "right":
            ys = np.linspace(-half, half, n1)
            zs = np.linspace(-half, half, n2)

            for row_idx, z in enumerate(zs):
                if row_idx >= 10:
                    continue
                if row_idx % 2 == 0:
                    y_iter = ys[::-1]
                else:
                    y_iter = ys

                for y in y_iter:
                    positions.append((face, [float(val) for val in [const_val_n1, y, z]]))
        return positions

    @staticmethod
    def light_grid_2d(face, n1, n2, scale=1.0):
        pos = SceneUtils.light_grid(face, n1, n2, scale)
        pos = [coords for (_face, coords) in pos]

        return pos

    @staticmethod
    def get_cube_path():
        cube_dir = "../assets/cube.obj"
        return cube_dir
    
    @staticmethod
    def get_base_scene_dict(low_res=False):
        w = 5184
        h = 3456
        if low_res:
            w = 800
            h = 600
        scene_dict = {
            "type": "scene",
            "integrator": {"type": "path"},
            "sensor": {
                "type": "perspective",
                "sampler": {"type": "independent", "sample_count": 512},
                "to_world": mi.ScalarTransform4f().look_at(
                    origin=mi.ScalarPoint3f(0, 0.1, 0.45),
                    target=mi.ScalarPoint3f(0, 0, 0),
                    up=mi.ScalarPoint3f(0, 1, 0)
                ),
                "film": {
                    "type": "hdrfilm",
                    "width": w,
                    "height": h,
                    "pixel_format": "rgb"
                }
            },
            "env": {
                "type": "constant",
                "radiance": {"type": "rgb", "value": [0.01, 0.01, 0.01]}
            },
            "checkerboard": {
                "type": "rectangle",
                "to_world": mi.ScalarTransform4f()
                    .translate(mi.ScalarPoint3f(0, 0, 0))
                    .rotate(mi.ScalarPoint3f(1, 0, 0), -90)
                    .scale(mi.ScalarPoint3f(0.2, 0.2, 1.0)),
                "bsdf": {
                    "type": "diffuse",
                    "reflectance": {
                        "type": "checkerboard",
                        "color0": { "type": "rgb", "value": [1,1,1] },
                        "color1": { "type": "rgb", "value": [0,0,0] },
                        "to_uv": mi.ScalarTransform4f().scale([10.0, 10.0, 1.0])
                    }
                }
            }
        }

        return scene_dict

    # @staticmethod
    # def get_scene_dict_empty_cube_old(HIDE_EMITTERS=True):
    #     filename = SceneUtils.get_cube_path()
    #     scene_dict = {
    #         "type": "scene",
    #         "integrator": {
    #             "type": "path", 
    #             "hide_emitters": HIDE_EMITTERS,},
    #         "sensor": {
    #             "type": "perspective",
    #             "to_world": mi.ScalarTransform4f().look_at(
    #                 origin=[0, 0.0, 18],
    #                 target=[0, 0, 0],
    #                 up=[0, 1, 0]
    #             ),
    #              "sampler": {
    #                 "type": "independent",
    #                 "sample_count": 512
    #             },
    #             "film": {
    #                 "type": "hdrfilm",
    #                 "width": 800,
    #                 "height": 600,
    #                 "pixel_format": "rgb"
    #             },
    #         },
    #         "env": {
    #             "type": "constant",
    #             "radiance": {"type": "rgb", "value": [0.01, 0.01, 0.01]}
    #         },
    #         "cube-back":{
    #             "type": "obj",
    #             "filename": filename,
    #             "to_world": mi.ScalarTransform4f()
    #                 .translate([0, 0, -10])  
    #             , 
    #             "bsdf": {
    #                 "type": "twosided",
    #                 "bsdf": {
    #                     "type": "diffuse",
    #                     "reflectance": {"type": "rgb", "value": [0.2, 0.2, 0.2]}
    #                 }
    #             }
    #         },

    #         "cube-top":{
    #             "type": "obj",
    #             "filename": filename,
    #             "to_world": mi.ScalarTransform4f()
    #                 .translate([0, 10, 0])  
    #             ,  
    #             "bsdf": {
    #                 "type": "twosided",
    #                 "bsdf": {
    #                     "type": "diffuse",
    #                     "reflectance": {"type": "rgb", "value": [0.2, 0.2, 0.2]}
    #                 }
    #             }
    #         }, 
    #         "cube-left":{
    #             "type": "obj",
    #             "filename": filename,
    #             "to_world": mi.ScalarTransform4f()
    #                 .translate([10,0, 0]) 
    #             ,  
    #             "bsdf": {
    #                 "type": "twosided",
    #                 "bsdf": {
    #                     "type": "diffuse",
    #                     "reflectance": {"type": "rgb", "value": [0.2, 0.2, 0.2]}
    #                 }
    #             }
    #         }, 
    #         "cube-right":{
    #             "type": "obj",
    #             "filename":filename,
    #             "to_world": mi.ScalarTransform4f()
    #                 .translate([-10, 0, 0]) 
    #             , 
    #             "bsdf": {
    #                 "type": "twosided",
    #                 "bsdf": {
    #                     "type": "diffuse",
    #                     "reflectance": {"type": "rgb", "value": [0.2, 0.2, 0.2]}
    #                 }
    #             }
    #         }, 
    #         "cube-bottom":{
    #             "type": "obj",
    #             "filename": filename,
    #             "to_world": mi.ScalarTransform4f()
    #                 .translate([0, -10, 0])  
    #             , 
    #             "bsdf": {
    #                 "type": "twosided",
    #                 "bsdf": {
    #                     "type": "diffuse",
    #                     "reflectance": {"type": "rgb", "value": [0.2, 0.2, 0.2]}
    #                 }
    #             }
    #         }
    #     }

    #     return scene_dict

    # @staticmethod
    # def get_scene_dict_empty_cube(HIDE_EMITTERS=True, origin_pos=[0,0,18], target_pos=[0,0,0], up=[0,1,0], cube_reflectance=[0.2, 0.2, 0.2], sample_count=512, env_radiance=[0.01, 0.01, 0.01]):
    #     filename = SceneUtils.get_cube_path()
    #     scene_dict = {
    #         "type": "scene",
    #         "integrator": {
    #             "type": "path", 
    #             "hide_emitters": HIDE_EMITTERS,},
    #         "sensor": {
    #             "type": "perspective",
    #             "to_world": mi.ScalarTransform4f().look_at(
    #                 origin=origin_pos,
    #                 target=target_pos,
    #                 up=up
    #             ),
    #              "sampler": {
    #                 "type": "independent",
    #                 "sample_count": sample_count
    #             },
    #             "film": {
    #                 "type": "hdrfilm",
    #                 "width": 800,
    #                 "height": 600,
    #                 "pixel_format": "rgb"
    #             },
    #         },
    #         "env": {
    #             "type": "constant",
    #             "radiance": {"type": "rgb", "value": env_radiance}
    #         },
    #         "cube-back":{
    #             "type": "obj",
    #             "filename": filename,
    #             "to_world": mi.ScalarTransform4f()
    #                 .translate([0, 0, -10])  
    #             , 
    #             "bsdf": {
    #                 "type": "twosided",
    #                 "bsdf": {
    #                     "type": "diffuse",
    #                     "reflectance": {"type": "rgb", "value": cube_reflectance}
    #                 }
    #             }
    #         },

    #         "cube-top":{
    #             "type": "obj",
    #             "filename": filename,
    #             "to_world": mi.ScalarTransform4f()
    #                 .translate([0, 10, 0])  
    #             ,  
    #             "bsdf": {
    #                 "type": "twosided",
    #                 "bsdf": {
    #                     "type": "diffuse",
    #                     "reflectance": {"type": "rgb", "value": cube_reflectance}
    #                 }
    #             }
    #         }, 
    #         "cube-left":{
    #             "type": "obj",
    #             "filename": filename,
    #             "to_world": mi.ScalarTransform4f()
    #                 .translate([10,0, 0]) 
    #             ,  
    #             "bsdf": {
    #                 "type": "twosided",
    #                 "bsdf": {
    #                     "type": "diffuse",
    #                     "reflectance": {"type": "rgb", "value": cube_reflectance}
    #                 }
    #             }
    #         }, 
    #         "cube-right":{
    #             "type": "obj",
    #             "filename":filename,
    #             "to_world": mi.ScalarTransform4f()
    #                 .translate([-10, 0, 0]) 
    #             , 
    #             "bsdf": {
    #                 "type": "twosided",
    #                 "bsdf": {
    #                     "type": "diffuse",
    #                     "reflectance": {"type": "rgb", "value": cube_reflectance}
    #                 }
    #             }
    #         }, 
    #         "cube-bottom":{
    #             "type": "obj",
    #             "filename": filename,
    #             "to_world": mi.ScalarTransform4f()
    #                 .translate([0, -10, 0])  
    #             , 
    #             "bsdf": {
    #                 "type": "twosided",
    #                 "bsdf": {
    #                     "type": "diffuse",
    #                     "reflectance": {"type": "rgb", "value": cube_reflectance}
    #                 }
    #             }
    #         }
    #     }

    #     return scene_dict

    @staticmethod
    def add_sphere_to_scene_dict(scene_dict):
        scene_dict.update({
            "center_sphere": {
                    "type": "sphere",
                    "to_world": mi.ScalarTransform4f()
                        .translate([0, 0, 0])
                        .scale([2, 2, 2]),      # sphere radius 2
                    "bsdf": {
                        "type": "diffuse",
                        "reflectance": {
                            "type": "checkerboard",
                            "color0": { "type": "rgb", "value": [0.8, 0.8, 0.8] },
                            "color1": { "type": "rgb", "value": [0.2, 0.2, 0.2] },
                            # use the scalar transform for UVs too:
                            "to_uv": mi.ScalarTransform4f().scale([5, 5, 5])
                        }
                    }
        }})

        return scene_dict
    
    @staticmethod
    def update_emitters(emitters, translation=[0.0, 0.0, 0.0], scale=1.0, orientation=[0.0, 0.0, 0.0], faces_on = ["left", "top", "back", "right"]):
        x, y, z = translation
        s = scale
        x_r, y_r, z_r = orientation

        transform = (
            mi.ScalarTransform4f()
            .translate([x, y, z])
            .rotate([1, 0, 0], x_r)
            .rotate([0, 1, 0], y_r)
            .rotate([0, 0, 1], z_r)
            .scale(s)
        )

        updated_emitters = {}

        for name, light in emitters.items():
            idx = int(name.split("_")[1])
            face = SceneUtils.idx_to_face(idx)
            orig_pos = light["position"]
            new_pos = transform @ mi.ScalarPoint3f(orig_pos)

            if face in faces_on: 
                updated_emitters[name] = {
                    **light,
                    "position": new_pos
                }
            else:
                updated_emitters[name] = {
                    **light,
                    "position": new_pos,
                    "intensity": {
                        "type": "rgb",
                        "value": [0, 0, 0]  # turn off the light
                    }
                }

        return updated_emitters

    @staticmethod
    def idx_to_face(idx):
        if idx < 150:
            return "left"
        elif idx < 300:
            return "top"
        elif idx < 450:
            return "back"
        elif idx < 600:
            return "right"
        else:
            return None

    @staticmethod
    def add_checkerboard_to_scene_dict(scene_dict):
        scene_dict.update({
            "checkerboard": {
        "type": "rectangle",
        "to_world": mi.ScalarTransform4f()
            .translate([0, 0, 0])      # Place it on the ground
            .rotate([1, 0, 0], -90)    # Lie flat on XZ
            .scale([0.1, 0.1, 1.0]),  # 20 cm × 20 cm plane
        "bsdf": {
            "type": "diffuse",
            "reflectance": {
                "type": "checkerboard",
                "color0": { "type": "rgb", "value": [1,1,1] },
                "color1": { "type": "rgb", "value": [0,0,0] },
                "to_uv": mi.ScalarTransform4f()
                    .scale([10.0, 10.0, 1.0])  # 10 checks ⇒ 2 cm each
            }
        }
    
        }})

        return scene_dict
    
    @staticmethod
    def get_mask(img1, img2, threshold=30):
        diff = cv2.absdiff(img1, img2)
        diff = cv2.cvtColor(diff, cv2.COLOR_BGR2GRAY)
        mask = cv2.threshold(diff, threshold, 255, cv2.THRESH_BINARY)[1]
        mask = cv2.cvtColor(mask, cv2.COLOR_GRAY2BGR)

        return mask

class ConfigUtils:
    """
    Utility class for loading, getting, setting, and saving configuration
    stored in a nested JSON structure. Automatically saves on each set operation.
    """
    def __init__(self, path):
        """Initialize with the file path and load the JSON data."""
        self.path = path
        self.data = self._load_json(path)

    def _load_json(self, path):
        """Load JSON from the given file path."""
        with open(path, 'r') as f:
            return json.load(f)

    def save(self, path=None):
        """Save the current data back to file (indent=4)."""
        target = path if path else self.path
        with open(target, 'w') as f:
            json.dump(self.data, f, indent=4)

    def get_value(self, path):
        """
        Get a nested value by key path.
          path: either "a.b.c" or ["a","b","c"]
        """
        keys = path.split('.') if isinstance(path, str) else path
        cur = self.data
        for key in keys:
            cur = cur[key]
        return cur

    def set_value(self, path, value):
        """
        Set a nested value by key path and immediately save file.
          path: either "a.b.c" or ["a","b","c"]
        """
        keys = path.split('.') if isinstance(path, str) else path
        cur = self.data
        for key in keys[:-1]:
            cur = cur[key]
        cur[keys[-1]] = value
        # auto-save after set
        self.save()




    # Top-level convenience methods

    # calibration_idx
    def get_calibration_idx(self):
        return self.get_value("calibration_idx")

    def set_calibration_idx(self, idx):
        self.set_value("calibration_idx", idx)



    # scene_calibration_params (raw dict of JSON-strings)
    def get_scene_param(self, param):
        raw = self.get_value(f"scene_calibration_params.{param}")
        return json.loads(raw)

    def set_scene_param(self, param, vals):
        self.set_value(f"scene_calibration_params.{param}", json.dumps(vals))

    def get_scene_calibration_params(self):
        """Return the raw scene_calibration_params dict (values are JSON-strings)."""
        return self.get_value("scene_calibration_params")

    def set_scene_calibration_params(self, raw_mapping):
        """Replace the raw scene_calibration_params dict and save."""
        # raw_mapping should be a dict of strings (JSON-strings)
        self.set_value("scene_calibration_params", raw_mapping)




    # camera_calibration_params (raw dict)
    def get_camera_param(self, param):
        raw = self.get_value(f"camera_calibration_params.{param}")
        try:
            return json.loads(raw)
        except (TypeError, json.JSONDecodeError):
            return raw

    def set_camera_param(self, param, vals):
        val = json.dumps(vals) if not isinstance(vals, str) else vals
        self.set_value(f"camera_calibration_params.{param}", val)

    def get_camera_calibration_params(self):
        """Return the raw camera_calibration_params dict (values are strings)."""
        return self.get_value("camera_calibration_params")

    def set_camera_calibration_params(self, raw_mapping):
        """Replace the raw camera_calibration_params dict and save."""
        # raw_mapping should be a dict of strings
        self.data["camera_calibration_params"] = raw_mapping

        # 2) save only to your original path
        self.save()



    # hdri_mapping utilities
    def get_hdri_mapping(self):
        """Return the entire hdri_mapping object."""
        try:
            return self.get_value("hdri_mapping")
        except KeyError:
            return {}

    def set_hdri_mapping(self, mapping):
        """Replace the entire hdri_mapping object and save."""
        self.data["hdri_mapping"] = mapping

        # 2) save only to your original path
        self.save()

    # # individual light helpers (optional)
    # def get_light_rgb(self, light):
    #     """Get RGB list for a specific light (e.g., 'light_3')."""
    #     return self.get_value(f"hdri_mapping.{light}.rgb")

    # def set_light_rgb(self, light, rgb):
    #     """Set RGB list for a specific light and save."""
    #     self.set_value(f"hdri_mapping.{light}.rgb", rgb)
