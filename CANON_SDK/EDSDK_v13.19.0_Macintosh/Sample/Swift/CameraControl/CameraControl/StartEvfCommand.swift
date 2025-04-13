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

class StartEvfCommand: Command {
    
    fileprivate var _model: CameraModel
    
    override init(model: CameraModel) {
        
        _model = model
        super.init(model: model)
        
    }
    
    override func execute() -> Bool {
        
        var error: EdsError = EdsUInt32(EDS_ERR_OK)
        var device: EdsUInt32 = 0
        var evfMode: EdsUInt32
        
        // Change settings because live view cannot be started
        // when camera settings are set to “do not perform live view.”
        evfMode = _model.evfMode()
        
        if(evfMode == 0)
        {
            evfMode = 1
            
            // Set to the camera.
            error = EdsSetPropertyData(_model.getCameraObject(), EdsPropertyID(kEdsPropID_Evf_Mode), 0, EdsUInt32(MemoryLayout<EdsUInt32>.size), &evfMode)
        }
        
        if(error == EdsError(EDS_ERR_OK)){
            
            // Get the current output device.
            device = _model.evfOutputDevice()
            
            device |= kEdsEvfOutputDevice_PC.rawValue
            
            // When to use small live view pictures
            //device |= kEdsEvfOutputDevice_PC_Small.rawValue;
                /*
                 In addition, Replace the definition `kEdsEvfOutputDevice_PC` to `kEdsEvfOutputDevice_PC_Small` in the following file as well
                  * DownloadEvfCommand.swift
                  * EndEvfCommand.swift
                */
            
            error = EdsSetPropertyData(_model.getCameraObject(), EdsPropertyID(kEdsPropID_Evf_OutputDevice), 0, EdsUInt32(MemoryLayout<EdsUInt32>.size), &device)
            
            _model.setEvfOutputDevice(device)
            
        }
        
        //Notification of error
        let viewNotification = ViewNotification()
        return viewNotification.errorNotification(error)
    }
}
