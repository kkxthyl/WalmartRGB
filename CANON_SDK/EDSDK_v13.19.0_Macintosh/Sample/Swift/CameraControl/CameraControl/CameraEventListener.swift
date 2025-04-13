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

open class CameraEventListener: NSObject{
    
    class func fireEvent(_ listener: CameraController, event: ActionEvent)
    {
        listener.actionPerformed(event)
    }
}

let handleObjectEvent : @convention(c)( EdsObjectEvent, EdsBaseRef, UnsafeMutableRawPointer?)->EdsError = {
    (inEvent, inRef, inContext) -> EdsError in
    
    var error = EdsError(EDS_ERR_OK)
    let controller: CameraController! = unsafeBitCast(inContext, to: CameraController.self)
    
    
    switch(inEvent)
    {
    case //EdsObjectEvent(kEdsObjectEvent_DirItemCreated),
         EdsObjectEvent(kEdsObjectEvent_DirItemRequestTransfer):
        
        let refObject = ActionEdsRef(ref: inRef)
        CameraEventListener.fireEvent(controller, event: ActionEvent(command: .download, object: refObject))
        
    default:
        //Object without the necessity is released
        // Warning: Comparing non-optional value of type 'EdsBaseRef' (aka 'OpaquePointer') to nil always returns true
//        if(inRef != nil)
//        {
            EdsRelease(inRef);
//        }
    }
    return error;
}

let handlePropertyEvent : @convention(c) (EdsPropertyEvent, EdsPropertyID, EdsUInt32, UnsafeMutableRawPointer)->EdsError = {
    (inEvent, inPropertyID, inParam, inContext) -> EdsError in
    
    var error = EdsError(EDS_ERR_OK)
    let controller: CameraController! = unsafeBitCast(inContext, to: CameraController.self)
    
    switch(inEvent)
    {
    case EdsPropertyEvent(kEdsPropertyEvent_PropertyChanged):
        var obj: NSInteger = NSInteger(inPropertyID)
        CameraEventListener.fireEvent(controller, event: ActionEvent(command: .get_PROPERTY, object: obj as AnyObject))
    case EdsPropertyEvent(kEdsPropertyEvent_PropertyDescChanged):
        let obj: NSInteger = NSInteger(inPropertyID)
        CameraEventListener.fireEvent(controller, event: ActionEvent(command: .get_PROPERTYDESC, object: obj as AnyObject))
    default:
        break
    }
    
    return error
}

let handleStateEvent : @convention(c) ( EdsStateEvent, EdsUInt32, UnsafeMutableRawPointer)->EdsError = {
    ( inEvent, inParam, inContext)->EdsError in
    
    var error = EdsError(EDS_ERR_OK)
    let controller: CameraController! = unsafeBitCast(inContext, to: CameraController.self)

    switch(inEvent)
    {
    case EdsStateEvent(kEdsStateEvent_Shutdown):
        CameraEventListener.fireEvent(controller, event: ActionEvent(command: .shut_DOWN, object: 0 as AnyObject))
    default:
        break;
    }
    return error;
}

