import mitsuba as mi
import matplotlib.pyplot as plt
import numpy as np
import drjit as dr
import json

class HDRIOptimization:

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

    @staticmethod
    def optimize_light_intensities(scene, emitters, reference_scene, lr=0.00025, n_epochs=200, spp=24):

        params = mi.traverse(scene)
        reference = mi.render(reference_scene, params, spp=spp)
        opt = mi.ad.Adam(lr=lr)
        for i in range(len(emitters)):
            init_rgb = dr.detach(params[f'light_{i}.intensity.value'])
            opt[f'light_{i}_rgb'] = mi.Color3f(init_rgb)
            params[f'light_{i}.intensity.value'] = opt[f'light_{i}_rgb']

        loss_hist = []
        best_loss = float('inf')
        best_rgb = None
        patience = 5
        wait = 0
        for epoch in range(n_epochs):
            for i in range(len(emitters)):
                opt[f'light_{i}_rgb'] = dr.clip(opt[f'light_{i}_rgb'], 0.0, 1.0)
                params[f'light_{i}.intensity.value'] = opt[f'light_{i}_rgb']

            params.update(opt)
            render = mi.render(scene, params, spp=spp)
            loss = dr.mean(dr.square(render - reference))

            dr.backward(loss)
            opt.step()
            loss_hist.append(loss.array[0])

            # early stopping
            if loss.array[0] < best_loss - 1e-6:
                best_loss = loss.array[0]
                best_rgb = {i: dr.detach(opt[f'light_{i}_rgb']) for i in range(len(emitters))}
                wait = 0
            else:
                wait += 1
                if wait >= patience:
                    print(f"Early stopping at epoch {epoch} (no improvement for {patience} epochs)")
                    break

            print(f"Epoch {epoch:02d}: Loss = {loss.array[0]:.6f}")

            # visualization
            fig, ax = plt.subplots(1, 2, figsize=(10, 4))
            ax[0].imshow(mi.util.convert_to_bitmap(reference))
            ax[0].set_title("Reference (HDRI)")
            ax[0].axis('off')
            ax[1].imshow(mi.util.convert_to_bitmap(render))
            ax[1].set_title(f"Render Epoch {epoch}")
            ax[1].axis('off')
            plt.tight_layout()
            plt.pause(0.08)
            plt.close(fig)


        for i in range(len(emitters)):
            params[f'light_{i}.intensity.value'] = best_rgb[i]

        params.update()
        final_render = mi.render(scene, params, spp=512)
        fig, ax = plt.subplots(1, 2, figsize=(10, 4))
        ax[0].imshow(mi.util.convert_to_bitmap(reference))
        ax[0].set_title("Reference (HDRI)")
        ax[0].axis('off')
        ax[1].imshow(mi.util.convert_to_bitmap(final_render))
        ax[1].set_title("Optimized Emitter Render")
        ax[1].axis('off')
        plt.show()

        optimized_colors = {
        i: dr.detach(opt[f'light_{i}_rgb']) for i in range(len(emitters))
        }


        return optimized_colors, best_loss