import os
from pathlib import Path
import mitsuba as mi
import matplotlib.pyplot as plt
import numpy as np
import time
import drjit as dr
import json
import cv2 

REFERENCE_DIRECTORY = '../calibration_images'
FILE_TYPE = 'combined.jpg'
SPP = 2

start = time.time()

mi.set_variant('cuda_ad_rgb')
def get_mask():

    calib = os.path.join(REFERENCE_DIRECTORY, 'mask_calibration.jpg')
    blank = os.path.join(REFERENCE_DIRECTORY, 'mask_blank.jpg')

    img_empty = cv2.imread(blank)
    img_obj = cv2.imread(calib)

    mask = np.zeros(img_obj.shape[:2], dtype="uint8")

    # creating a rectangle on the mask
    # where the pixels are valued at 255

    # plt.subplot(1, 2, 1)
    # plt.imshow(img_empty)
    # plt.axis('off')

    # plt.subplot(1, 2, 2)
    # plt.imshow(img_obj)
    # plt.axis('off')

    # plt.show()

    diff = cv2.absdiff(img_empty, img_obj)
    # plt.imshow(diff, cmap='gray')
    # plt.axis('off')
    # plt.show()

    # normalized = cv2.normalize(diff, None, 0, 1, cv2.NORM_MINMAX)
    # plt.imshow(normalized, cmap='gray')
    # plt.show()

    diff = cv2.cvtColor(diff, cv2.COLOR_BGR2GRAY)
    mask = cv2.threshold(diff, 30, 255, cv2.THRESH_BINARY)[1]
    mask = cv2.cvtColor(mask, cv2.COLOR_GRAY2BGR)

    # plt.imshow(mask)

    gray_image = cv2.cvtColor(mask, cv2.COLOR_BGR2GRAY)
    return gray_image

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

    

ref_path = next(Path(REFERENCE_DIRECTORY).glob(f'*{FILE_TYPE}'))
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

def compare_scenes(real_img, virtual_img, file_name):

    start = time.time()

    f, axarr = plt.subplots(1,2) 

    # use the created array to output your multiple images. In this case I have stacked 4 images vertically
    axarr[0].imshow(real_img)
    axarr[1].imshow(virtual_img)

    print('Comparing virtual and real scenes ({} s)'.format(time.time()-start))
    plt.show()
    plt.savefig(f'figures/{file_name}')


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

    check_board_scene.update(get_emitters('WHITE'))
    virtual_scene = mi.load_dict(check_board_scene)
    virtual_params = mi.traverse(virtual_scene)
    

    # reference_image = mi.render(virtual_scene, virtual_params, spp=SPP)

    print("Real FOV: ", virtual_params['sensor.x_fov'])
    # # Build transformation
    # T = (
    #     mi.Transform4f()
    #     .translate([0,0,0])
    # )

    # U = (
    #     mi.Transform4f()
    #     .rotate([1, 0, 0], 0)
    #     .rotate([0, 1, 0], 0)
    #     .rotate([0, 0, 1], 0)
    # )

    # # Misalign virtual scene for testing
    # virtual_params['sensor.x_fov'] = virtual_params['sensor.x_fov'] *0.9

    # virtual_params["sensor.to_world"] = mi.ScalarTransform4f().look_at(
    #     origin=point_to_list(T@[18,0,0]),
    #     target=[0, 0, 0],
    #     up=point_to_list(U@[0,1,0])
    # )

    # virtual_params.update()

   
    #virtual_img = mi.render(virtual_scene, virtual_params, spp=SPP)
    #compare_scenes(reference_image, virtual_img)

    return virtual_scene


def initialize_test_scene(misalign=False):

    # Initialize scene
    check_board_scene.update(get_emitters())
    virtual_scene = mi.load_dict(check_board_scene)
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
        initial_light_positions = [mi.Point3f(virtual_params[f'light_{i}.position']) for i in range(600)]
        for i in range(600):
            virtual_params[f'light_{i}.position'] = T @ initial_light_positions[i] 
            virtual_params.update()

   
    # virtual_img = mi.render(virtual_scene, virtual_params, spp=SPP)
    # compare_scenes(reference_image, virtual_img)

    initial_light_positions = [mi.Point3f(virtual_params[f'light_{i}.position']) for i in range(600)]
    return virtual_scene, initial_light_positions 

