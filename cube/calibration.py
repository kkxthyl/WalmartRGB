import mitsuba as mi
import matplotlib.pyplot as plt
import numpy as np
import colorsys
import time
import drjit as dr

start = time.time()

mi.set_variant('scalar_rgb')

def light_grid(face, n1, n2, const_val):
    positions = []
    if face == "top":
        # Top face
        xs = np.linspace(-4, 4, n1)
        zs = np.linspace(-4, 4, n2)
        for x in xs:
            for z in zs:
                positions.append([x, const_val, z])
    elif face == "back":
        # Back face
        xs = np.linspace(-4, 4, n1)
        ys = np.linspace(-4, 4, n2)
        for x in xs:
            for y in ys:
                positions.append([x, y, const_val])
    elif face == "left":
        # Left face
        ys = np.linspace(-4, 4, n1)
        zs = np.linspace(-4, 4, n2)
        for y in ys:
            for z in zs:
                positions.append([const_val, y, z])
    elif face == "right":
        # Right face
        ys = np.linspace(-4, 4, n1)
        zs = np.linspace(-4, 4, n2)
        for y in ys:
            for z in zs:
                positions.append([const_val, y, z])
    return positions


# 10 x 15 = 150 lights
top_pos   = light_grid("top",   10, 15,  4.5)   
back_pos  = light_grid("back",  10, 15, -4.5)  
left_pos  = light_grid("left",  10, 15, -4.5)  
right_pos = light_grid("right", 10, 15,  4.5)   

# 12 x 12 = 144 lights
# top_pos   = light_grid("top",   12, 12,  4.5)   
# back_pos  = light_grid("back",  12, 12, -4.5)  
# left_pos  = light_grid("left",  12, 12, -4.5)  
# right_pos = light_grid("right", 12, 12,  4.5)   

all_pos = top_pos + back_pos + left_pos + right_pos
print("Total light emitters:", len(all_pos))  



def rainbow(i, total):
    hue = i / total
    saturation = 1.0
    value = 1.0
    r, g, b = colorsys.hsv_to_rgb(hue, saturation, value)
    # return [r * 1.5, g * 1.5, b * 1.5]
    return [r, g, b]

# Suppose you already generated 'all_positions' for 600 lights
# We'll just assume you have them in a list named all_positions.
# Build emitter definitions, each with a unique color.
emitters = {}
num_emitters = len(all_pos)
for i, pos in enumerate(all_pos):
    color = rainbow(i, num_emitters) 
    emitters[f"light_{i}"] = {
        "type": "point",
        "position": pos,
        "intensity": {
            "type": "rgb",
            "value": color  # Use the rainbow function's RGB output
        }

        # "center": pos,
        # "radius": 0.05,
        # "emitter": {
        #     "type": "area",
        #     "radiance": {"type": "rgb", "value": color}
        # },
        # Optional: a diffuse BSDF so you see the spheres themselves
        # "bsdf": {
        #     "type": "diffuse",
        #     "reflectance": {"type": "rgb", "value": [1, 1, 1]}
        # }
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

def update_emitters(emitters, translation, scale, orientation, faces_on = ["left", "top", "back", "right"]):
    x, y, z = translation
    s = scale
    x_r, y_r, z_r = orientation

    transform = (
        mi.ScalarTransform4f()
        .translate([x, y, z])
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

    updated_emitters = {}

    for name, light in emitters.items():
        idx = int(name.split("_")[1])
        face = idx_to_face(idx)
        orig_pos = light["position"]
        new_pos = transform @ mi.Point3f(orig_pos)

        if face in faces_on: 
            updated_emitters[name] = {
                **light,
                "position": new_pos
            }
        else:
            updated_emitters[name] = {
                **light,
                "position": new_pos,
                "intensity": {
                    "type": "rgb",
                    "value": [0, 0, 0]  # turn off the light
                }
            }

    return updated_emitters






def take_picture(scene):
    return mi.render(scene, spp=8)

    
def error_function(image, image_ref):
    return dr.mean(dr.sqr(image-image_ref))

def update_virtual_lights(opt):
    T = mi.Transform4f.translate(opt['translation'])

    new_light_positions = T 

def test_optimizer():

    real_dict = scene_dict.copy()
    virtual_dict = scene_dict.copy()
    
    real_emitters = emitters.copy()
    virtual_emitters = update_emitters(emitters, [10, 21, 4], 4, [0,0,0])

    real_dict.update(real_emitters)
    virtual_dict.update(virtual_emitters)

    virtual_scene = mi.load_dict(scene_dict)
    real_scene = mi.load_dict(real_dict)

    virtual_params = mi.traverse(virtual_scene)


    mi.set_variant('llvm_ad_rgb')
    import pdb; pdb.set_trace()
    img = mi.render(virtual_scene)
    mi.Scene
    plt.imshow(mi.util.convert_to_bitmap(img))
    plt.axis('off')
    plt.show()

    opt = mi.ad.Adam(
        lr=0.25
    )

    # camera parameters TODO: should be a separate optimization
    # opt['angle'] =  mi.Point3f(0.0,0.0,0.0)
    # opt['translation'] =  mi.Point1f(1.0)


    # cube parameters 
    opt['translation'] =  mi.Point3f(0.0,0.0,0.0)
    opt['orientation'] =  mi.Point3f(0.0,0.0,0.0)
    opt['scale'] =  mi.Point1f(1.0)


    results = []
    import pdb; pdb.set_trace()
    for light_setup in range(1):
        
        # TODO: Change lights
        print(light_setup)
        picture = take_picture(real_scene)
        print(light_setup)

        update_emitters(opt['translation'], opt['scale'], opt['orientation'])

        # Optimization Loop
        for _ in range(50):

            virtual_render = mi.render(virtual_scene, virtual_params, spp=8)
            loss = error_function(virtual_render, picture)
            print(loss)
            dr.backward(loss)
            opt.step()

            # clamp if necessarry
            # smallest scale, upper bound
            virtual_emitters = update_emitters(virtual_emitters, [10, 21, 4], 4, [0,0,0])
            virtual_params.update(virtual_emitters)

        # Finished optimizing against one light setup
        results.append((loss, opt))

    parameters = next(sorted(results, key=lambda x: x[0]))[1]
    # OR take the average
    #parameters = next(sorted(results, key=lambda x: x[0]))[1]


    print(parameters)




#test_optimizer()
print(time.time()-start, "s")

img = mi.render(mi.load_dict(scene_dict))