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

class SwitchMirrorUpCommand: Command {
    
    fileprivate var _parameter: EdsInt32
    fileprivate var _model: CameraModel
    
    init(model: CameraModel, parameter: EdsInt32) {
        
        _parameter = parameter
        _model = model
        super.init(model: model)
        
    }
    
    override func execute() -> Bool {

        var error = EdsUInt32(EDS_ERR_OK)
        if (_model.getPropertyUInt32(EdsUInt32(kEdsPropID_MirrorLockUpState)) == kEdsMirrorLockupStateDuringShooting.rawValue)
        {
            return false
        }

        if (_parameter == 1 && _model.getPropertyUInt32(EdsUInt32(kEdsPropID_MirrorLockUpState)) == kEdsMirrorLockupStateDisable.rawValue)
        {
            var mirrorUpSetting = kEdsMirrorUpSettingOn.rawValue
            error = EdsSetPropertyData(_model.getCameraObject(), EdsPropertyID(kEdsPropID_MirrorUpSetting), 0, EdsUInt32(MemoryLayout<EdsUInt32>.size), &mirrorUpSetting)
        }
        else if (_parameter == 0 && _model.getPropertyUInt32(EdsUInt32(kEdsPropID_MirrorLockUpState)) == kEdsMirrorLockupStateEnable.rawValue)
        {
            var mirrorUpSetting = kEdsMirrorUpSettingOff.rawValue
            error = EdsSetPropertyData(_model.getCameraObject(), EdsPropertyID(kEdsPropID_MirrorUpSetting), 0, EdsUInt32(MemoryLayout<EdsUInt32>.size), &mirrorUpSetting)
        }
        else
        {
            // NOP
        }

        //Notification of error
        let viewNotification = ViewNotification()
        return viewNotification.errorNotification(error)
    }
}
