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

class FormatVolumeCommand : Command{
    
    fileprivate var _model: CameraModel
    
    override init(model: CameraModel) {
        
        _model = model
        super.init(model: model)
        
    }
    
    //Format the specified volume.
    override func execute()->Bool {
        
        var error: EdsError = EdsUInt32(EDS_ERR_OK)
        let camera: EdsCameraRef? = _model.getCameraObject()
        var volumeCount = 0 as EdsUInt32
        let volumeIndex = _model.getSelectedVolume()
        
        error = EdsGetChildCount(camera, &volumeCount)
        if(volumeCount <= volumeIndex){
            error = EdsError(EDS_ERR_DIR_NOT_FOUND)
        }
        
        if error ==  EdsUInt32(EDS_ERR_OK)
        {
            var volume : EdsBaseRef? = nil
            EdsGetChildAtIndex(camera, EdsInt32(volumeIndex), &volume)
            error = EdsFormatVolume(volume)
        }
        //Notification of error
        let viewNotification = ViewNotification()
        return viewNotification.errorNotification(error)
    }
}
