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

class CameraController: NSObject, ActionListener{
    
    fileprivate var _processor : CommandProcessor
    fileprivate var _model : CameraModel
    var clickType : Int = 0
    
    init(model: CameraModel){
        
        _processor = CommandProcessor()
        _model = model
        
        super.init()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.actionPerformed),
                                                         name: Notification.Name(rawValue: "ACTION_PERFORMED_MESSAGE"), object: nil)
    }
    
    internal func getCameraModel()->CameraModel{
        return _model
    }
    
    func run(){
        
        //The communication with the camera begins
        _processor.postCommand(OpenSessionCommand(model: _model))
        
        _processor.postCommand(GetPropertyCommand(model: _model, propertyID: EdsUInt32(kEdsPropID_ProductName)))
        
    }
    
    func postCommand(_ command : Command){
        _processor.postCommand(command)
    }
    
    @objc func actionPerformed(_ event: ActionEvent){
        
        var number: NSNumber
        
        var refObject: ActionEdsRef
        var propertyID: EdsPropertyID
        var point: EdsPoint
        
        switch(event.getActionCommand()){
            
        case .get_PROPERTY:
            number = event.getArg() as! NSNumber
            propertyID = EdsPropertyID(number.int32Value)
            self.postCommand(GetPropertyCommand(model: _model, propertyID: propertyID))
        case .get_PROPERTYDESC:
            number = event.getArg() as! NSNumber
            propertyID = EdsPropertyID(number.int32Value)
            self.postCommand(GetPropertyDescCommand(model: _model, propertyID: propertyID))
        case .download:
            refObject = event.getArg() as! ActionEdsRef
            let dirRef = refObject.getRef()
            self.postCommand(DownloadCommand(model: _model, directoryItem: dirRef))
            
        case .take_PICTURE:
            self.postCommand(TakePictureCommand(model: _model))
        case .press_COMPLETELY:
            self.postCommand(PressShutterCommand(model: _model,
                parameter: EdsInt32(kEdsCameraCommand_ShutterButton_Completely.rawValue)))
        case .focus_FAR1:
            self.postCommand(DriveLensEvfCommand(model: _model, parameter: EdsInt32(kEdsEvfDriveLens_Far1.rawValue)))
        case .focus_FAR2:
            self.postCommand(DriveLensEvfCommand(model: _model, parameter: EdsInt32(kEdsEvfDriveLens_Far2.rawValue)))
        case .focus_FAR3:
            self.postCommand(DriveLensEvfCommand(model: _model, parameter: EdsInt32(kEdsEvfDriveLens_Far3.rawValue)))
        case .focus_NEAR1:
            self.postCommand(DriveLensEvfCommand(model: _model, parameter: EdsInt32(kEdsEvfDriveLens_Near1.rawValue)))
        case .focus_NEAR2:
            self.postCommand(DriveLensEvfCommand(model: _model, parameter: EdsInt32(kEdsEvfDriveLens_Near2.rawValue)))
        case .focus_NEAR3:
            self.postCommand(DriveLensEvfCommand(model: _model, parameter: EdsInt32(kEdsEvfDriveLens_Near3.rawValue)))
        case.evf_AF_ON:
            self.postCommand(DoEvfAFCommand(model: _model,parameter: EdsInt32(kEdsCameraCommand_EvfAf_ON.rawValue)))
        case.evf_AF_OFF:
            self.postCommand(DoEvfAFCommand(model: _model,parameter: EdsInt32(kEdsCameraCommand_EvfAf_OFF.rawValue)))
        case .press_HALFWAY:
            self.postCommand(PressShutterCommand(model: _model,
                                                 parameter: EdsInt32(kEdsCameraCommand_ShutterButton_Halfway.rawValue)))
        case .press_OFF:
            self.postCommand(PressShutterCommand(model: _model,
                parameter: EdsInt32(kEdsCameraCommand_ShutterButton_OFF.rawValue)))
        case .start_EVF:
            _model.setIsEvfEnable(true)
            self.postCommand(StartEvfCommand(model: _model))
        case .end_EVF:
            _model.setIsEvfEnable(false)
            self.postCommand(EndEvfCommand(model: _model))
        case .download_EVF:
            self.postCommand(DownloadEvfCommand(model: _model))
        case .set_AE_MODE:
            propertyID = EdsUInt32(kEdsPropID_AEModeSelect)
            let data = event.getArg() as! NSNumber
            self.postCommand(SetPropertyCommandWithData(model: _model, propertyID: propertyID, data: EdsUInt32(data.int32Value)))
        case .set_TV:
            propertyID = EdsUInt32(kEdsPropID_Tv)
            let data = event.getArg() as! NSNumber
            self.postCommand(SetPropertyCommandWithData(model: _model, propertyID: propertyID, data: EdsUInt32(data.int32Value)))
        case .set_AV:
            propertyID = EdsUInt32(kEdsPropID_Av)
            let data = event.getArg() as! NSNumber
            self.postCommand(SetPropertyCommandWithData(model: _model, propertyID: propertyID, data: EdsUInt32(data.int32Value)))
        case .set_ISO_SPEED:
            propertyID = EdsUInt32(kEdsPropID_ISOSpeed)
            let data = event.getArg() as! NSNumber
            self.postCommand(SetPropertyCommandWithData(model: _model, propertyID: propertyID, data: EdsUInt32(data.int32Value)))
        case .set_METERING_MODE:
            propertyID = EdsUInt32(kEdsPropID_MeteringMode)
            let data = event.getArg() as! NSNumber
            self.postCommand(SetPropertyCommandWithData(model: _model, propertyID: propertyID, data: EdsUInt32(data.int32Value)))
        case .set_EXPOSURE_COMPENSATION:
            propertyID = EdsUInt32(kEdsPropID_ExposureCompensation)
            let data = event.getArg() as! NSNumber
            self.postCommand(SetPropertyCommandWithData(model: _model, propertyID: propertyID, data: EdsUInt32(data.int32Value)))
        case .set_IMAGEQUALITY:
            propertyID = EdsUInt32(kEdsPropID_ImageQuality)
            let data = event.getArg() as! NSNumber
            self.postCommand(SetPropertyCommandWithData(model: _model, propertyID: propertyID, data: EdsUInt32(data.int32Value)))
        case .set_EVF_AFMODE:
            // When switching a EVF AF MODE, cancel EVF AF ON
            self.postCommand(DoEvfAFCommand(model: _model,parameter: EdsInt32(kEdsCameraCommand_EvfAf_OFF.rawValue)))
            propertyID = EdsUInt32(kEdsPropID_Evf_AFMode)
            let data = event.getArg() as! NSNumber
            self.postCommand(SetPropertyCommandWithData(model: _model, propertyID: propertyID, data: EdsUInt32(data.int32Value)))
        case .set_WHITE_BALANCE:
            propertyID = EdsUInt32(kEdsPropID_WhiteBalance)
            let data = event.getArg() as! NSNumber
            self.postCommand(SetPropertyCommandWithData(model: _model, propertyID: propertyID, data: EdsUInt32(data.int32Value)))
        case .set_DRIVE_MODE:
            propertyID = EdsUInt32(kEdsPropID_DriveMode)
            let data = event.getArg() as! NSNumber
            self.postCommand(SetPropertyCommandWithData(model: _model, propertyID: propertyID, data: EdsUInt32(data.int32Value)))
        case .set_AF_MODE:
            propertyID = EdsUInt32(kEdsPropID_AFMode)
            let data = event.getArg() as! NSNumber
            self.postCommand(SetPropertyCommandWithData(model: _model, propertyID: propertyID, data: EdsUInt32(data.int32Value)))
        case .set_STROBO:
            propertyID = EdsUInt32(kEdsPropID_DC_Strobe)
            let data = event.getArg() as! NSNumber
            self.postCommand(SetPropertyCommandWithData(model: _model, propertyID: propertyID, data: EdsUInt32(data.int32Value)))
        case .set_MOVIEQUALITY:
            propertyID = EdsUInt32(kEdsPropID_MovieParam)
            let data = event.getArg() as! NSNumber
            self.postCommand(SetPropertyCommandWithData(model: _model, propertyID: propertyID, data: EdsUInt32(data.int32Value)))
        case .set_MOVIE_HFR:
            propertyID = EdsUInt32(kEdsPropID_MovieHFRSetting)
            let data = event.getArg() as! NSNumber
            self.postCommand(SetPropertyCommandWithData(model: _model, propertyID: propertyID, data: EdsUInt32(data.int32Value)))
        case .set_PICTURESTYLE:
            propertyID = EdsUInt32(kEdsPropID_PictureStyle)
            let data = event.getArg() as! NSNumber
            self.postCommand(SetPropertyCommandWithData(model: _model, propertyID: propertyID, data: EdsUInt32(data.int32Value)))
        case .set_ASPECT:
            propertyID = EdsUInt32(kEdsPropID_Aspect)
            let data = event.getArg() as! NSNumber
            self.postCommand(SetPropertyCommandWithData(model: _model, propertyID: propertyID, data: EdsUInt32(data.int32Value)))
            
        case .click_WB:
            self.postCommand(ClickWBCommand(model: _model, parameter: 1))
            clickType = 1;
        case .click_MOUSE_WB:
            self.postCommand(ClickWBCommand(model: _model, parameter: 2))
        case .click_AF:
            clickType = 2;
            self.postCommand(ClickAFCommand(model: _model, parameter: 1))
        case .click_MOUSE_AF:
            self.postCommand(ClickAFCommand(model: _model, parameter: 2))
    
        case .zoom_FIT:
            propertyID = EdsUInt32(kEdsPropID_Evf_Zoom)
            let data = kEdsEvfZoom_Fit
            self.postCommand(SetPropertyCommandWithData(model: _model, propertyID: propertyID, data: data))
        case .zoom_ZOOM:
            propertyID = EdsUInt32(kEdsPropID_Evf_Zoom)
            // Set the magnification that can be used for the camera body
            let data = kEdsEvfZoom_x5
            //  let data = kEdsEvfZoom_x6
            self.postCommand(SetPropertyCommandWithData(model: _model, propertyID: propertyID, data: data))
        case .set_ZOOM:
            propertyID = EdsUInt32(kEdsPropID_DC_Zoom)
            let data = event.getArg() as! NSNumber
            self.postCommand(SetPropertyCommandWithData(model: _model, propertyID: propertyID, data: EdsUInt32(data.int32Value)))
        case .zoom_UP, .zoom_DOWN:
            let stepY: Int32 = 128
            point = _model.evfZoomPosition()
            if (event.getActionCommand() == .zoom_UP)
            {
                point.y -= stepY
                if (point.y < 0)
                {
                    point.y = 0
                }
            }
            if (event.getActionCommand() == .zoom_DOWN)
            {
                point.y += stepY
            }
            propertyID = EdsUInt32(kEdsPropID_Evf_ZoomPosition)
            let data = point
            self.postCommand(SetPropertyCommandWithData(model: _model, propertyID: propertyID, data: data))
        case .zoom_LEFT, .zoom_RIGHT:
            let stepX: Int32 = 128
            point = _model.evfZoomPosition()
            if (event.getActionCommand() == .zoom_LEFT)
            {
                point.x -= stepX
                if (point.x < 0)
                {
                    point.x = 0
                }
            }
            if (event.getActionCommand() == .zoom_RIGHT)
            {
                point.x += stepX
            }
            propertyID = EdsUInt32(kEdsPropID_Evf_ZoomPosition)
            let data = point
            self.postCommand(SetPropertyCommandWithData(model: _model, propertyID: propertyID, data: data))
        case .download_ALLFILES:
            self.postCommand(DownloadAllFilesCommand(model: _model))
        case .delete_ALLFILES:
            self.postCommand(DeleteAllFilesCommand(model: _model))
        case .format_VOLUME:
            self.postCommand(FormatVolumeCommand(model: _model))
        case .remoteshooting_START:
            self.postCommand(SetRemoteShootingCommand(model: _model, parameter: EdsInt32(1)))
        case .remoteshooting_END:
            self.postCommand(SetRemoteShootingCommand(model: _model, parameter: EdsInt32(0)))
        case .rool_PITCH:
            if (_model.getIsEvfEnable())
            {
                if (_model.getPropertyUInt32(EdsUInt32(kEdsPropID_EVF_RollingPitching)) == 0)
                {
                    _model.SetProperty(EdsUInt32(kEdsPropID_EVF_RollingPitching), property: 1)
                }
                else
                {
                    _model.SetProperty(EdsUInt32(kEdsPropID_EVF_RollingPitching), property: 0)
                }
            }
            self.postCommand(SetRollPitchCommand(model: _model, parameter: kEdsCameraCommand_RequestRollPitchLevel))
        case .shut_DOWN:
            disconnectAlert()
            NotificationCenter.default.removeObserver(self)
            NSApp.stopModal()
            NSApp.abortModal()
            NSApp.terminate(NSApp.windows)
        case .press_STILL:
            self.postCommand(SwitchStillMovieCommand(model: _model, parameter: kEdsCameraCommand_MovieSelectSwOFF))
        case .press_MOVIE:
            self.postCommand(SwitchStillMovieCommand(model: _model, parameter: kEdsCameraCommand_MovieSelectSwON))
        case .rec_START:
            self.postCommand(SetRecCommand(model: _model, parameter: EdsInt32(4)))
        case .rec_END:
            self.postCommand(SetRecCommand(model: _model, parameter: EdsInt32(0)))
            self.postCommand(SwitchStillMovieCommand(model: _model, parameter: kEdsCameraCommand_MovieSelectSwOFF))
        case .mirrorup_ON:
            self.postCommand(SwitchMirrorUpCommand(model: _model, parameter: EdsInt32(kEdsMirrorUpSettingOn.rawValue)))
        case .mirrorup_OFF:
            self.postCommand(SwitchMirrorUpCommand(model: _model, parameter: EdsInt32(kEdsMirrorUpSettingOff.rawValue)))
        default:
            break;
            
        }
        
    }
    
    func disconnectAlert(){
        let alert = NSAlert()
        alert.addButton(withTitle: "OK")
        alert.messageText = "Camera is disconnected"
        alert.runModal()
    }
    
}
