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


#    updated_emitters = {}
#
#    for name, light in emitters.items():
#        idx = int(name.split("_")[1])
#        face = idx_to_face(idx)
#        orig_pos = light["position"]
#        new_pos = transform @ mi.Point3f(orig_pos)
#
#        if face in faces_on: 
#            updated_emitters[name] = {
#                **light,
#                "position": new_pos
#            }
#        else:
#            updated_emitters[name] = {
#                **light,
#                "position": new_pos,
#                "intensity": {
#                    "type": "rgb",
#                    "value": [0, 0, 0]  # turn off the light
#                }
#            }
#
#    return updated_emitters



scene_dict = {
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

# scene_dict = {
#     "type": "scene",
#     "integrator": {"type": "path"},
#     "sensor": {
#         "type": "perspective",
#         "sampler": {
#             "type": "independent",
#             "sample_count": 512
#         },
#         "to_world": mi.ScalarTransform4f().look_at(
#             origin=[0, 0, 18],
#             target=[0, 0, 0],
#             up=[0, 1, 0]
#         ),
#         "film": {
#             "type": "hdrfilm",
#             "width": 800,
#             "height": 600,
#             "pixel_format": "rgb"
#         },
#     },
#     "env": {
#         "type": "constant",
#         "radiance": {"type": "rgb", "value": [0.01, 0.01, 0.01]}
#     },
#     "cube-back":{
#         "type": "obj",
#         "filename": "cube.obj",
#         "to_world": mi.ScalarTransform4f()
#             .translate([0, 0, -10])  
#         , 
#         "bsdf": {
#             "type": "twosided",
#             "bsdf": {
#                 "type": "diffuse",
#                 "reflectance": {"type": "rgb", "value": [0.2, 0.2, 0.2]}
#             }
#         }
#     },

#     "cube-top":{
#         "type": "obj",
#         "filename": "cube.obj",
#         "to_world": mi.ScalarTransform4f()
#             .translate([0, 10, 0])  
#         ,  
#         "bsdf": {
#             "type": "twosided",
#             "bsdf": {
#                 "type": "diffuse",
#                 "reflectance": {"type": "rgb", "value": [0.2, 0.2, 0.2]}
#             }
#         }
#     }, 
#     "cube-left":{
#         "type": "obj",
#         "filename": "cube.obj",
#         "to_world": mi.ScalarTransform4f()
#             .translate([10,0, 0]) 
#         ,  
#         "bsdf": {
#             "type": "twosided",
#             "bsdf": {
#                 "type": "diffuse",
#                 "reflectance": {"type": "rgb", "value": [0.2, 0.2, 0.2]}
#             }
#         }
#     }, 
#     "cube-right":{
#         "type": "obj",
#         "filename": "cube.obj",
#         "to_world": mi.ScalarTransform4f()
#             .translate([-10, 0, 0]) 
#         , 
#         "bsdf": {
#             "type": "twosided",
#             "bsdf": {
#                 "type": "diffuse",
#                 "reflectance": {"type": "rgb", "value": [0.2, 0.2, 0.2]}
#             }
#         }
#     }, 
#     "cube-bottom":{
#         "type": "obj",
#         "filename": "cube.obj",
#         "to_world": mi.ScalarTransform4f()
#             .translate([0, -10, 0])  
#         , 
#         "bsdf": {
#             "type": "twosided",
#             "bsdf": {
#                 "type": "diffuse",
#                 "reflectance": {"type": "rgb", "value": [0.2, 0.2, 0.2]}
#             }
#         }
#     },
#     "center_sphere": {
#         "type": "sphere",
#         "to_world": mi.ScalarTransform4f().translate([0, 0, 0]).scale(2),  # Adjust position & size
#         "bsdf": {
#             "type": "diffuse",
#             # "reflectance": {
#             #     "type": "rgb",
#             #     "value": [0.5, 0.5, 0.5]
#             # }
#             "reflectance": {
#                 "type": "checkerboard",
#                 "color0": {"type": "rgb", "value": [0.8, 0.8, 0.8]},
#                 "color1": {"type": "rgb", "value": [0.2, 0.2, 0.2]},
#                 "to_uv": mi.Transform4f().scale([5, 5, 5])


#             }
#         }
#     }
# }


def render_scene(emitters, config="RGB", save_path=None):
    scene_dict = {
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
                    "to_uv": mi.ScalarTransform4f().scale(mi.Vector3f(10, 10, 1))
                }
            }
        }
    }

    scene_dict.update(emitters)

    scene = mi.load_dict(scene_dict)
    img = mi.render(scene)
    bitmap = mi.util.convert_to_bitmap(img)

    if save_path:
        plt.imshow(bitmap)
        plt.axis('off')
        plt.savefig(save_path, dpi=300, bbox_inches='tight')
        plt.show()
    else:
        plt.imshow(bitmap)
        plt.axis('off')
        plt.show()


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
    return mi.TensorXf(np.array(mi.Bitmap('output/CMYK.png')))

    
def save_render(virtual_img, epoch):
    plt.imshow(mi.util.convert_to_bitmap(virtual_img))
    plt.axis('off')
    file = f"results/virtual_epoch{epoch}.png"
    plt.savefig(file, dpi=300, bbox_inches='tight')
    return mi.TensorXf(np.array(mi.Bitmap(file)))

