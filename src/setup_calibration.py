import os
from pathlib import Path
import mitsuba as mi
import matplotlib.pyplot as plt
import numpy as np
import drjit as dr
import json
import cv2
from Configs import Configs as cf
from Utils import SceneUtils
from Utils import ConfigUtils

class SetupCalibration:

	FILE_TYPE = 'jpg'
	SPP = 2
	LIGHT_SETUP_FILE = 'data/light_setup.json'
	CAMERA_SETUP_FILE = 'data/camera_setup.json'
	MASK_FULL_FILE = 'mask_obj.jpg'
	MASK_EMPTY_FILE = 'mask_no_obj.jpg'
	CAMERA_LR = 0.3
	LIGHT_LR = 0.03

	@staticmethod
	def open_light_parameters(file_path):

		cu = ConfigUtils(file_path)
		params = cu.get_scene_calibration_params()

		params['translation'] = mi.Vector3f(*eval(params['translation']))
		params['scale'] = mi.Float(eval(params['scale']))
		params['roll'] = 100*mi.Float(eval(params['roll']))
		params['pitch'] = 100*mi.Float(eval(params['pitch']))
		params['yaw'] = 100*mi.Float(eval(params['yaw']))

		return params

	@staticmethod
	def open_camera_parameters(file_path):

		cu = ConfigUtils(file_path)
		params = cu.get_camera_calibration_params()

		params['translation'] = eval(params['translation'])
		params['sensor.x_fov'] = mi.Float(eval(params['sensor.x_fov']))

		return params

	@staticmethod
	def show_results(init_virtual_render, virtual_render, picture, loss_hist, file_name, learning_rate):

		fig, axs = plt.subplots(2, 2, figsize=(10, 10))

		axs[0][0].plot(loss_hist)
		axs[0][0].set_xlabel('Iteration')
		axs[0][0].set_ylabel('Loss')
		axs[0][0].set_title(f'Parameter error plot (LR={learning_rate})')

		axs[0][1].imshow(mi.util.convert_to_bitmap(init_virtual_render))
		axs[0][1].axis('off')
		axs[0][1].set_title('Initial Image')

		axs[1][0].imshow(mi.util.convert_to_bitmap(virtual_render))
		axs[1][0].axis('off')
		axs[1][0].set_title('Optimized image')

		axs[1][1].imshow(np.array(picture))
		axs[1][1].axis('off')
		axs[1][1].set_title('Reference Image')

		plt.savefig(f'figures/{file_name}.png')

		plt.close(fig)

	@staticmethod
	def get_emitters(all_pos, config, color_configs_file=None):
	
		num_emitters = len(all_pos)
		print(f"Number of emitters: {num_emitters}")
		emitters = {}

		for i, (face, pos) in enumerate(all_pos):
			color = SetupCalibration.get_light_color(face, config, color_configs_file)
			emitters[f"light_{i}"] = {
				"type": "point",
				"position": pos,
				"intensity": {
					"type": "rgb",
					"value": color
				}
			}
	
		return emitters

	
	@staticmethod
	def get_light_color(face, config_name, color_configs_file=None):
		with open(color_configs_file) as f:
			color_configs = json.load(f)

		if config_name not in color_configs:
			raise ValueError(f"Configuration '{config_name}' not found in color_configs.json")
		config = color_configs[config_name]

		color = config.get(face, [0, 0, 0])

		return color

	@staticmethod
	def initialize_virtual_scene(all_pos, color_configs_file):

		# Initialize scene
		scene_dict = SceneUtils.get_base_scene_dict(low_res=True)
		scene_dict = SceneUtils.add_checkerboard_to_scene_dict(scene_dict)

		configs = json.load(open(color_configs_file))
		print(configs.keys())

		num_emitters = len(all_pos)
		print(f"Number of emitters: {num_emitters}")
		emitters = {}

		config = "RGB"
		for i, (face, pos) in enumerate(all_pos):
			color = SetupCalibration.get_light_color(face, config, color_configs_file)
			emitters[f"light_{i}"] = {
				"type": "point",
				"position": pos,
				"intensity": {
					"type": "rgb",
					"value": color
				}
			}

		scene_dict.update(emitters)
		virtual_scene = mi.load_dict(scene_dict)

		virtual_params = mi.traverse(virtual_scene)

		initial_light_positions = [mi.Point3f(virtual_params[f'light_{i}.position']) for i in range(len(emitters))]
		return virtual_scene, scene_dict, initial_light_positions 

	@staticmethod
	def compare_scenes(real_img, virtual_img, file_name):

		f, axarr = plt.subplots(1,2) 

		# use the created array to output your multiple images. In this case I have stacked 4 images vertically
		real = mi.util.convert_to_bitmap(real_img)
		axarr[0].imshow(real)
		bitmap = mi.util.convert_to_bitmap(virtual_img)
		axarr[1].imshow(bitmap)

		# plt.savefig(f'figures/{file_name}.png')
		plt.pause(0.08)
		plt.close(f)

	@staticmethod
	def optimize_camera(emitter_positions, calibration_images_folder, color_configs_file, config_file):

		virtual_scene, _, _ = SetupCalibration.initialize_virtual_scene(emitter_positions, color_configs_file)
		virtual_scene_params = mi.traverse(virtual_scene)

		print('Initializing optimizer...')
		opt = mi.ad.Adam(
			lr=SetupCalibration.CAMERA_LR,
			mask_updates=True
		)

		opt["sensor.x_fov"] = mi.Float(30)
	
		# Grab the white calibration photo for camera alignment
		file = next(Path(calibration_images_folder).glob(f'WHITE*{SetupCalibration.FILE_TYPE}'))
		picture = cv2.imread(str(file))
		picture = cv2.resize(picture, (800,600))

		# Update the virtual scene with the same lighting
		virtual_scene_params.update(SetupCalibration.get_emitters(emitter_positions, 'WHITE', color_configs_file))
		virtual_scene_params.update()
		init_virtual_render = mi.render(virtual_scene, virtual_scene_params, spp=SetupCalibration.SPP)

		# Mask the object
		calib = os.path.join(calibration_images_folder, SetupCalibration.MASK_FULL_FILE)
		blank = os.path.join(calibration_images_folder, SetupCalibration.MASK_EMPTY_FILE)
		img_empty = cv2.imread(blank)
		img_obj = cv2.imread(calib)

		mask = SceneUtils.get_mask(img_empty, img_obj)
		mask = cv2.resize(mask, (800,600))
		mask = cv2.cvtColor(mask, cv2.COLOR_BGR2GRAY)
		mask = mask.astype(bool)
			
		SetupCalibration.compare_scenes(picture, mi.util.convert_to_bitmap(init_virtual_render), 'calib')

		# Nudge the camera around a small cube and choose the translation with the best loss
		best_loss = 1E10
		result = {}
		for i in np.linspace(-0.01, 0.01, 6):
			for j in np.linspace(-0.001, 0.001, 6):
				for k in np.linspace(-0.001, 0.001, 6):

					# Add a small dx, dy, dz to the measured camera position
					translation = cf.BASE_VIEW
					translation[0] += float(i)
					translation[1] += float(i)
					translation[2] += float(k)

					virtual_scene_params["sensor.to_world"] = mi.ScalarTransform4f().look_at(
						origin=translation,
						target=[0, 0, 0],
						up=[0,1,0]
					)
					virtual_scene_params.update()
					virtual_render = mi.render(virtual_scene, virtual_scene_params, spp=SetupCalibration.SPP)

					vrender = np.array(virtual_render)
					loss = np.mean(np.square(vrender-picture))

					if loss < best_loss:
						SetupCalibration.compare_scenes(vrender, picture, str(i))
						best_loss = loss
						print(translation, loss)
						result['translation'] = translation

		# Update scene with the best translation
		virtual_scene_params["sensor.to_world"] = mi.ScalarTransform4f().look_at(
			origin=result['translation'],
			target=mi.ScalarPoint3f(0, 0, 0),
			up=mi.ScalarPoint3f(0,1,0)
		)
		virtual_scene_params.update()
		virtual_render = mi.render(virtual_scene, virtual_scene_params, spp=SetupCalibration.SPP)

		SetupCalibration.compare_scenes(virtual_render, picture, 'sweep')

		loss_hist = []
		virtual_render = None
		loss = None
		best_loss = float('inf')
		patience = 3
		wait=0
		best_fov = None
		best_translation = None

		# Optimization Loop
		for epoch in range(50):

			print(epoch, end='\r')

			# Apply clipping
			fov_val = dr.clip(opt['sensor.x_fov'], 0.0, 50)
			opt['sensor.x_fov'] = fov_val

			virtual_scene_params["sensor.x_fov"] = opt["sensor.x_fov"] 
			virtual_scene_params.update()

			virtual_render = mi.render(virtual_scene, virtual_scene_params, spp=SetupCalibration.SPP)

			# Mask the picture so only the checkerboard is in the scene
			picture[~mask] = (0,0,0)

			# Compute loss and backpropagate
			loss = dr.mean(dr.sqr(virtual_render-picture))
			dr.backward(loss)
			opt.step()

			print(f"Epoch {epoch:02d}: Loss = {loss.array[0]:.6f}")

			# Early stopping
			if loss.array[0] < best_loss - 1e-6:
				best_fov = mi.Float(opt['sensor.x_fov'])
				print(f'{epoch} - {best_fov}, {best_translation}')
				best_loss = loss.array[0]
				wait = 0
			else:
				wait += 1
				if wait >= patience:
					print(f"Stopped at epoch {epoch} (no improvement for {wait} epochs)")
					break

			if epoch % 1 == 0:
				vimg = mi.util.convert_to_bitmap(virtual_render)
				SetupCalibration.compare_scenes(picture, vimg, str(epoch))

			loss_hist.append(loss.array[0])


		result['sensor.x_fov'] = best_fov

		SetupCalibration.show_results(init_virtual_render, virtual_render, picture, loss_hist, 'camera_optimization', SetupCalibration.CAMERA_LR)

		# Write to configuration file
		cu = ConfigUtils(config_file)
		raw = {}
		for k,v in result.items():
			raw[k] = str(v)
		cu.set_camera_calibration_params(raw)
		return result
	

	@staticmethod
	def optimize_lights(emitter_positions, calibration_images_folder, color_configs_file, results_path, camera_parameters, config_output_file):

		virtual_scene, scene_dict, initial_light_positions = SetupCalibration.initialize_virtual_scene(emitter_positions, color_configs_file)

		print('Initializing optimizer...')
		virtual_scene_params = mi.traverse(virtual_scene)
		opt = mi.ad.Adam(
			lr=SetupCalibration.LIGHT_LR,
			mask_updates=True
		)
		
		opt['translation'] =  mi.Vector3f([1.0,0.0,0.0])
		opt['roll'] =  mi.Float(0.0)
		opt['pitch'] =  mi.Float(0.0)
		opt['yaw'] =  mi.Float(0.0)
		opt['scale'] =  mi.Float(1.0)

		# Generate mask to isolate object in the scene
		calib = os.path.join(calibration_images_folder, SetupCalibration.MASK_FULL_FILE)
		blank = os.path.join(calibration_images_folder, SetupCalibration.MASK_EMPTY_FILE)
		img_empty = cv2.imread(blank)
		img_obj = cv2.imread(calib)
		mask = SceneUtils.get_mask(img_empty, img_obj)
		mask = cv2.resize(mask, (800,600))

		# Convert to boolean array 
		mask = cv2.cvtColor(mask, cv2.COLOR_BGR2GRAY)
		mask = mask.astype(bool)
		
		results = []
		for config_file in Path(calibration_images_folder).glob(f'*{SetupCalibration.FILE_TYPE}'):

			# Look only for valid color calibration images of the form {COLOR}_{FACE}
			try:
				config, face = config_file.stem.split('_')
			except ValueError:
				continue

			print(config, face)

			if config == 'mask':
				continue

			# Update emitters based on the configuration used for the calibration image
			emitters = SetupCalibration.get_emitters(emitter_positions, config, color_configs_file)
			if face == 'combined':
				# Turn all faces on 
				emitters = SceneUtils.update_emitters(emitters)
			else:
				emitters = SceneUtils.update_emitters(emitters, faces_on=[face])

			scene_dict.update(emitters)

			# Load new scene
			virtual_scene = mi.load_dict(scene_dict)
			virtual_scene_params = mi.traverse(virtual_scene)

			# Build translation matrix for camera
			T = (
            	mi.Transform4f()
                .translate(mi.Point3f(camera_parameters['translation']))
			)

			# Apply optimized camera parameters
			origin = T@[0, 0.3, 0.35]
			virtual_scene_params["sensor.to_world"] = mi.ScalarTransform4f().look_at(
				origin=[origin[i][0] for i in range(3)],
				target=[0, 0, 0],
				up=[0,1,0]
			)
			virtual_scene_params["sensor.x_fov"] = camera_parameters['sensor.x_fov']
			virtual_scene_params.update()

			# Use a new optimization for each calibration iamge
			for key in opt.keys():
				opt.reset(key)
			
			# Grab reference image
			picture = cv2.imread(str(config_file))
			picture = cv2.resize(picture, (800,600))

			# Mask the object in the scene
			picture[~mask] = (0,0,0)
			picture = picture.astype(np.float32) / 255.0
			picture = mi.TensorXf(picture)

			init_virtual_render = mi.render(virtual_scene, virtual_scene_params, spp=SetupCalibration.SPP)

			loss_hist = []
			virtual_render = None
			loss = None
			best_loss = float('inf')

			patience = 5
			# Optimization Loop
			for epoch in range(50):

				print('Epoch: ', epoch)

				# Apply clipping
				scale_val = dr.clip(opt['scale'], 0.1, 8.0)
				translation_val = dr.clip(opt['translation'], [0.0,0.0,0.0], [20.0,20.0,20.0])
				roll_val = dr.clip(opt['roll'], -0.5, 0.5)
				pitch_val = dr.clip(opt['pitch'], -0.5, 0.5)
				yaw_val = dr.clip(opt['yaw'], -0.5, 0.5)

				opt['scale'] = scale_val
				opt['translation'] = translation_val
				opt['roll'] = roll_val
				opt['pitch'] = pitch_val
				opt['yaw'] = yaw_val

				# Build transformation
				T = (
					mi.Transform4f()
					.translate(opt['translation'])
					.rotate([1, 0, 0], 100*opt['pitch'])
					.rotate([0, 1, 0], 100*opt['yaw'])
					.rotate([0, 0, 1], 100*opt['roll'])
					.scale(opt['scale'])
				)

				# Update all emitters in the scene
				for i in range(len(emitters)):
					virtual_scene_params[f'light_{i}.position'] = T @ initial_light_positions[i] 
				virtual_scene_params.update()

				virtual_render = mi.render(virtual_scene, virtual_scene_params, spp=SetupCalibration.SPP)

				# Backpropagate and take a step
				loss = dr.mean(dr.sqr(virtual_render-mi.TensorXf(picture)))
				dr.backward(loss)
				opt.step()

				# early stopping
				if loss.array[0] < best_loss - 1e-6:
					best_loss = loss.array[0]
					wait = 0
				else:
					wait += 1
					if wait >= patience:
						print(f"Stopped at epoch {epoch} (no improvement for {patience} epochs)")
						break


				print(loss)
				loss_hist.append(loss.array[0])

			print(config_file.name)
			SetupCalibration.show_results(init_virtual_render, virtual_render, picture, loss_hist, f'{config_file.name}_results', SetupCalibration.LIGHT_LR)

			result = {
				'scale' : opt['scale'],
				'translation' : opt['translation'],
				'roll' : opt['roll'],
				'pitch' : opt['pitch'],
				'yaw' : opt['yaw'],
			}
			results.append((result, loss))



		# Choose the parameters with the best loss 
		params, loss = sorted(results, key=lambda x: x[1])[0]
		
		print("CONFIG FILE: ", config_output_file)

		# Write to configuration file
		cu = ConfigUtils(config_output_file)
		for k,v in params.items():
			params[k] = str(v)
		cu.set_scene_calibration_params(params)
		cu.save()
		return params
