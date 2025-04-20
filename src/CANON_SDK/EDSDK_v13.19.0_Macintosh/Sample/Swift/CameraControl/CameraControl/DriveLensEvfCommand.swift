/******************************************************************************
 *                                                                             *
 *   PROJECT : Eos Digital camera Software Development Kit EDSDK               *
 *                                                                             *
 *   Description: This is the Sample code to show the usage of EDSDK.          *
 *                                                                             *
 *                                                                             *
 *******************************************************************************
 *                                                                             *
 *   Written and developed by Canon Inc.                                       *
 *   Copyright Canon Inc. 2018 All Rights Reserved                             *
 *                                                                             *
 *******************************************************************************/

import Cocoa

class DriveLensEvfCommand: Command {
    
    fileprivate var _parameter: EdsInt32
    fileprivate var _model: CameraModel
    
    init(model: CameraModel, parameter: EdsInt32) {
        
        _parameter = parameter
        _model = model
        super.init(model: model)
        
    }

    override func execute() -> Bool {
        
        //Drives the lens and adjusts focus
        let error = EdsSendCommand(_model.getCameraObject(), EdsCameraCommand(kEdsCameraCommand_DriveLensEvf), _parameter)
       
        //Notification of error
        let viewNotification = ViewNotification()
        return viewNotification.errorNotification(error)
        
    }
}

