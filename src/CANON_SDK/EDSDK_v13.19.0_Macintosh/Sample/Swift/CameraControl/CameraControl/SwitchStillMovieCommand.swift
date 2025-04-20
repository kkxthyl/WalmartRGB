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

class SwitchStillMovieCommand: Command {
    
    fileprivate var _parameter: EdsInt32
    fileprivate var _model: CameraModel
    
    init(model: CameraModel, parameter: EdsInt32) {
        
        _parameter = parameter
        _model = model
        super.init(model: model)
        
    }
    
    override func execute() -> Bool {

        var movieMode = EdsUInt32(0)
        var error: EdsError = EdsUInt32(EDS_ERR_OK)
        error = EdsGetPropertyData(_model.getCameraObject(), EdsUInt32(kEdsPropID_FixedMovie), 0, EdsUInt32(MemoryLayout<EdsUInt32>.size), &movieMode)
        if (movieMode == 0 && _parameter == kEdsCameraCommand_MovieSelectSwOFF)
        {
            return true
        }

        error = EdsSendCommand(_model.getCameraObject(), EdsCameraCommand(_parameter), 0)

        if(error == EdsUInt32(EDS_ERR_OK))
        {
            if (_parameter == kEdsCameraCommand_MovieSelectSwON)
            {
                var saveTo = kEdsSaveTo_Camera
                error = EdsSetPropertyData(_model.getCameraObject(), EdsPropertyID(kEdsPropID_SaveTo), 0, EdsUInt32(MemoryLayout<EdsUInt32>.size), &saveTo)
            }
            else
            {
                var saveTo = kEdsSaveTo_Host
                error = EdsSetPropertyData(_model.getCameraObject(), EdsPropertyID(kEdsPropID_SaveTo), 0, EdsUInt32(MemoryLayout<EdsUInt32>.size), &saveTo)
                let capacity: EdsCapacity = EdsCapacity(numberOfFreeClusters: 0x7fffffff, bytesPerSector: 0x1000, reset: 1)
                error = EdsSetCapacity(_model.getCameraObject(), capacity)
            }
        }
        


        
        //Notification of error
        let viewNotification = ViewNotification()
        return viewNotification.errorNotification(error)
    }
}
