import mitsuba as mi
import matplotlib.pyplot as plt
import numpy as np
import drjit as dr
import json
import time

mi.set_variant('llvm_ad_rgb')


def light_grid(face, n1, n2, const_val, scale=1.0):
    positions = []
    half = scale / 2
    if face == "top":
        xs = np.linspace(-half, half, n1)
        zs = np.linspace(-half, half, n2)
        for x in xs:
            for z in zs:
                positions.append((face, [x, const_val, z]))
    elif face == "back":
        xs = np.linspace(-half, half, n1)
        ys = np.linspace(-half, half, n2)
        for x in xs:
            for y in ys:
                positions.append((face, [x, y, const_val]))
    elif face == "left" or face == "right":
        ys = np.linspace(-half, half, n1)
        zs = np.linspace(-half, half, n2)
        for y in ys:
            for z in zs:
                positions.append((face, [const_val, y, z]))
    return positions


def build_base_scene(emitters):
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

    scene_dict.update(emitters)
    scene = mi.load_dict(scene_dict)

    return scene

def get_reference_hdri_scene(hdri_path, spp=8, hide_hdri=True):
    hdri = mi.Bitmap(hdri_path).convert(
        mi.Bitmap.PixelFormat.RGB,
        mi.Struct.Type.Float32
    )

    scene_dict = {
        "type": "scene",
        "integrator": {
            "type": "path",
            "hide_emitters": hide_hdri
        },
        "sensor": {
            "type": "perspective",
            "sampler": {"type": "independent", "sample_count": spp},
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
            "type": "envmap",
            "bitmap": hdri,
            "scale": 1.0
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
                    "color0": { "type": "rgb", "value": [1, 1, 1] },
                    "color1": { "type": "rgb", "value": [0, 0, 0] },
                    "to_uv": mi.ScalarTransform4f().scale([10.0, 10.0, 1.0])
                }
            }
        }
    }

    scene = mi.load_dict(scene_dict)

    return scene

def compare_scenes(ref, render):
    fig, ax = plt.subplots(1, 2, figsize=(10, 4))
    ax[0].imshow(mi.util.convert_to_bitmap(ref))
    ax[0].set_title("Reference (HDRI)")
    ax[0].axis('off')
    ax[1].imshow(mi.util.convert_to_bitmap(render))
    ax[1].set_title("Emitter Render")
    ax[1].axis('off')
    plt.show()



def optimize_light_intensities(scene, emitters, reference_scene, n_epochs=50, spp=8):

    n_epochs = 10    # reduced for faster testing
    params = mi.traverse(scene)
    reference = mi.render(reference_scene, params, spp=spp)

    opt = mi.ad.Adam(lr=0.01)

    for i in range(len(emitters)):
        init_rgb = dr.detach(params[f'light_{i}.intensity.value'])
        opt[f'light_{i}_rgb'] = mi.Color3f(init_rgb)
        params[f'light_{i}.intensity.value'] = opt[f'light_{i}_rgb']

    loss_hist = []

    for epoch in range(n_epochs):
        for i in range(len(emitters)):
            opt[f'light_{i}_rgb'] = dr.clip(opt[f'light_{i}_rgb'], 0.0, 1.0)

        params.update(opt)
        render = mi.render(scene, params, spp=spp)
        loss = dr.mean(dr.square(render - reference))

        dr.backward(loss)
        opt.step()
        loss_hist.append(loss.array[0])
        print(f"Epoch {epoch:02d}: Loss = {loss.array[0]:.6f}")

    final_render = mi.render(scene, params, spp=16)
    compare_scenes(reference, final_render)

    optimized_colors = {
        f'light_{i}': opt[f'light_{i}_rgb'] for i in range(len(emitters))
    }

    return optimized_colors, loss_hist


if __name__ == '__main__':
    mi.set_variant('llvm_ad_rgb')

    reference = get_reference_hdri_scene("../sample_hdri.exr", spp=8)

    scale = 0.28
    CONST = (scale / 2) + (scale / 5)
    left  = light_grid("left",  10, 15, -CONST, scale)
    top   = light_grid("top",   10, 15,  CONST, scale)
    back  = light_grid("back",  10, 15, -CONST, scale)
    right = light_grid("right", 10, 15,  CONST, scale)
    all_pos = left + top + back + right

    color_configs = json.load(open("color_configs.json"))
    CONFIG = "RGB"

    emitters = {}
    for i, (face, pos) in enumerate(all_pos):
        base_color = color_configs[CONFIG].get(face, [1, 1, 1])
        emitters[f'light_{i}'] = {
            "type": "point",
            "position": pos,
            "intensity": {
                "type": "rgb",
                "value": [0.001 * c for c in base_color]
            }
        }

    base_scene = build_base_scene(emitters) 

    optimized_rgb, loss_history = optimize_light_intensities(base_scene, emitters, reference)
    print("Final loss:", loss_history[-1])
