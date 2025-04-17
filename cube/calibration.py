import mitsuba as mi
import matplotlib.pyplot as plt
import numpy as np
import colorsys
import time
import drjit as dr
import json
import cv2 


    
start = time.time()

mi.set_variant('llvm_ad_rgb')

def light_grid(face, n1, n2, const_val):
    positions = []
    if face == "top":
        xs = np.linspace(-4, 4, n1)
        zs = np.linspace(-4, 4, n2)
        for x in xs:
            for z in zs:
                positions.append((face, [x, const_val, z]))
    elif face == "back":
        xs = np.linspace(-4, 4, n1)
        ys = np.linspace(-4, 4, n2)
        for x in xs:
            for y in ys:
                positions.append((face, [x, y, const_val]))
    elif face == "left" or face == "right":
        ys = np.linspace(-4, 4, n1)
        zs = np.linspace(-4, 4, n2)
        for y in ys:
            for z in zs:
                positions.append((face, [const_val, y, z]))

    return positions


def get_light_color(face, config_name):
    with open('color_configs.json') as f:
        color_configs = json.load(f)

    if config_name not in color_configs:
        raise ValueError(f"Configuration '{config_name}' not found in color_configs.json")
    config = color_configs[config_name]

    color = config.get(face, [0, 0, 0])

    return color

configs = json.load(open("color_configs.json"))
print(configs.keys())


# 10 x 15 = 150 lights per face
left_pos  = light_grid("left",  10, 15, -4.5)  
top_pos   = light_grid("top",   10, 15,  4.5)   
back_pos  = light_grid("back",  10, 15, -4.5)  
right_pos = light_grid("right", 10, 15,  4.5)   

# all_pos = top_pos + back_pos + left_pos + right_pos
all_pos = left_pos + top_pos + back_pos + right_pos


num_emitters = len(all_pos)
print(f"Number of emitters: {num_emitters}")
emitters = {}

CONFIG = "RGB"

for i, (face, pos) in enumerate(all_pos):
    color = get_light_color(face, CONFIG)
    emitters[f"light_{i}"] = {
        "type": "point",
        "position": pos,
        "intensity": {
            "type": "rgb",
            "value": color
        }
    }
    
    
for key, val in emitters['light_0'].items():
    print( f"{key}: {val}")

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
    
def get_transform(translation, scale, orientation, faces_on = ["left", "top", "back", "right"]):
    x, y, z = translation

    s = scale
    if isinstance(scale, mi.Point1f):
        s = scale[0][0]
    x_r, y_r, z_r = orientation

    transform = (
        mi.Transform4f()
        .translate(translation)
        .rotate([1, 0, 0], x_r)
        .rotate([0, 1, 0], y_r)
        .rotate([0, 0, 1], z_r)
        .scale(s)
    )

    # for light in emitters.values():
    #     orig_pos = light["position"]
    #     new_pos = transform @ mi.Point3f(orig_pos)
    #     light["position"] = new_pos

    # return

    return transform





