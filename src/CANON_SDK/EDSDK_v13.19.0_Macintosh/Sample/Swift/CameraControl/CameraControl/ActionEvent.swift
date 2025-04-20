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

open class ActionEvent: NSObject {
    
    public enum Command {
        
        case none
        case download
        case take_PICTURE
        case set_CAMERASETTING
        case press_COMPLETELY
        case press_HALFWAY
        case press_OFF
        case start_EVF
        case end_EVF
        case get_PROPERTY
        case get_PROPERTYDESC
        case download_EVF
        case set_AE_MODE
        case set_DRIVE_MODE
        case set_FLASHOPTION
        case set_FLASHOUTPUT
        case set_MUTE
        case set_AFASSISTBEAM
        case set_REDEYELAMP
        case set_WHITE_BALANCE
        case set_METERING_MODE
        case set_EXPOSURE_COMPENSATION
        case set_IMAGEQUALITY
        case set_AV
        case set_TV
        case set_LED
        case set_ISO_SPEED
        case set_ASPECT_RATIO
        case set_EVF_AFMODE
        case set_ZOOM
        case set_AF_MODE
        case set_STROBO
        case set_MOVIEQUALITY
        case set_MOVIE_HFR
        case set_PICTURESTYLE
        case set_ASPECT
        case evf_AF_ON
        case evf_AF_OFF
        case focus_NEAR1
        case focus_NEAR2
        case focus_NEAR3
        case focus_FAR1
        case focus_FAR2
        case focus_FAR3
        case zoom_FIT
        case zoom_ZOOM
        case zoom_UP
        case zoom_LEFT
        case zoom_RIGHT
        case zoom_DOWN
        case download_ALLFILES
        case delete_ALLFILES
        case format_VOLUME
        case remoteshooting_START
        case remoteshooting_END
        case rool_PITCH
        case press_STILL
        case press_MOVIE
        case rec_START
        case rec_END
        case click_WB
        case click_MOUSE_WB
        case click_AF
        case click_MOUSE_AF
        case mirrorup_ON
        case mirrorup_OFF
        case shut_DOWN

    }

    
    fileprivate var _command: Command
    fileprivate var _object: AnyObject

    init(command: Command, object: AnyObject){
        
        self._command = command
        self._object = object
        
    }
    
    func getActionCommand() -> Command { return _command }
       
    func getArg() -> AnyObject { return _object }
    
    
}


open class ActionEdsRef{
    
    var _ref: EdsBaseRef
    
    init(ref: EdsBaseRef){
        
        _ref = ref
        
    }
    
    func getRef() -> EdsBaseRef{ return _ref }
    
}
