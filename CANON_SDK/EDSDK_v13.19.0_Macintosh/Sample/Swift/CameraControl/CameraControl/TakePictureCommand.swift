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

import Foundation

class TakePictureCommand : Command{
    
    fileprivate var _model: CameraModel
    
    override init(model: CameraModel) {
        
        _model = model
        super.init(model: model)
        
    }
    
    override func execute()->Bool {
        
        //Takeing a picture
        var error = EdsSendCommand(_model.getCameraObject(), EdsCameraCommand(kEdsCameraCommand_PressShutterButton), Int32(kEdsCameraCommand_ShutterButton_Completely.rawValue))
        error = EdsSendCommand(_model.getCameraObject(), EdsCameraCommand(kEdsCameraCommand_PressShutterButton), Int32(kEdsCameraCommand_ShutterButton_OFF.rawValue))
        
        //Notification of error
        let viewNotification = ViewNotification()
        let result = viewNotification.errorNotificationShutter(error)
        
        _model.setCanDownloadImage(true)
        
        return result
        
    }
}
