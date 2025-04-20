import mitsuba as mi
import matplotlib.pyplot as plt
import drjit as dr
import json
from Utils import SceneUtils as su
from setup_calibration import SetupCalibration as SC
output_dir = "figures"


class HDRIOptimization:

    @staticmethod
    def get_reference_hdri_scene(hdri_path, sample_count=512, hide_hdri=True):

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
                "sampler": {"type": "independent", "sample_count": sample_count},
                "to_world": mi.ScalarTransform4f().look_at(
                    origin=mi.ScalarPoint3f(0, 0.05, 0.35),
                    target=mi.ScalarPoint3f(0, 0, 0),
                    up=mi.ScalarPoint3f(0, 1, 0)
                ),
                "film": {
                    "type": "hdrfilm",
                    # "width": 5184,
                    # "height": 3456,
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
                    .translate(mi.ScalarPoint3f(0, 0, 0))
                    .rotate(mi.ScalarPoint3f(1, 0, 0), -90)
                    .scale(mi.ScalarPoint3f(0.2, 0.2, 1.0)),
                "bsdf": {
                    "type": "diffuse",
                    "reflectance": {
                        "type": "checkerboard",
                        "color0": {"type": "rgb", "value": [1, 1, 1]},
                        "color1": {"type": "rgb", "value": [0, 0, 0]},
                        "to_uv": mi.ScalarTransform4f().scale(mi.ScalarPoint3f(10.0, 10.0, 1.0))
                    }
                }
            }
        }
        scene_dict = su.add_checkerboard_to_scene_dict(scene_dict)
        scene = mi.load_dict(scene_dict)

        return scene

    @staticmethod
    def optimize_light_intensities(scene, emitters, reference_scene, light_cfg, cam_cfg, lr=0.00025, n_epochs=200, spp=16,
                                   patience=5, visualize_steps=False):

        base_params = mi.traverse(scene)
        ref_params = mi.traverse(reference_scene)

        # update sensor parameters
        cam_opt = SC.open_camera_parameters(cam_cfg)

        translation = cam_opt['translation']
        x_fov = cam_opt['sensor.x_fov']

        base_params["sensor.to_world"] = mi.ScalarTransform4f().look_at(
            origin=mi.ScalarPoint3f(*translation),
            target=mi.ScalarPoint3f(0, 0, 0),
            up=mi.ScalarPoint3f(0, 1, 0)
        )
        base_params["sensor.x_fov"] = x_fov
        ref_params["sensor.to_world"] = mi.ScalarTransform4f().look_at(
            origin=mi.ScalarPoint3f(*translation),
            target=mi.ScalarPoint3f(0, 0, 0),
            up=mi.ScalarPoint3f(0, 1, 0)
        )
        ref_params["sensor.x_fov"] = x_fov

        base_params.update()
        ref_params.update()

        reference = mi.render(reference_scene, ref_params, spp=512)
        opt = mi.ad.Adam(lr=lr)
        for i in range(len(emitters)):
            init_rgb = dr.detach(base_params[f'light_{i}.intensity.value'])
            opt[f'light_{i}_rgb'] = mi.Color3f(init_rgb)
            base_params[f'light_{i}.intensity.value'] = opt[f'light_{i}_rgb']

        loss_hist = []
        best_loss = float('inf')
        best_loss_idx = -1
        best_rgb = None
        patience = patience
        wait = 0
        for epoch in range(n_epochs):
            for i in range(len(emitters)):
                opt[f'light_{i}_rgb'] = dr.clip(opt[f'light_{i}_rgb'], 0.0, 1.0)
                base_params[f'light_{i}.intensity.value'] = opt[f'light_{i}_rgb']

            base_params.update(opt)
            render = mi.render(scene, base_params, spp=spp)
            loss = dr.mean(dr.square(render - reference))

            dr.backward(loss)
            opt.step()
            loss_hist.append(loss.array[0])

            if visualize_steps:
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

            print(f"Epoch {epoch:02d}: Loss = {loss.array[0]:.6f}") if visualize_steps else None

            # early stopping
            if loss.array[0] < best_loss - 1e-6:
                best_loss = loss.array[0]
                best_rgb = {i: dr.detach(opt[f'light_{i}_rgb']) for i in range(len(emitters))}
                best_loss_idx = epoch
                wait = 0
            else:
                wait += 1
                if wait >= patience:
                    print(f"Stopped at epoch {epoch} (no improvement for {patience} epochs)")
                    break

        for i in range(len(emitters)):
            base_params[f'light_{i}.intensity.value'] = best_rgb[i]

        base_params.update()
        final_render = mi.render(scene, base_params, spp=512)
        fig, ax = plt.subplots(1, 2, figsize=(10, 4))

        if visualize_steps:
            ax[0].imshow(mi.util.convert_to_bitmap(reference))
            ax[0].set_title("Reference (HDRI)")
            ax[0].axis('off')
            ax[1].imshow(mi.util.convert_to_bitmap(final_render))
            ax[1].set_title(f"Optimized Emitter Render @ Epoch {best_loss_idx:02d}")
            ax[1].axis('off')
            plt.tight_layout()
            plt.pause(3.0)
            plt.close(fig)

        plt.figure(figsize=(10, 4))
        plt.plot(loss_hist, label='Loss', linewidth=2)
        plt.axvline(best_loss_idx, color='red', linestyle='--', label='Best Epoch (Early Stopping)')
        plt.xlim(1, len(loss_hist)-1)
        plt.xlabel('Epoch')
        plt.ylabel('Loss')
        plt.title('HDRI Optimization Loss over Time')
        plt.legend()
        plt.tight_layout()
        plt.savefig(f"{output_dir}/intensity_loss_plot.png", dpi=300)
        if visualize_steps:
            plt.pause(3.0)
        plt.close(fig)

        optimized_colors = {
            i: dr.detach(opt[f'light_{i}_rgb']) for i in range(len(emitters))
        }
        return optimized_colors, loss_hist, best_loss_idx
