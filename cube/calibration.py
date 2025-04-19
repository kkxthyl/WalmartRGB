from pathlib import Path
import mitsuba as mi
import matplotlib.pyplot as plt
import numpy as np
import time
import drjit as dr
import json
import cv2 

REFERENCE_DIRECTORY = 'output'
FILE_TYPE = 'png'
SPP = 2

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


def get_emitters(config='RGB'):

    num_emitters = len(all_pos)
    print(f"Number of emitters: {num_emitters}")
    emitters = {}

    #CONFIG = "RGB"
    for i, (face, pos) in enumerate(all_pos):
        color = get_light_color(face, config)
        emitters[f"light_{i}"] = {
            "type": "point",
            "position": pos,
            "intensity": {
                "type": "rgb",
                "value": color
            }
        }
        
        
    # for key, val in emitters['light_0'].items():
    #     print( f"{key}: {val}")

    return emitters

    

ref_path = next(Path('output').glob(f'*{FILE_TYPE}'))
ref = cv2.imread(str(ref_path))


check_board_scene = {
    "type": "scene",
    "integrator": {"type": "path"},
    "sensor": {
        "type": "perspective",
        "sampler": {"type": "independent", "sample_count": 512},
        "to_world": mi.ScalarTransform4f().look_at(
            origin=[0, -2, 19], target=[0, -5, 0], up=[0, 1, 0]
        ),
        "film": {
            "type": "hdrfilm",
            "width": ref.shape[1],
            "height": ref.shape[0],
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
    "integrator": {"type": "path"},
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
            "width": ref.shape[1],
            "height": ref.shape[0],
            "pixel_format": "rgb"
        },
    },
    "env": {
        "type": "constant",
        "radiance": {"type": "rgb", "value": [0.01, 0.01, 0.01]}
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


def show_results(init_virtual_render, virtual_render, picture, loss_hist):

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

def compare_scenes(real_img, virtual_img):

    start = time.time()

    f, axarr = plt.subplots(1,2) 

    # use the created array to output your multiple images. In this case I have stacked 4 images vertically
    axarr[0].imshow((real_img))
    axarr[1].imshow(mi.util.convert_to_bitmap(virtual_img))

    print('Comparing virtual and real scenes ({} s)'.format(time.time()-start))
    plt.show()


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

def point_to_list(points, dim=3):
    return [points[i][0] for i in range(3)]

def initialize_checker_board_scene():

    virtual_scene = mi.load_dict(check_board_scene)
    virtual_params = mi.traverse(virtual_scene)

    reference_image = mi.render(virtual_scene, virtual_params, spp=SPP)

    print("Real FOV: ", virtual_params['sensor.x_fov'])
    # Build transformation
    T = (
        mi.Transform4f()
        .translate([0,0,0])
    )

    U = (
        mi.Transform4f()
        .rotate([1, 0, 0], 0)
        .rotate([0, 1, 0], 0)
        .rotate([0, 0, 1], 0)
    )

    # Misalign virtual scene for testing
    virtual_params['sensor.x_fov'] = virtual_params['sensor.x_fov'] *0.9

    virtual_params["sensor.to_world"] = mi.ScalarTransform4f().look_at(
        origin=point_to_list(T@[18,0,0]),
        target=[0, 0, 0],
        up=point_to_list(U@[0,1,0])
    )

    virtual_params.update()

   
    virtual_img = mi.render(virtual_scene, virtual_params, spp=SPP)
    compare_scenes(reference_image, virtual_img)

    return virtual_scene, reference_image


def initialize_test_scene():

    # Initialize scene
    check_board_scene.update(get_emitters())
    virtual_scene = mi.load_dict(check_board_scene)
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
    initial_light_positions = [mi.Point3f(virtual_params[f'light_{i}.position']) for i in range(600)]
    for i in range(600):
        virtual_params[f'light_{i}.position'] = T @ initial_light_positions[i] 
        virtual_params.update()

   
    #virtual_img = mi.render(virtual_scene, virtual_params, spp=SPP)
    #compare_scenes(reference_image, virtual_img)

    initial_light_positions = [mi.Point3f(virtual_params[f'light_{i}.position']) for i in range(600)]
    return virtual_scene, initial_light_positions 

def test_camera_optimizer():

    virtual_scene, picture = initialize_checker_board_scene()
    print('Initializing optimizer...')

    import pdb; pdb.set_trace()
    virtual_scene_params = mi.traverse(virtual_scene)
    opt = mi.ad.Adam(
        lr=0.025,
        mask_updates=True
    )
    
    opt['translation'] =  mi.Vector3f([1.0,0.0,0.0])
    opt['roll'] =  mi.Float(0.0)
    opt['pitch'] =  mi.Float(0.0)
    opt['yaw'] =  mi.Float(0.0)
    opt["sensor.x_fov"] = mi.Float(1.0)

    # Use the Plane Sweep Method
    # Elect depth candidates
    loss_hist = []
    virtual_render = None
    loss = None

    init_virtual_render = mi.render(virtual_scene, virtual_scene_params, spp=SPP)
    # Optimization Loop
    for epoch in range(1):

        print('Epoch: ', epoch)

        # Apply clipping
        translation_val = dr.clip(opt['translation'], [0.0,0.0,0.0], [20.0,20.0,20.0])
        roll_val = dr.clip(opt['roll'], [0.0], [180.0])
        pitch_val = dr.clip(opt['pitch'], [0.0], [180.0])
        yaw_val = dr.clip(opt['yaw'], [0.0], [180.0])
        fov_val = dr.clip(opt['sensor.x_fov'], 0.1, 8.0)

        opt['translation'] = translation_val
        opt['roll'] = roll_val
        opt['pitch'] = pitch_val
        opt['yaw'] = yaw_val
        opt['sensor.x_fov'] = fov_val


        # Build transformation
        T = (
            mi.Transform4f()
            .translate(opt['translation'])
        )

        U = (
            mi.Transform4f()
            .rotate([1, 0, 0], opt['pitch'])
            .rotate([0, 1, 0], opt['yaw'])
            .rotate([0, 0, 1], opt['roll'])
        )

        origin = T @ [0, 0, 18]
        up = U @ [0,1,0]

        virtual_scene_params["sensor.to_world"] = mi.ScalarTransform4f().look_at(
            origin=[origin[i][0] for i in range(3)],
            target=[0, 0, 0],
            up=[up[i][0] for i in range(3)]
        )

        # Apply change to scene
        virtual_scene_params["sensor.x_fov"] = opt["sensor.x_fov"]
        virtual_scene_params.update()

        virtual_render = mi.render(virtual_scene, virtual_scene_params, spp=SPP)
        
        loss = error_function(virtual_render, picture)
        dr.backward(loss)
        opt.step()

        loss_hist.append(loss.array[0])


    show_results(init_virtual_render, virtual_render, picture, loss_hist)

def test_light_optimizer():

    virtual_scene, initial_light_positions = initialize_test_scene()

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

    for config_file in Path('output').glob(f'*{FILE_TYPE}'):

        # Change the lights to match the real scene
        print(config_file)
        config = config_file.name.split('.')[0]
        virtual_scene_params.update(get_emitters(config))

        for key in opt.keys():
            opt.reset(key)
        
        picture = cv2.imread(str(config_file))

        init_virtual_render = mi.render(virtual_scene, virtual_scene_params, spp=SPP)
        compare_scenes(picture, init_virtual_render)

        loss_hist = []
        virtual_render = None
        loss = None

        # Optimization Loop
        for epoch in range(10):

            print('Epoch: ', epoch)

            # Apply clipping
            scale_val = dr.clip(opt['scale'], 0.1, 8.0)
            translation_val = dr.clip(opt['translation'], [0.0,0.0,0.0], [20.0,20.0,20.0])
            roll_val = dr.clip(opt['roll'], [0.0], [180.0])
            pitch_val = dr.clip(opt['pitch'], [0.0], [180.0])
            yaw_val = dr.clip(opt['yaw'], [0.0], [180.0])

            opt['scale'] = scale_val
            opt['translation'] = translation_val
            opt['roll'] = roll_val
            opt['pitch'] = pitch_val
            opt['yaw'] = yaw_val


            import pdb; pdb.set_trace()
            # Build transformation
            T = (
                mi.Transform4f()
                .translate(opt['translation'])
                .rotate([1, 0, 0], opt['pitch'])
                .rotate([0, 1, 0], opt['yaw'])
                .rotate([0, 0, 1], opt['roll'])
                .scale(opt['scale'])
            )

            # Apply change to scene
            for i in range(1):
                virtual_scene_params[f'light_{i}.position'] = T @ initial_light_positions[i] 
                virtual_scene_params.update()

            virtual_render = mi.render(virtual_scene, virtual_scene_params, spp=SPP)
            
            loss = error_function(virtual_render, picture)
            dr.backward(loss)
            opt.step()


            loss_hist.append(loss.array[0])

        show_results(init_virtual_render, virtual_render, picture, loss_hist)

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


    import pdb; pdb.set_trace()
    params, loss = sorted(results, key=lambda x: x[1])[0]
    with open('results/light_setup.json', 'w') as f:
        json.dump(params, f)

def open_parameters(file_name='results/light_setup.json'):
    with open(file_name) as f:
        params = json.load(f)
        params['translation'] = mi.Vector3f(*eval(params['translation']))
        params['scale'] = mi.Float(eval(params['scale']))
        params['roll'] = mi.Float(eval(params['roll']))
        params['pitch'] = mi.Float(eval(params['pitch']))
        params['yaw'] = mi.Float(eval(params['yaw']))

    return params

    
if __name__ == '__main__':

    test_light_optimizer()
    #test_camera_optimizer()
    # x = cv2.imread('assets/gnome.jpg')
    
    # for i in range(1):
    #     x = cv2.pyrDown(x)

    # print(x.shape)
    # import pdb; pdb.set_trace()

    # scene_dict['sensor']['film']['width'] = x.shape[1]
    # scene_dict['sensor']['film']['height'] = x.shape[0]
    # scene_dict.update()
    # virtual_scene, initial_light_positions, reference_image = initialize_test_scene()

    # image = mi.render(virtual_scene, spp=128)





    # import pdb; pdb.set_trace()


    # f, axarr = plt.subplots(1,2) 

    # # use the created array to output your multiple images. In this case I have stacked 4 images vertically
    # axarr[0].imshow(x)
    # axarr[1].imshow(mi.util.convert_to_bitmap(image))
    # plt.show()


    print(time.time()-start, "s")





    # camera parameters TODO: should be a separate optimization
    # opt['angle'] =  mi.Point3f(0.0,0.0,0.0)
    # opt['translation'] =  mi.Point1f(1.0)
