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

class CloseSessionCommand: Command {
    
    fileprivate var _model: CameraModel
    
    override init(model: CameraModel) {
        
        _model = model
        super.init(model: model)
        
    }
    
    override func execute() -> Bool {
        
        var error: EdsError = EdsUInt32(EDS_ERR_OK)
        
        if (_model.getCameraObject() != nil){
            
            error = EdsCloseSession(_model.getCameraObject())
            
       }
        
        //Notification of error
        let viewNotification = ViewNotification()
        
        return viewNotification.errorNotification(error)
    }
    
    
}
