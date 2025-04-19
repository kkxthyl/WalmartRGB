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

REFERENCE_DIRECTORY = '../calibration_images'
FILE_TYPE = 'combined.jpg'
SPP = 2
COLOR_CONFIGS_FILE = "../cube/color_configs.json"
mi.set_variant('llvm_ad_rgb')



class SetupCalibration:


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
		with open(COLOR_CONFIGS_FILE) as f:
			color_configs = json.load(f)

		if config_name not in color_configs:
			raise ValueError(f"Configuration '{config_name}' not found in color_configs.json")
		config = color_configs[config_name]

		color = config.get(face, [0, 0, 0])

		return color

	@staticmethod
	def __initialize_test_scene(misalign=False):

		# Initialize scene
		scene_dict = SceneUtils.get_base_scene_dict()
		scene_dict = SceneUtils.add_checkerboard_to_scene_dict(scene_dict)


		configs = json.load(open(COLOR_CONFIGS_FILE))
		print(configs.keys())



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
		return virtual_scene, initial_light_positions 

	def test_light_optimizer():

		virtual_scene, initial_light_positions = SetupCalibration.__initialize_test_scene()

		print('Initializing optimizer...')

		results = []
		
		# Apply transform to each light
		
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

		result = {
			'scale' : str(opt['scale'][0]),
			'translation' : str(opt['translation']),
			'roll' : str(opt['roll'][0]),
			'pitch' : str(opt['pitch'][0]),
			'yaw' : str(opt['yaw'][0]),
		}

		for k, v in opt.items():
			print(k, dr.grad(v))
		
		calib = os.path.join(REFERENCE_DIRECTORY, 'mask_calibration.jpg')
		blank = os.path.join(REFERENCE_DIRECTORY, 'mask_blank.jpg')

		img_empty = cv2.imread(blank)
		img_obj = cv2.imread(calib)

		mask = SceneUtils.get_mask(img_empty, img_obj)



		import pdb; pdb.set_trace()
		for config_file in Path(REFERENCE_DIRECTORY).glob(f'CMYK*{FILE_TYPE}'):

			
			# Change the lights to match the real scene
			config, face = config_file.stem.split('_')
			print(config_file, config, face)
			emitters = SetupCalibration.get_emitters(config)
			if face == 'combined':
				emitters = SceneUtils.update_emitters(emitters, faces_on=[face])
			else:
				emitters = SceneUtils.update_emitters(emitters)

			virtual_scene.update(emitters)


			# Load new scene
			virtual_scene = mi.load_dict(virtual_scene)
			virtual_scene_params = mi.traverse(virtual_scene)

			# TODO: Use camera optimization
			virtual_scene_params["sensor.to_world"] = mi.ScalarTransform4f().look_at(
				origin=[2,19,56],
				target=[0,0,0],
				up=[0,1,0],
			)
			virtual_scene_params.update()

			# Using a new optimization for each calibration iamge
			for key in opt.keys():
				opt.reset(key)
			
			picture = cv2.imread(str(config_file))
			picture = cv2.bitwise_and(picture, picture, mask=mask)

			init_virtual_render = mi.render(virtual_scene, virtual_scene_params, spp=SPP)
			#compare_scenes(picture, mi.util.convert_to_bitmap(init_virtual_render), 'config_file_initial')

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


				print(opt['scale'])
				print(opt['translation'])
				print(opt['roll'])
				print(opt['pitch'])
				print(opt['yaw'])

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
				for i in range(600):
					virtual_scene_params[f'light_{i}.position'] = T @ initial_light_positions[i] 
				virtual_scene_params.update()

				virtual_render = mi.render(virtual_scene, virtual_scene_params, spp=SPP)
				
				loss = dr.mean(dr.square(virtual_render-picture))
				dr.backward(loss)
				opt.step()


				print(loss)
				loss_hist.append(loss.array[0])

			print('Showing results!')
			SetupCalibration.show_results(init_virtual_render, virtual_render, picture, loss_hist, f'{config_file.name}_results')

			result = {
				'scale' : opt['scale'],
				'translation' : opt['translation'],
				'roll' : opt['roll'],
				'pitch' : opt['pitch'],
				'yaw' : opt['yaw'],
			}
			results.append((result, loss))
			break
		#compare_scenes(picture, virtual_render)


		params, loss = sorted(results, key=lambda x: x[1])[0]

	#write_parameters(params)
	
if __name__ == '__main__':
	SetupCalibration.test_light_optimizer()