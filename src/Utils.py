import mitsuba as mi
import matplotlib.pyplot as plt
import numpy as np

class SceneUtils:

    @staticmethod
    def light_grid(face, n1, n2, const_val, scale=1.0):
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
    def get_cube_path():
        cube_dir = "../assets/cube.obj"
        return cube_dir
    

    @staticmethod
    def get_base_scene_dict():
        scene_dict = {
            "type": "scene",
            "integrator": {"type": "path"},
            "sensor": {
                "type": "perspective",
                "sampler": {"type": "independent", "sample_count": 512},
                "to_world": mi.ScalarTransform4f().look_at(
                    origin=[0, 0.05, 0.35],
                    target=[0, 0, 0],
                    up=[0, 1, 0]
                ),
                "film": {
                    "type": "hdrfilm",
                    "width": 800,
                    "height": 600,
                    "pixel_format": "rgb"
                },
            },
            "env": {
                "type": "constant",
                "radiance": {"type": "rgb", "value": [0.01, 0.01, 0.01]}
            },
            "checkerboard": {
                "type": "rectangle",
                "to_world": mi.ScalarTransform4f()
                    .translate([0, 0, 0])
                    .rotate([1, 0, 0], -90)
                    .scale([0.2, 0.2, 1.0]),
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


    @staticmethod
    def get_scene_dict_empty_cube(HIDE_EMITTERS=True):
        filename = SceneUtils.get_cube_path()
        scene_dict = {
            "type": "scene",
            "integrator": {
                "type": "path", 
                "hide_emitters": HIDE_EMITTERS,},
            "sensor": {
                "type": "perspective",
                "to_world": mi.ScalarTransform4f().look_at(
                    origin=[0, 0.0, 18],
                    target=[0, 0, 0],
                    up=[0, 1, 0]
                ),
                 "sampler": {
                    "type": "independent",
                    "sample_count": 512
                },
                "film": {
                    "type": "hdrfilm",
                    "width": 800,
                    "height": 600,
                    "pixel_format": "rgb"
                },
            },
            "env": {
                "type": "constant",
                "radiance": {"type": "rgb", "value": [0.01, 0.01, 0.01]}
            },
            "cube-back":{
                "type": "obj",
                "filename": filename,
                "to_world": mi.ScalarTransform4f()
                    .translate([0, 0, -10])  
                , 
                "bsdf": {
                    "type": "twosided",
                    "bsdf": {
                        "type": "diffuse",
                        "reflectance": {"type": "rgb", "value": [0.2, 0.2, 0.2]}
                    }
                }
            },

            "cube-top":{
                "type": "obj",
                "filename": filename,
                "to_world": mi.ScalarTransform4f()
                    .translate([0, 10, 0])  
                ,  
                "bsdf": {
                    "type": "twosided",
                    "bsdf": {
                        "type": "diffuse",
                        "reflectance": {"type": "rgb", "value": [0.2, 0.2, 0.2]}
                    }
                }
            }, 
            "cube-left":{
                "type": "obj",
                "filename": filename,
                "to_world": mi.ScalarTransform4f()
                    .translate([10,0, 0]) 
                ,  
                "bsdf": {
                    "type": "twosided",
                    "bsdf": {
                        "type": "diffuse",
                        "reflectance": {"type": "rgb", "value": [0.2, 0.2, 0.2]}
                    }
                }
            }, 
            "cube-right":{
                "type": "obj",
                "filename":filename,
                "to_world": mi.ScalarTransform4f()
                    .translate([-10, 0, 0]) 
                , 
                "bsdf": {
                    "type": "twosided",
                    "bsdf": {
                        "type": "diffuse",
                        "reflectance": {"type": "rgb", "value": [0.2, 0.2, 0.2]}
                    }
                }
            }, 
            "cube-bottom":{
                "type": "obj",
                "filename": filename,
                "to_world": mi.ScalarTransform4f()
                    .translate([0, -10, 0])  
                , 
                "bsdf": {
                    "type": "twosided",
                    "bsdf": {
                        "type": "diffuse",
                        "reflectance": {"type": "rgb", "value": [0.2, 0.2, 0.2]}
                    }
                }
            }
        }

        return scene_dict


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