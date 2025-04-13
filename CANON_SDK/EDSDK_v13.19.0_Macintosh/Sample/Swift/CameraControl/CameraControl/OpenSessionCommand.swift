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

class OpenSessionCommand : Command{
    
    fileprivate var _model: CameraModel

    override init(model: CameraModel) {
        
        _model = model
        super.init(model: model)
        
    }
    
    override func execute()->Bool {
        
        let camera: EdsCameraRef? = _model.getCameraObject()
        
        var uintData: EdsUInt32 = 0
        
        //Enabling private properties
        var error = EdsUInt32(EDS_ERR_OK)
        var propId = kEdsPropID_TempStatus
        error = EdsSetPropertyData(camera, 0x01000000, 0x14840DF1, EdsUInt32(MemoryLayout<EdsUInt32>.size), &propId)
        propId = kEdsPropID_EVF_RollingPitching
        error = EdsSetPropertyData(camera, 0x01000000, 0x05B3740D, EdsUInt32(MemoryLayout<EdsUInt32>.size), &propId)
        propId = kEdsPropID_FixedMovie
        error = EdsSetPropertyData(camera, 0x01000000, 0x17AF25B1, EdsUInt32(MemoryLayout<EdsUInt32>.size), &propId)
        propId = kEdsPropID_MovieParam
        error = EdsSetPropertyData(camera, 0x01000000, 0x2A0C1274, EdsUInt32(MemoryLayout<EdsUInt32>.size), &propId)
        propId = kEdsPropID_Aspect
        error = EdsSetPropertyData(camera, 0x01000000, 0x3FB1718B, EdsUInt32(MemoryLayout<EdsUInt32>.size), &propId)
        propId = kEdsPropID_Evf_ClickWBCoeffs
        error = EdsSetPropertyData(camera, 0x01000000, 0x653048A9, EdsUInt32(MemoryLayout<EdsUInt32>.size), &propId)
        propId = kEdsPropID_Evf_VisibleRect
        error = EdsSetPropertyData(camera, 0x01000000, 0x4D2879F3, EdsUInt32(MemoryLayout<EdsUInt32>.size), &propId)
        propId = kEdsPropID_ManualWhiteBalanceData
        error = EdsSetPropertyData(camera, 0x01000000, 0x20DD3609, EdsUInt32(MemoryLayout<EdsUInt32>.size), &propId)
        propId = kEdsPropID_MirrorUpSetting
        error = EdsSetPropertyData(camera, 0x01000000, 0x517F095D, EdsUInt32(MemoryLayout<EdsUInt32>.size), &propId)
        propId = kEdsPropID_MirrorLockUpState
        error = EdsSetPropertyData(camera, 0x01000000, 0x00E13499, EdsUInt32(MemoryLayout<EdsUInt32>.size), &propId)
        propId = kEdsPropID_UTCTime
        error = EdsSetPropertyData(camera, 0x01000000, 0x51DD2696, EdsUInt32(MemoryLayout<EdsUInt32>.size), &propId)
        propId = kEdsPropID_TimeZone
        error = EdsSetPropertyData(camera, 0x01000000, 0x00FA71F7, EdsUInt32(MemoryLayout<EdsUInt32>.size), &propId)
        propId = kEdsPropID_SummerTimeSetting
        error = EdsSetPropertyData(camera, 0x01000000, 0x09780670, EdsUInt32(MemoryLayout<EdsUInt32>.size), &propId)
        propId = kEdsPropID_AutoPowerOffSetting
        error = EdsSetPropertyData(camera, 0x01000000, 0x1C31565B, EdsUInt32(MemoryLayout<EdsUInt32>.size), &propId)
        propId = kEdsPropID_StillMovieDivideSetting
        error = EdsSetPropertyData(camera, 0x01000000, 0x1EDD16B6, EdsUInt32(MemoryLayout<EdsUInt32>.size), &propId)
        propId = kEdsPropID_CardExtension
        error = EdsSetPropertyData(camera, 0x01000000, 0x4FB44E3C, EdsUInt32(MemoryLayout<EdsUInt32>.size), &propId)
        propId = kEdsPropID_MovieCardExtension
        error = EdsSetPropertyData(camera, 0x01000000, 0x5C6C20B2, EdsUInt32(MemoryLayout<EdsUInt32>.size), &propId)
        propId = kEdsPropID_StillCurrentMedia
        error = EdsSetPropertyData(camera, 0x01000000, 0x139E4D1D,EdsUInt32(MemoryLayout<EdsUInt32>.size), &propId)
        propId = kEdsPropID_MovieCurrentMedia
        error = EdsSetPropertyData(camera, 0x01000000, 0x00D50906, EdsUInt32(MemoryLayout<EdsUInt32>.size), &propId)
        propId = kEdsPropID_FocusShiftSetting
        error = EdsSetPropertyData(camera, 0x01000000, 0x707571DF, EdsUInt32(MemoryLayout<EdsUInt32>.size), &propId)
        propId = kEdsPropID_MovieHFRSetting
        error = EdsSetPropertyData(camera, 0x01000000, 0x44396197, EdsUInt32(MemoryLayout<EdsUInt32>.size), &propId)
  
        
        Thread.sleep(forTimeInterval: 0.5)

        //The communication with the camera begins
        error = EdsOpenSession(camera);
        
        if(error == EdsUInt32(EDS_ERR_OK))
        {
             error = EdsGetPropertyData(camera, EdsPropertyID(kEdsPropID_FixedMovie), 0, EdsUInt32(MemoryLayout<EdsUInt32>.size), &uintData)
             
             if (uintData == 0){
                 var saveTo = kEdsSaveTo_Host
                 error = EdsSetPropertyData(camera, EdsPropertyID(kEdsPropID_SaveTo), 0, EdsUInt32(MemoryLayout<EdsUInt32>.size), &saveTo)
                 
                 if(error == EdsUInt32(EDS_ERR_OK))
                 {
                     var capacity: EdsCapacity = EdsCapacity()
                     capacity.numberOfFreeClusters = 0x7fffffff
                     capacity.bytesPerSector = 0x1000
                     capacity.reset = 1
                     error = EdsSetCapacity(camera, capacity)
                 }
                 
             }else{
                 var saveTo = kEdsSaveTo_Camera
                 error = EdsSetPropertyData(camera, EdsPropertyID(kEdsPropID_SaveTo), 0, EdsUInt32(MemoryLayout<EdsUInt32>.size), &saveTo)
             }
         }
        
    
        //Notification of error
        let viewNotification = ViewNotification()
        return viewNotification.errorNotification(error)
        
    }
}
