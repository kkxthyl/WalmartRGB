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

class ClickWBCommand: Command {
    
    fileprivate var _parameter: EdsInt32
    fileprivate var _model: CameraModel
    
    init(model: CameraModel, parameter: EdsInt32) {
        
        _parameter = parameter
        _model = model
        super.init(model: model)
        
    }
    
    override func execute() -> Bool {
        let viewNotification = ViewNotification()

        if (!_model.getIsEvfEnable())
        {
            return false
        }

        if (_parameter == 1)
        {
            var event = CameraEvent(type:.mouse_CURSOR, arg: _parameter as AnyObject)
            viewNotification.viewNotificationObservers(&event)
        }

        var error: EdsError = EdsUInt32(EDS_ERR_OK)
        if (_parameter == 2)
        {
            let param: Int32 = _model.getClickPoint()
            error = EdsSendCommand(_model.getCameraObject(), EdsCameraCommand(kEdsCameraCommand_DoClickWBEvf), param)
        }

        //Notification of error
        return viewNotification.errorNotification(error)
    }
}