def test_camera_optimizer():

    virtual_scene = initialize_checker_board_scene()
    print('Initializing optimizer...')

    virtual_scene_params = mi.traverse(virtual_scene)
    opt = mi.ad.Adam(
        lr=0.1,
        mask_updates=True
    )
    
    opt['translation'] =  mi.Vector3f([2,19,56])
    # opt['roll'] =  mi.Float(0.0)
    # opt['pitch'] =  mi.Float(0.0)
    # opt['yaw'] =  mi.Float(0.0)
    opt["sensor.x_fov"] = mi.Float(30)

    # Use the Plane Sweep Method
    # Elect depth candidates
    loss_hist = []
    virtual_render = None
    loss = None

    file = next(Path(REFERENCE_DIRECTORY).glob(f'*{FILE_TYPE}'))
    picture = cv2.imread(str(file))
    virtual_scene_params.update(get_emitters('WHITE'))
    init_virtual_render = mi.render(virtual_scene, virtual_scene_params, spp=SPP)

    mask = get_mask()
    picture = cv2.bitwise_and(picture, picture, mask=mask)
    #picture = cv2.cvtColor(picture, cv2.COLOR_BGR2GRAY)
    compare_scenes(picture, init_virtual_render, 'camera_calibration')
        
    import pdb; pdb.set_trace()
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
            # .rotate([1, 0, 0], opt['pitch'])
            # .rotate([0, 1, 0], opt['yaw'])
            # .rotate([0, 0, 1], opt['roll'])
            # .scale(opt['scale'])
        )

        # U = (
        #     mi.Transform4f()
        #     .rotate([1, 0, 0], opt['pitch'])
        #     .rotate([0, 1, 0], opt['yaw'])
        #     .rotate([0, 0, 1], opt['roll'])
        # )

        #up = @ [0,1,0]



        print(opt['translation'])
        # # Apply change to scene
        virtual_scene_params["sensor.to_world"] = T @ initial_to_world
        virtual_scene_params["sensor.x_fov"] = opt["sensor.x_fov"] 
        virtual_scene_params.update()

        virtual_render = mi.render(virtual_scene, virtual_scene_params, spp=SPP)
        
        if epoch % 10 == 0:
            compare_scenes(picture, virtual_render, f'{epoch}_tens')

        virtual_render = cv2.cvtColor(np.array(virtual_render), cv2.COLOR_BGR2GRAY)
        import pdb; pdb.set_trace()
        thresh = cv2.threshold(virtual_render, 127, 255, cv2.THRESH_BINARY)[1]
        contours, _ = cv2.findContours(thresh, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
        print(np.mean([cv2.contourArea(contour) for contour in contours]))
        
        loss = error_function(virtual_render, picture)
        print(loss)
        dr.backward(loss)
        opt.step()

        loss_hist.append(loss.array[0])


    show_results(init_virtual_render, virtual_render, picture, loss_hist, 'camera_optimization')

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
    
    mask = get_mask()

    import pdb; pdb.set_trace()
    for config_file in Path(REFERENCE_DIRECTORY).glob(f'CMYK*{FILE_TYPE}'):

        
        # Change the lights to match the real scene
        print(config_file)
        config = config_file.name.split('_')[0]
        print(config)
        check_board_scene.update(get_emitters(config))
        virtual_scene = mi.load_dict(check_board_scene)
        virtual_scene_params = mi.traverse(virtual_scene)
        virtual_scene_params["sensor.to_world"] = mi.ScalarTransform4f().look_at(
            origin=[2,19,56],
            target=[0,0,0],
            up=[0,1,0],
        )
        virtual_scene_params.update()

        for key in opt.keys():
            opt.reset(key)
        
        picture = cv2.imread(str(config_file))
        picture = cv2.bitwise_and(picture, picture, mask=mask)

        init_virtual_render = mi.render(virtual_scene, virtual_scene_params, spp=SPP)
        compare_scenes(picture, mi.util.convert_to_bitmap(init_virtual_render), 'config_file_initial')

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
            
            loss = error_function(virtual_render, picture)
            dr.backward(loss)
            opt.step()


            print(loss)
            loss_hist.append(loss.array[0])

        print('Showing results!')
        show_results(init_virtual_render, virtual_render, picture, loss_hist, f'{config_file.name}_results')

        result = {
            'scale' : opt['scale'],
            'translation' : opt['translation'],
            'roll' : opt['roll'],
            'pitch' : opt['pitch'],
            'yaw' : opt['yaw'],
        }
        results.append((result, loss))
    #compare_scenes(picture, virtual_render)


    params, loss = sorted(results, key=lambda x: x[1])[0]
    for k,v in params.items():
        params[k] = str(v)
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

def camera_pose_estimation():
    virtual_scene = initialize_checker_board_scene()

    virtual_scene_params = mi.traverse(virtual_scene)

    # virtual_scene_params["sensor.to_world"] = mi.ScalarTransform4f().look_at(
    #     target=[0,0,0],
    #     up=[int(up[i][0]) for i in range(3)],
    # )


    # file = next(Path(REFERENCE_DIRECTORY).glob('mask_calibration.jpg'))
    # picture = cv2.imread(str(file))
    init_virtual_render = mi.render(virtual_scene, virtual_scene_params, spp=SPP)
    picture = mi.util.convert_to_bitmap(init_virtual_render)
    mask = get_mask()
    picture = cv2.bitwise_and(picture, picture, mask=mask)
    #picture = cv2.imread('chessboard.jpg')
    imgray = cv2.cvtColor(picture, cv2.COLOR_BGR2GRAY)
    ret, thresh = cv2.threshold(imgray, 200, 255, 0)
    contours, hierarchy = cv2.findContours(thresh, cv2.RETR_TREE, cv2.CHAIN_APPROX_SIMPLE)
    #cv2.drawContours(thresh, contours, -1, (0,255,0), 3)

    # print(contours)
    corners = []
    for cnt in contours:
        x, y = cnt[0][0]
        #print(thresh)
        picture = cv2.circle(picture, (x,y), 10, (0,0,255), 10) 

    objectPoints = np.array([(x, y) for x,y in zip(range(len(corners)),range(len(corners)))])
    imagePoints = np.array(corners)
    cameraMatrix = cameraMatrix = np.array([
    [800, 0, 320],
    [0, 800, 240],
    [0,   0,   1]
    ], dtype=np.float32)
    distCoeffs = np.zeros(5)

    success, rvec, tvec = cv2.solvePnP(objectPoints, imagePoints, cameraMatrix, distCoeffs)
    print(success, rvec, tvec)

    
if __name__ == '__main__':




    # U = (
    #     mi.Transform4f()
    #     .rotate([1, 0, 0], 0)
    #     .rotate([0, 1, 0], 65)
    #     .rotate([0, 0, 1], 0)
    # )

    # up = U @ [0,1,0]



    #compare_scenes(picture, picture, 'corners')

    # # # virtual_scene_params.update(get_emitters('WHITE'))


    # picture = cv2.cvtColor(picture, cv2.COLOR_BGR2GRAY)
    
    # # for i in range(picture.shape[0]):
    # #     for j in range(picture.shape[1]):
            
    # #         if any(picture[i][j]):

    # #             print(picture[i][j])
    # # detect corners with the goodFeaturesToTrack function. 
    # corners = np.int0(corners) 
    
    # # we iterate through each corner,  
    # # making a circle at each point that we think is a corner. 
    # for i in corners: 
    #     x, y = i.ravel() 
    #     cv2.circle(picture, (x, y), 3, 255, -1) 

    # plt.imshow(picture)
    # # plt.savefig('new222.png')
    # mask = get_mask()

    #for config_file in Path(REFERENCE_DIRECTORY).glob(f'*{FILE_TYPE}'):

        # Change the lights to match the real scene

    # config_file = Path('../calibration_images/COOL_combined.jpg')
    # print(config_file)
    # config = config_file.name.split('_')[0]
    # print(config)
    # picture = cv2.imread(str(config_file))
    # #picture = cv2.bitwise_and(picture, picture, mask=mask)
    # #compare_scenes(picture, picture, config_file.name)
    # plt.imshow(picture)
    # plt.savefig('figures/test.png')


    test_light_optimizer()

    




    # test_light_optimizer()
    # test_camera_optimizer()
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