def render(scene, params):
    ret = mi.render(scene, params, spp=8)
    return ret
    
def error_function(image, image_ref):
    return dr.mean(dr.square(image-image_ref))

def update_virtual_lights(params, translation, scale, orientation):

    T = get_transform(
        translation,
        scale,
        orientation
    )

    # Apply transform to each light
    for i in range(600):
        key = f'light_{i}.position'
        x,y,z = T @ params[key]
        params[key] = dr.ravel([x,y,z])

    return params

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


def initialize_test_scene():

    scene_dict.update(emitters)

    virtual_scene = mi.load_dict(scene_dict)

    virtual_params = mi.traverse(virtual_scene)
    virtual_img1 = render(virtual_scene, virtual_params)

    t = dict()
    # Misalign virtual scene for testing
    t['orientation'] =  mi.Point3f(0.0,0.0,0.0)
    t['translation'] =  mi.Point3f(5.0,0.0,0.0)
    t['scale'] =  mi.Point1f(1.0)
    update_virtual_lights(
        virtual_params,
        t['translation'],
        t['scale'] ,
        t['orientation'],
    )
    virtual_img = mi.render(virtual_scene, virtual_params, spp=8)
    compare_scenes(virtual_img1, virtual_img)

    return virtual_scene 

def attempt_transformation(virtual_scene, opt, img_ref):
    
    
    virtual_params = mi.traverse(virtual_scene).copy()
    trial_scene = mi.load_dict(virtual_params)

    update_virtual_lights(trial_scene, opt)
    virtual_img = mi.render(trial_scene)
    return error_function(virtual_img, img_ref)



def test_camera_optimizer():
    virtual_scene, real_scene = initialize_test_scenes()

    opt = mi.ad.Adam(
        lr=0.25
    )

    # cube parameters 
    opt['fov'] =  mi.Vector3f(0.0,0.0,0.0)
    opt['orientation'] =  mi.Vector3f(0.0,0.0,0.0)
    opt['scale'] =  mi.Vector1f(1.0)

def test_light_optimizer():


    virtual_scene = initialize_test_scene()

    print('Initializing optimizer...')

    virtual_scene_params = mi.traverse(virtual_scene)
    params = {}
    params['translation'] =  mi.Vector3f([1.0,0.0,0.0])
    params['orientation'] =  mi.Vector3f([0.0,0.0,0.0])
    params['scale'] =  mi.Point1f(1.0)

    opt = mi.ad.Adam(
        lr=0.25,
        params=virtual_scene_params['light_0.position']
    )
    
    # cube parameters 
    # dr.enable_grad(params["translation"])
    # dr.enable_grad(params["scale"])
    # dr.enable_grad(params["orientation"])


    import pdb; pdb.set_trace()

    results = []
    for light_setup in range(1):
        
        #picture = take_picture()
        picture = mi.Bitmap(np.full((600, 800, 3), 0.5, dtype=np.float32))

        epochs = np.array([0])
        losses = np.array([0])

        #figure, line = track_losses(epochs, losses)
        # Optimization Loop
        virtual_scene_params = mi.traverse(virtual_scene)

        for epoch in range(5):

            print('Epoch: ', epoch)

            # clamp if necessarry
            # smallest scale, upper bound
            import pdb; pdb.set_trace()
            # new_params = update_virtual_lights(
            #     virtual_scene_params,
            #     params['translation'],
            #     params['scale'],
            #     params['orientation']
            # )
            virtual_render = mi.render(virtual_scene, virtual_scene_params, spp=8)
            #virtual_img = save_render(virtual_render, epoch)

            #compare_scenes(picture, virtual_img)
            
            loss = error_function(virtual_render, picture)
            dr.backward(loss)
            opt.step()
            virtual_scene_params.update(opt)
            

            print(params['translation']) 
            print(params['orientation']) 
            print(params['scale']) 
            print('Loss: ', loss)
            
            # Update graph
            #epochs = np.append(epochs, epoch)
            #losses = np.append(losses, loss)

            #line.set_xdata(epochs)
            #line.set_ydata(losses)
            #plt.xlim([epochs.min()-1, epochs.max()+1])
            #plt.ylim([losses.min()-0.01, losses.max()+0.01])
            #figure.canvas.draw()
            ## This will run the GUI event loop until all 
            ## UI events currently waiting have been processed
            #figure.canvas.flush_events()
            #time.sleep(0.1)
            

        # Finished optimizing against one light setup
        results.append((loss, params))
    #compare_scenes(picture, virtual_img)

    parameters = sorted(results, key=lambda x: x[0])[0][1]
    # OR take the average
    #parameters = next(sorted(results, key=lambda x: x[0]))[1]


    print(parameters)


if __name__ == '__main__':

    # img = mi.render(scene)
    # plt.imshow(mi.util.convert_to_bitmap(img))
    # plt.axis('off')

    test_light_optimizer()

    print(time.time()-start, "s")




    # camera parameters TODO: should be a separate optimization
    # opt['angle'] =  mi.Point3f(0.0,0.0,0.0)
    # opt['translation'] =  mi.Point1f(1.0)
