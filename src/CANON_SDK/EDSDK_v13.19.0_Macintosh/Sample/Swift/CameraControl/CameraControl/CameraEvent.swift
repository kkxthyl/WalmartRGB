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

class CameraEvent {
    
    internal enum CameraEventType {
        case error
        case device_BUSY
        case terminate_APP
        case download_EVF
        case evf_DATA_CHANGED
        case property_CHANGED
        case propertydesc_CHANGED
        case download_START
        case download_COMPLETED
        case download_PROGRESS
        case file_COUNT_COMPLETED
        case file_DOWNLOAD_COMPLETED
        case file_DELETE_COMPLETED
        case file_DELETE_CANCEL
        case close_PROGRESS
        case angle_INFO
        case mouse_CURSOR
    }
    
    fileprivate var _type : CameraEventType
    fileprivate var _arg : AnyObject
    
    init(type : CameraEventType, arg : AnyObject){
        _type = type
        _arg = arg
    }
    
    internal func getEvent()->CameraEventType { return _type}
    internal func getArg()->AnyObject { return _arg}
}