check_board_scene = {
    "type": "scene",
    "integrator": {"type": "direct_projective"},
    "sensor": {
        "type": "perspective",
        "sampler": {"type": "independent", "sample_count": 512},
        "to_world": mi.ScalarTransform4f().look_at(
            origin=[0, -2, 19], target=[0, -5, 0], up=[0, 1, 0]
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
            .translate([0, -5, 0])
            .rotate([1, 0, 0], -90)
            .scale([8, 8, 1]),
        "bsdf": {
            "type": "diffuse",
            "reflectance": {
                "type": "checkerboard",
                "color0": {"type": "rgb", "value": [1.0, 1.0, 1.0]},
                "color1": {"type": "rgb", "value": [0.0, 0.0, 0.0]},
                "to_uv": mi.ScalarTransform4f().scale(mi.ScalarPoint3f(10, 10, 1))
            }
        }
    }
}

scene_dict = {
    "type": "scene",
    "integrator": {"type": "direct_projective"},
    "sensor": {
        "type": "perspective",
        "sampler": {
            "type": "independent",
            "sample_count": 512
        },
        "to_world": mi.ScalarTransform4f().look_at(
            origin=[0, 0, 18],
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
    "cube-back":{
        "type": "obj",
        "filename": "cube.obj",
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
        "filename": "cube.obj",
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
        "filename": "cube.obj",
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
        "filename": "cube.obj",
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
        "filename": "cube.obj",
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
    },
    "center_sphere": {
        "type": "sphere",
        "to_world": mi.ScalarTransform4f().translate([0, 0, 0]).scale(2),  # Adjust position & size
        "bsdf": {
            "type": "diffuse",
            # "reflectance": {
            #     "type": "rgb",
            #     "value": [0.5, 0.5, 0.5]
            # }
            "reflectance": {
                "type": "checkerboard",
                "color0": {"type": "rgb", "value": [0.8, 0.8, 0.8]},
                "color1": {"type": "rgb", "value": [0.2, 0.2, 0.2]},
                "to_uv": mi.ScalarTransform4f().scale([5, 5, 5])


            }
        }
    }
}



def compare_scenes(real_img, virtual_img):

    #mi.set_variant('scalar_rgb')
    start = time.time()

    f, axarr = plt.subplots(1,2) 

    # use the created array to output your multiple images. In this case I have stacked 4 images vertically
    axarr[0].imshow(mi.util.convert_to_bitmap(real_img))
    axarr[1].imshow(mi.util.convert_to_bitmap(virtual_img))

    print('Comparing virtual and real scenes ({} s)'.format(time.time()-start))
    plt.show()
    #mi.set_variant('llvm_ad_rgb')


def take_picture():
    # TODO: Change lights
    #return mi.Bitmap(np.full((600, 800, 3), 0.5, dtype=np.float32))
    return mi.TensorXf(np.array(mi.Bitmap('output/CMYK.png')))

    
def error_function(image, image_ref):
    return dr.mean(dr.square(image-image_ref))


def track_losses(epochs, losses):

    ####### Matplotlib Interactive mode 
    plt.ion()
    ########### Sub plots ############
    figure, ax = plt.subplots(figsize=(10, 8))
    line, = ax.plot(epochs, losses)
    ############ Title ###############
    plt.title('Vectors', fontsize=20)
    # setting x-axis label and y-axis label
    plt.xlabel('Epoch')
    plt.ylabel('MSE Loss')
    
    return figure, line

def initialize_checker_board_scene():

    virtual_scene = mi.load_dict(check_board_scene)
    virtual_params = mi.traverse(virtual_scene)

    reference_image = mi.render(virtual_scene, virtual_params, spp=8)


    print("Real FOV: ", virtual_params['sensor.x_fov'])
    # Build transformation

    # Misalign virtual scene for testing
    virtual_params['sensor.x_fov'] = 5
    virtual_params.update()

   
    virtual_img = mi.render(virtual_scene, virtual_params, spp=8)
    compare_scenes(reference_image, virtual_img)

    return virtual_scene, reference_image


def initialize_test_scene():

    # Initialize scene
    check_board_scene.update(emitters)
    virtual_scene = mi.load_dict(check_board_scene)
    virtual_params = mi.traverse(virtual_scene)
    initial_light_positions = [virtual_params[f'light_{i}.position'] for i in range(600)]

    reference_image = mi.render(virtual_scene, virtual_params, spp=8)

    # Build transformation
    T = (
        mi.Transform4f()
        .translate([5,0,0])
        .rotate([1, 0, 0], 0)
        .rotate([0, 1, 0], 0)
        .rotate([0, 0, 1], 0)
        .scale(1)
    )

    # Misalign virtual scene for testing
    for i in range(600):
        virtual_params[f'light_{i}.position'] = T @ initial_light_positions[i] 
    virtual_params.update()

   
    virtual_img = mi.render(virtual_scene, virtual_params, spp=8)
    compare_scenes(reference_image, virtual_img)

    initial_light_positions = [mi.Point3f(virtual_params[f'light_{i}.position']) for i in range(600)]
    return virtual_scene, initial_light_positions, reference_image

def test_camera_optimizer():

    virtual_scene, picture = initialize_checker_board_scene()
    print('Initializing optimizer...')

    virtual_scene_params = mi.traverse(virtual_scene)

    import pdb; pdb.set_trace()

    best_depth = 1.0
    best_loss = 1E4
    # Use the Plane Sweep Method
    # Elect depth candidates
    for candidate in np.linspace(20, 40, 50):

        print(f'{candidate=}')

        # Apply change to scene
        virtual_scene_params["sensor.x_fov"] = mi.Float(candidate)
        virtual_scene_params.update()

        virtual_render = mi.render(virtual_scene, virtual_scene_params, spp=8)

        loss = error_function(virtual_render, picture)
        
        if loss < best_loss:
            best_loss = loss
            best_depth = candidate
            print(best_depth) 


        print('Loss: ', loss)

    print(best_depth, best_loss)
    virtual_scene_params["sensor.x_fov"] = best_depth
    virtual_scene_params.update()
    virtual_render = mi.render(virtual_scene, virtual_scene_params, spp=8)
    compare_scenes(picture, virtual_render)

def test_light_optimizer():

    virtual_scene, initial_light_positions, picture = initialize_test_scene()

    print('Initializing optimizer...')

    virtual_scene_params = mi.traverse(virtual_scene)

    opt = mi.ad.SGD(
        lr=0.01,
        #mask_updates=True
    )
    
    opt['translation'] =  mi.Vector3f([1.0,0.0,0.0])
    dr.enable_grad(opt['translation'])
    # opt['roll'] =  mi.Float(0.0)
    # opt['pitch'] =  mi.Float(0.0)
    # opt['yaw'] =  mi.Float(0.0)
    # opt['scale'] =  mi.Float(1.0)

    import pdb; pdb.set_trace()
    # Build transformation
    T = (
        mi.Transform4f()
        .translate(opt['translation'])
        # .rotate([1, 0, 0], opt['roll'])
        # .rotate([0, 1, 0], opt['pitch'])
        # .rotate([0, 0, 1], opt['yaw'])
        # .scale(opt['scale'])
    )

    # Apply change to scene
    for i in range(600):
        virtual_scene_params[f'light_{i}.position'] = T @ initial_light_positions[i] 
    virtual_scene_params.update()

    init_virtual_render = mi.render(virtual_scene, virtual_scene_params, spp=8)

    print(dr.grad(opt['translation']))

    loss_hist = []
    # Apply transform to each light
    for light_setup in range(1):
        
        #picture = take_picture()

        #figure, line = track_losses(epochs, losses)
        # Optimization Loop
        for epoch in range(50):

            print('Epoch: ', epoch)

            # Apply clipping
            # scale_val = dr.clip(opt['scale'], 0.1, 8.0)
            # translation_val = dr.clip(opt['translation'], [0.0,0.0,0.0], [1.0,1.0,1.0])
            # roll_val = dr.clip(opt['roll'], [0.0], [180.0])
            # pitch_val = dr.clip(opt['pitch'], [0.0], [180.0])
            # yaw_val = dr.clip(opt['yaw'], [0.0], [180.0])

            # opt['scale'] = scale_val
            # opt['translation'] = translation_val
            # print(opt['translation'])
            # opt['roll'] = roll_val
            # opt['pitch'] = pitch_val
            # opt['yaw'] = yaw_val


            # print(opt['scale'])
            # print(opt['roll'])
            # print(opt['pitch'])
            # print(opt['yaw'])

            # Build transformation
            T = (
                mi.Transform4f()
                .translate(opt['translation'])
                # .rotate([1, 0, 0], opt['roll'])
                # .rotate([0, 1, 0], opt['pitch'])
                # .rotate([0, 0, 1], opt['yaw'])
                # .scale(opt['scale'])
            )

            # Apply change to scene
            for i in range(600):
                virtual_scene_params[f'light_{i}.position'] = T @ initial_light_positions[i] 
            virtual_scene_params.update()

            print(initial_light_positions[0])
            print(virtual_scene_params[f'light_{i}.position'])

            virtual_render = mi.render(virtual_scene, virtual_scene_params, seed=epoch, spp=8)
            
            if epoch % 5 == 0:
                compare_scenes(picture, virtual_render)

            loss = error_function(virtual_render, picture)
            dr.backward(loss)
            opt.step()
            print(opt['translation'])


            print('Loss: ', loss)
            loss_hist.append(loss.array[0])
            

    #compare_scenes(picture, virtual_render)

    fig, axs = plt.subplots(2, 2, figsize=(10, 10))

    axs[0][0].plot(loss_hist)
    axs[0][0].set_xlabel('iteration')
    axs[0][0].set_ylabel('Loss')
    axs[0][0].set_title('Parameter error plot')

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

    #parameters = sorted(results, key=lambda x: x[0])[0][1]
    # OR take the average
    #parameters = next(sorted(results, key=lambda x: x[0]))[1]


if __name__ == '__main__':

    test_light_optimizer()
    #test_camera_optimizer()

    print(time.time()-start, "s")




    # camera parameters TODO: should be a separate optimization
    # opt['angle'] =  mi.Point3f(0.0,0.0,0.0)
    # opt['translation'] =  mi.Point1f(1.0)
