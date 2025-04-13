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

class SetRemoteShootingCommand: Command {
    
    fileprivate var _parameter: EdsInt32
    fileprivate var _model: CameraModel
    
    init(model: CameraModel, parameter: EdsInt32) {
        
        _parameter = parameter
        _model = model
        super.init(model: model)
        
    }
    
    override func execute() -> Bool {
        
        var error: EdsError = EdsUInt32(EDS_ERR_OK)
        var uintData: EdsUInt32 = 0
        
        error = EdsGetPropertyData(_model.getCameraObject(), EdsPropertyID(kEdsPropID_LensBarrelStatus), 0, EdsUInt32(MemoryLayout<EdsUInt32>.size), &uintData)
        if (error != EdsUInt32(EDS_ERR_OK) || uintData == 1)
        {
            return true
        }
        
        // Set property
        if (error == EdsUInt32(EDS_ERR_OK))
        {
            error = EdsSendCommand(_model.getCameraObject(), EdsCameraCommand(kEdsCameraCommand_SetRemoteShootingMode), _parameter)
        }
        
        //Notification of error
        let viewNotification = ViewNotification()
        _ = viewNotification.errorNotification(error)
        return true
        
    }
}
