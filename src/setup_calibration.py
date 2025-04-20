import os
from pathlib import Path
import mitsuba as mi
import matplotlib.pyplot as plt
import numpy as np
import time
import drjit as dr
import json
import cv2 
from Utils import SceneUtils


mi.set_variant('llvm_ad_rgb')
class SetupCalibration:

	FILE_TYPE = 'combined.jpg'
	SPP = 2
	LIGHT_SETUP_FILE = 'results/light_setup.json'
	CAMERA_SETUP_FILE = 'results/camera_setup.json'

	@staticmethod
	def open_light_parameters(file_path):

		with open(file_path) as f:
			params = json.load(f)
			params['translation'] = mi.Vector3f(*eval(params['translation']))
			params['scale'] = mi.Float(eval(params['scale']))
			params['roll'] = mi.Float(eval(params['roll']))
			params['pitch'] = mi.Float(eval(params['pitch']))
			params['yaw'] = mi.Float(eval(params['yaw']))

		return params
	  
	@staticmethod
	def write_parameters(params, file_path):
		for k,v in params.items():
			params[k] = str(v)
		with open(file_path, 'w') as f:
			json.dump(params, f)
		

	@staticmethod
	def show_results(init_virtual_render, virtual_render, picture, loss_hist, file_name):

		fig, axs = plt.subplots(2, 2, figsize=(10, 10))

		axs[0][0].plot(loss_hist)
		axs[0][0].set_xlabel('iteration')
		axs[0][0].set_ylabel('Loss')
		axs[0][0].set_title(f'Parameter error plot')

		axs[0][1].imshow(mi.util.convert_to_bitmap(init_virtual_render))
		axs[0][1].axis('off')
		axs[0][1].set_title('Initial Image')

		axs[1][0].imshow(mi.util.convert_to_bitmap(virtual_render))
		axs[1][0].axis('off')
		axs[1][0].set_title('Optimized image')

		axs[1][1].imshow(mi.util.convert_to_bitmap(picture))
		axs[1][1].axis('off')
		axs[1][1].set_title('Reference Image')
		plt.show()
		plt.savefig(f'figures/{file_name}.png')

	@staticmethod
	def get_emitters(config):
     
		# 10 x 15 = 150 lights per face
		left_pos  = SceneUtils.light_grid("left",  13, 13, -4.5)  
		top_pos   = SceneUtils.light_grid("top",   13, 13,  4.5)   
		back_pos  = SceneUtils.light_grid("back",  13, 13, -4.5)  
		right_pos = SceneUtils.light_grid("right", 13, 13,  4.5)   

		print(len(left_pos) , len(top_pos)  , len(back_pos) , len(right_pos))
		# all_pos = top_pos + back_pos + left_pos + right_pos
		all_pos = left_pos + top_pos + back_pos + right_pos


		num_emitters = len(all_pos)
		print(f"Number of emitters: {num_emitters}")
		emitters = {}

		for i, (face, pos) in enumerate(all_pos):
			color = SetupCalibration.get_light_color(face, config)
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
	def get_light_color(face, config_name):
		with open(SetupCalibration.COLOR_CONFIGS_FILE) as f:
			color_configs = json.load(f)

		if config_name not in color_configs:
			raise ValueError(f"Configuration '{config_name}' not found in color_configs.json")
		config = color_configs[config_name]

		color = config.get(face, [0, 0, 0])

		return color

	@staticmethod
	def initialize_virtual_scene(misalign=False):

		# Initialize scene
		scene_dict = SceneUtils.get_base_scene_dict()
		scene_dict = SceneUtils.add_checkerboard_to_scene_dict(scene_dict)


		configs = json.load(open(SetupCalibration.COLOR_CONFIGS_FILE))
		print(configs.keys())

		# 10 x 15 = 150 lights per face
		left_pos  = SceneUtils.light_grid("left",  13, 13, -4.5)  
		top_pos   = SceneUtils.light_grid("top",   13, 13,  4.5)   
		back_pos  = SceneUtils.light_grid("back",  13, 13, -4.5)  
		right_pos = SceneUtils.light_grid("right", 13, 13,  4.5)   

		print(len(left_pos) , len(top_pos)  , len(back_pos) , len(right_pos))
		all_pos = left_pos + top_pos + back_pos + right_pos


		num_emitters = len(all_pos)
		print(f"Number of emitters: {num_emitters}")
		emitters = {}

		config = "RGB"
		for i, (face, pos) in enumerate(all_pos):
			color = SetupCalibration.get_light_color(face, config)
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

		if misalign:
			# Build transformation
			T = (
				mi.Transform4f()
				.translate([0.5,0.5,0])
				.rotate([1, 0, 0], 0.2)
				.rotate([0, 1, 0], 1)
				.rotate([0, 0, 1], 1.2)
				.scale(1.01)
			)

			# Misalign virtual scene for testing
			initial_light_positions = [mi.Point3f(virtual_params[f'light_{i}.position']) for i in range(len(emitters))]
			for i in range(len(emitters)):
				virtual_params[f'light_{i}.position'] = T @ initial_light_positions[i] 
				virtual_params.update()

		initial_light_positions = [mi.Point3f(virtual_params[f'light_{i}.position']) for i in range(len(emitters))]
		return virtual_scene, scene_dict, initial_light_positions 

	@staticmethod
	def optimize_camera(calibration_images_folder):

		virtual_scene, scene_dict, _ = SetupCalibration.initialize_virtual_scene()

		print('Initializing optimizer...')

		virtual_scene_params = mi.traverse(virtual_scene)
		opt = mi.ad.Adam(
			lr=0.1,
			mask_updates=True
		)
		

		opt['translation'] =  mi.Vector3f([2,19,56])
		opt["sensor.x_fov"] = mi.Float(30)

		# Use the Plane Sweep Method
		# Elect depth candidates
		loss_hist = []
		virtual_render = None
		loss = None

		file = next(Path(calibration_images_folder).glob(f'*{SetupCalibration.FILE_TYPE}'))
		picture = cv2.imread(str(file))
		virtual_scene_params.update(SetupCalibration.get_emitters('WHITE'))
		init_virtual_render = mi.render(virtual_scene, virtual_scene_params, spp=SetupCalibration.SPP)

		# Mask the object
		calib = os.path.join(calibration_images_folder, 'mask_calibration.jpg')
		blank = os.path.join(calibration_images_folder, 'mask_blank.jpg')

		img_empty = cv2.imread(blank)
		img_obj = cv2.imread(calib)

		mask = SceneUtils.get_mask(img_empty, img_obj)
		mask = cv2.cvtColor(mask, cv2.COLOR_BGR2GRAY)
		mask = np.alltrue(mask != [0, 0, 0], axis=2)

		picture = cv2.bitwise_and(picture, picture, mask=mask)
		#picture = cv2.cvtColor(picture, cv2.COLOR_BGR2GRAY)
		#compare_scenes(picture, init_virtual_render, 'camera_calibration')
			
		initial_to_world = mi.Transform4f(virtual_scene_params["sensor.to_world"])

		# TEST 
		picture = cv2.cvtColor(picture, cv2.COLOR_BGR2GRAY)
		thresh = cv2.threshold(picture, 127, 255, cv2.THRESH_BINARY)[1]
		contours, _ = cv2.findContours(thresh, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
		
		reference_area = np.mean([cv2.contourArea(contour) for contour in contours])

		# Optimization Loop
		for epoch in range(100):

			print('Epoch: ', epoch)

			# Apply clipping
			translation_val = dr.clip(opt['translation'], -50, 50)
			fov_val = dr.clip(opt['sensor.x_fov'], 0.0, 50)

		

			opt['translation'] = translation_val
			opt['sensor.x_fov'] = fov_val

			T = (
				mi.Transform4f()
				.translate(opt['translation'])
			)


			print(opt['translation'])
			# # Apply change to scene
			virtual_scene_params["sensor.to_world"] = T @ initial_to_world
			virtual_scene_params["sensor.x_fov"] = opt["sensor.x_fov"] 
			virtual_scene_params.update()

			virtual_render = mi.render(virtual_scene, virtual_scene_params, spp=SetupCalibration.SPP)
			

			# TODO: Test code
			# virtual_render = cv2.cvtColor(np.array(virtual_render), cv2.COLOR_BGR2GRAY)
			# thresh = cv2.threshold(virtual_render, 127, 255, cv2.THRESH_BINARY)[1]
			# contours, _ = cv2.findContours(thresh, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
			# print(np.mean([cv2.contourArea(contour) for contour in contours]))
			
			loss = dr.mean(dr.square(virtual_render-picture))
			dr.backward(loss)
			opt.step()

			loss_hist.append(loss.array[0])



		SetupCalibration.show_results(init_virtual_render, virtual_render, picture, loss_hist, 'camera_optimization')
		SetupCalibration.write_parameters(opt, SetupCalibration.CAMERA_SETUP_FILE)
		return opt



	@staticmethod
	def optimize_lights(calibration_images_folder, results_path):

		virtual_scene, scene_dict, initial_light_positions = SetupCalibration.initialize_virtual_scene()

		print('Initializing optimizer...')

		results = []
		
		# Initialize Adam optimizer
		virtual_scene_params = mi.traverse(virtual_scene)
		opt = mi.ad.Adam(
			lr=0.025,
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

		# Convert to boolean array 
		mask = cv2.cvtColor(mask, cv2.COLOR_BGR2GRAY)
		mask = mask.astype(bool)
		
		for config_file in Path(calibration_images_folder).glob(f'CMYK*{SetupCalibration.FILE_TYPE}'):

			config, face = config_file.stem.split('_')

			# Update emitters based on the configuration used for the calibration image
			emitters = SetupCalibration.get_emitters(config)
			if face == 'combined':
				emitters = SceneUtils.update_emitters(emitters, faces_on=[face])
			else:
				emitters = SceneUtils.update_emitters(emitters)

			scene_dict.update(emitters)

			# Load new scene
			virtual_scene = mi.load_dict(scene_dict)
			virtual_scene_params = mi.traverse(virtual_scene)

			# TODO: Use camera optimization
			virtual_scene_params["sensor.to_world"] = mi.ScalarTransform4f().look_at(
				origin=[2,19,56],
				target=[0,0,0],
				up=[0,1,0],
			)
			virtual_scene_params.update()

			# Use a new optimization for each calibration iamge
			for key in opt.keys():
				opt.reset(key)
			
			# Grab reference image
			picture = cv2.imread(str(config_file))
			picture[~mask] = (0,0,0)

			init_virtual_render = mi.render(virtual_scene, virtual_scene_params, spp=SetupCalibration.SPP)

			loss_hist = []
			virtual_render = None
			loss = None

			# Optimization Loop
			for epoch in range(10):

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

				# Apply change to scene
				for i in range(len(emitters)):
					virtual_scene_params[f'light_{i}.position'] = T @ initial_light_positions[i] 
				virtual_scene_params.update()

				virtual_render = mi.render(virtual_scene, virtual_scene_params, spp=SetupCalibration.SPP)
				
				# Backpropagate and take a step
				loss = dr.mean(dr.sqr(virtual_render-picture))
				dr.backward(loss)
				opt.step()

				print(loss)
				loss_hist.append(loss.array[0])

			SetupCalibration.show_results(init_virtual_render, virtual_render, picture, loss_hist, f'{config_file.name}_results')

			result = {
				'scale' : opt['scale'],
				'translation' : opt['translation'],
				'roll' : opt['roll'],
				'pitch' : opt['pitch'],
				'yaw' : opt['yaw'],
			}
			results.append((result, loss))
		#compare_scenes(picture, virtual_render)

		# Choose the parameters with the best loss 
		params, loss = sorted(results, key=lambda x: x[1])[0]

		SetupCalibration.write_parameters(params, results_path)
		return params
	
class TestSetupCalibration:

	def test_light_optimizer():
		virtual_scene, scene_dict, initial_light_positions = SetupCalibration.initialize_virtual_scene()

		virtual_params = mi.traverse(virtual_scene)

		# Build transformation
		T = (
			mi.Transform4f()
			.translate([0.5,0.5,0])
			.rotate([1, 0, 0], 0.2)
			.rotate([0, 1, 0], 1)
			.rotate([0, 0, 1], 1.2)
			.scale(1.01)
		)

		# Misalign virtual scene for testing
		initial_light_positions = [mi.Point3f(virtual_params[f'light_{i}.position']) for i in range(len(emitters))]
		for i in range(len(emitters)):
			virtual_params[f'light_{i}.position'] = T @ initial_light_positions[i] 
			virtual_params.update()

		initial_light_positions = [mi.Point3f(virtual_params[f'light_{i}.position']) for i in range(len(emitters))]

     
    
if __name__ == '__main__':
	#SetupCalibration.optimize_lights()
	SetupCalibration.optimize_camera()