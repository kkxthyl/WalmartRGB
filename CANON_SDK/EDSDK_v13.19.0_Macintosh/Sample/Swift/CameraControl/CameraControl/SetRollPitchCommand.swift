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

class SetRollPitchCommand: Command {
    
    fileprivate var _parameter: EdsInt32
    fileprivate var _model: CameraModel
    
    init(model: CameraModel, parameter: EdsInt32) {
        
        _parameter = parameter
        _model = model
        super.init(model: model)
        
    }
    
    override func execute() -> Bool {

        let rollPitch = EdsInt32(_model.getPropertyUInt32(EdsUInt32(kEdsPropID_EVF_RollingPitching)))
        
        if (!_model.getIsEvfEnable())
        {
            return true
        }

        var error: EdsError = EdsUInt32(EDS_ERR_OK)
        error = EdsSendCommand(_model.getCameraObject(), EdsCameraCommand(kEdsCameraCommand_RequestRollPitchLevel), rollPitch)

        let viewNotification = ViewNotification()
        if (rollPitch == 1)
        {
            let cameraPos: EdsCameraPos = EdsCameraPos()
            var event = CameraEvent(type:.angle_INFO, arg: cameraPos as AnyObject)
            viewNotification.viewNotificationObservers(&event)
        }

        //Notification of error
        let result = viewNotification.errorNotificationShutter(error)
        return result
    }
}
