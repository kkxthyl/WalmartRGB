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

    write_parameters(params)