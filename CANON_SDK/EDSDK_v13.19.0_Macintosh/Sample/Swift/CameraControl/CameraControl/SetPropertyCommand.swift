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

class SetPropertyCommandWithData: Command {
    
    fileprivate var _propertyID: EdsPropertyID
    fileprivate var _data: Any
    fileprivate var _model: CameraModel
    
    init(model: CameraModel, propertyID: EdsPropertyID, data: Any) {
        
        _propertyID = propertyID
        _data = data
        _model = model
        super.init(model: model)
        
    }
    
    override func execute() -> Bool {
        
        var error: EdsError = EdsUInt32(EDS_ERR_OK)
        
        // Set property
        if (error == EdsUInt32(EDS_ERR_OK))
        {
            var size: EdsUInt32 = EdsUInt32(0)
            switch _data {
            case is EdsPoint:
                size = EdsUInt32(MemoryLayout<EdsPoint>.size)
            default:
                size = EdsUInt32(MemoryLayout<EdsUInt32>.size)
            }
            error = EdsSetPropertyData(_model.getCameraObject(), _propertyID, 0, size, &_data)
        }
        
        //Notification of error
        let viewNotification = ViewNotification()
        _ = viewNotification.errorNotification(error)
        return true
        
    }
}
