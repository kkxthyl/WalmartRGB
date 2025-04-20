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

class SetRecCommand: Command {
    
    fileprivate var _parameter: EdsInt32
    fileprivate var _model: CameraModel
    
    init(model: CameraModel, parameter: EdsInt32) {
        
        _parameter = parameter
        _model = model
        super.init(model: model)
        
    }
    
    override func execute() -> Bool {

        var error: EdsError = EdsUInt32(EDS_ERR_OK)

        // Start/End movie recording
        if (_model.getPropertyUInt32(EdsUInt32(kEdsPropID_FixedMovie)) == 1)
        {
            error = EdsSetPropertyData(_model.getCameraObject(), EdsPropertyID(kEdsPropID_Record), 0, EdsUInt32(MemoryLayout<EdsUInt32>.size), &_parameter)
        }

        //Notification of error
        let viewNotification = ViewNotification()
        return viewNotification.errorNotification(error)
    }
}
