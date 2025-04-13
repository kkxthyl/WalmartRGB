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

class EndEvfCommand: Command {
    
    fileprivate var _model: CameraModel
    
    override init(model: CameraModel) {
        
        _model = model
        super.init(model: model)
        
    }
    
    override func execute() -> Bool {
        
        // Get the current output device.
        var device = _model.evfOutputDevice()
        
        var error = EdsUInt32(EDS_ERR_OK)
        
        
        // Do nothing if the remote live view has already ended.
        if(device & EdsUInt32(kEdsEvfOutputDevice_PC.rawValue) == 0)
        {
            return true
        }
        
        // Get depth of field status.
        var depthOfFieldPreview = _model.evfDepthOfFieldPreview()
        
        // Release depth of field in case of depth of field status.
        if(depthOfFieldPreview != 0)
        {
            depthOfFieldPreview = 0
            
            error = EdsSetPropertyData(_model.getCameraObject(), EdsPropertyID(kEdsPropID_Evf_DepthOfFieldPreview), 0, EdsUInt32(MemoryLayout<EdsUInt32>.size), &depthOfFieldPreview)
            
            // Standby because commands are not accepted for awhile when the depth of field has been released.
            if(error == EdsUInt32(EDS_ERR_OK))
            {
                Thread.sleep(forTimeInterval: 0.5)
            }
        }
        
        // Change the output device.
        if(error == EdsUInt32(EDS_ERR_OK))
        {
            device &= ~kEdsEvfOutputDevice_PC.rawValue
            error = EdsSetPropertyData(_model.getCameraObject(), EdsPropertyID(kEdsPropID_Evf_OutputDevice), 0, EdsUInt32(MemoryLayout<EdsUInt32>.size), &device);
        }
        
        //Notification of error(Retry)
        let viewNotification = ViewNotification()
        
        _model.SetProperty(EdsUInt32(kEdsPropID_EVF_RollingPitching), property: 1)
        let cameraPos: EdsCameraPos = EdsCameraPos()
        var event = CameraEvent(type:.angle_INFO, arg: cameraPos as AnyObject)
        viewNotification.viewNotificationObservers(&event)

        return viewNotification.errorNotificationWithRetry(error)
        
    }
    
}
