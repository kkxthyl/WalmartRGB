from sklearn.cluster import MiniBatchKMeans
from scipy.spatial import cKDTree
import mitsuba as mi
import numpy as np
import json
from Utils import ConfigUtils
from setup_calibration import SetupCalibration as SC

class HDRImap(): 

    @staticmethod
    def apply_hdri(emitters, hdri_path, all_pos, light_cfg, hidr_scale_factor, n_clusters=598, scale=0.6, verbose=False):

        if (hdri_path is None):
            raise FileNotFoundError("invalid hdri path")

        hdri = mi.Bitmap(hdri_path).convert(
            mi.Bitmap.PixelFormat.RGB,
            mi.Struct.Type.Float32,
            srgb_gamma=False
        )
        hdri_np = np.array(hdri)
        H, W, _ = hdri_np.shape

        print("Initializing with optimized transform.") if verbose else None
        light_opt = SC.open_light_parameters(light_cfg)
        # update light parameters
        scale = light_opt['scale']
        translation = light_opt['translation']
        roll = light_opt['roll']
        pitch = light_opt['pitch']
        yaw = light_opt['yaw']

        T = (
            mi.Transform4f()
                .translate(mi.Point3f(translation))
                .rotate(mi.Point3f(1, 0, 0), roll)
                .rotate(mi.Point3f(0, 1, 0), pitch)
                .rotate(mi.Point3f(0, 0, 1), yaw)
                .scale(scale)
        )
        print(f"Original positions: {all_pos[:3]}...{all_pos[-1]}") if verbose else None
        transformed_pos = [T @ mi.Point3f(float(pos[0]), float(pos[1]), float(pos[2])) for pos in all_pos]
        print(f"Transformed positions: {transformed_pos[:3]}...{transformed_pos[-1]}") if verbose else None

        # perceived brightness of each pixel in HDRI
        # https://stackoverflow.com/questions/596216/formula-to-determine-perceived-brightness-of-rgb-color
        luminance = (
            0.2126 * hdri_np[:, :, 0] +
            0.7152 * hdri_np[:, :, 1] +
            0.0722 * hdri_np[:, :, 2]
        )

        # hdri lighting is spherical, get pixel directions
        print("Calculating directions.") if verbose else None
        phi = np.linspace(0, 2 * np.pi, W, endpoint=False)
        theta = np.linspace(0, np.pi, H)
        phi_grid, theta_grid = np.meshgrid(phi, theta)

        # https://en.wikipedia.org/wiki/Spherical_coordinate_system
        dirs = np.stack([
            np.sin(theta_grid) * np.sin(phi_grid), 
            np.cos(theta_grid),
            np.sin(theta_grid) * np.cos(phi_grid)
        ], axis=-1)

        dirs_flat = dirs.reshape(-1, 3)
        colors_flat = hdri_np.reshape(-1, 3)
        weights = luminance.reshape(-1)

        valid = weights > 1e-6
        sample_dirs = dirs_flat[valid]
        sample_colors = colors_flat[valid]
        sample_weights = weights[valid]

        # cluster env lighting into 600 lights
        # kmeans = KMeans(n_clusters=n_clusters, random_state=42)
        print("Clustering HDRI light directions weighted by luminance.") if verbose else None
        kmeans = MiniBatchKMeans(n_clusters, random_state=42, batch_size=1000)
        kmeans.fit(sample_dirs, sample_weight=sample_weights)
        cluster_dirs = kmeans.cluster_centers_

        labels = kmeans.labels_
        # cluster_colors = np.zeros((n_clusters, 3))
        n_clusters_actual = kmeans.n_clusters  # may be less than requested if there’s not enough data
        cluster_colors = np.zeros((n_clusters_actual, 3))

        for i in range(n_clusters_actual):
            mask = labels == i
            if np.any(mask):  # cluster got samples
                cluster_colors[i] = np.average(
                    sample_colors[mask],
                    axis=0,
                    weights=sample_weights[mask] + 1e-6
                )
            else:
                cluster_colors[i] = 0  # fallback color for empty cluster

        # emitter_dirs = np.array([np.array(pos)/np.linalg.norm(pos) for pos in all_pos])
        emitter_dirs = np.array([np.array(p).reshape(3) / np.linalg.norm(p) for p in transformed_pos])

        print("Finding nearest emitter to each cluster.") if verbose else None
        tree = cKDTree(emitter_dirs)
        _, nearest_indices = tree.query(cluster_dirs)

        for i in range(len(all_pos)):
            emitters[f"light_{i}"]["intensity"]["value"] = [0.0, 0.0, 0.0]

        from collections import defaultdict
        emitter_colors = defaultdict(list)

        for cluster_idx, emitter_idx in enumerate(nearest_indices):
            emitter_colors[emitter_idx].append(cluster_colors[cluster_idx])

        print("Calculating average color for each emitter.") if verbose else None
        for idx, colors in emitter_colors.items():
            # numPy array for per-channel 
            colors_np = np.array(colors)
            avg_r = np.mean(colors_np[:, 0])
            avg_g = np.mean(colors_np[:, 1])
            avg_b = np.mean(colors_np[:, 2])
            avg_color = np.array([avg_r, avg_g, avg_b])

            # Optional tone mapping
            mapped_color = avg_color / (1 + avg_color)
            # Normalize
            distance_scale = np.linalg.norm(np.array([scale, scale, scale]))
            final_color = (mapped_color * hidr_scale_factor) / distance_scale

            emitters[f"light_{idx}"]["intensity"]["value"] = final_color.tolist()
            
        return emitters
    
    @staticmethod
    def export_hdrimap_to_json(emitters, filename):
        data = {}

        for key, props in emitters.items():
            rgb = props.get("intensity", {}).get("value", [0.0, 0.0, 0.0])
            data[key] = {
                "rgb": [round(v, 6) for v in rgb] 
            }

        out = ConfigUtils(filename)
        out.set_hdri_mapping(data)
        out.save()

        # with open(filename, "w") as f:
        #     ConfigUtils.set_hdri_mapping(self, json.dump(data, f, indent=4))
