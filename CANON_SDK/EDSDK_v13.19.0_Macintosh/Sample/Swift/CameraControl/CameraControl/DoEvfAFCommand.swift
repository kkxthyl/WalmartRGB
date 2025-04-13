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

class DoEvfAFCommand: Command {
    
    fileprivate var _parameter: EdsInt32
    fileprivate var _model: CameraModel
    
    init(model: CameraModel, parameter: EdsInt32) {
        
        _parameter = parameter
        _model = model
        super.init(model: model)
        
    }
    
    override func execute() -> Bool {
        
        var error: EdsError = EdsUInt32(EDS_ERR_OK)
        
        //
        if(error == EdsUInt32(EDS_ERR_OK))
        {
            error = EdsSendCommand(_model.getCameraObject(), EdsUInt32(kEdsCameraCommand_DoEvfAf), _parameter)
        }
        
        //Notification of error
        let viewNotification = ViewNotification()
        let result = viewNotification.errorNotification(error)

        return result
    }
    
}
