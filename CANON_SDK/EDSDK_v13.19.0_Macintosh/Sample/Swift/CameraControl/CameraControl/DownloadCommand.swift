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

class DownloadCommand: Command {
    
    fileprivate var _directoryItem: EdsDirectoryItemRef? = nil
    fileprivate var _model: CameraModel
    
    init(model: CameraModel, directoryItem: EdsDirectoryItemRef) {
        
        _model = model
         _directoryItem = directoryItem
        
        super.init(model: model)
    
    }
    
    override func execute() -> Bool {
        
        if (_model.getCanDownloadImage() == false)
        {
            return true
        }
        
        var error: EdsError = EdsUInt32(EDS_ERR_OK)
        var stream: EdsStreamRef? = nil
        var directoryItemInfo: EdsDirectoryItemInfo = EdsDirectoryItemInfo()
       
        var number: NSNumber
        let viewNotification = ViewNotification()
        
        
        let bundlePath = Bundle.main.bundlePath as NSString
        let path = NSSearchPathForDirectoriesInDomains(.picturesDirectory, .userDomainMask, true)[0] as String
        
        //Acquisition of the downloaded image information
        error = EdsGetDirectoryItemInfo(_directoryItem, &directoryItemInfo)
        
        
        // Forwarding beginning notification
        if(error == EdsUInt32(EDS_ERR_OK))
        {
            number = NSNumber.init(value: 0 as Int32)
            var event = CameraEvent(type:.download_START, arg: number)
            viewNotification.viewNotificationObservers(&event)
           
        }
        
        //Make the file stream at the forwarding destination
        if(error == EdsUInt32(EDS_ERR_OK))
        {
            
            let itemName = withUnsafePointer(to: &directoryItemInfo.szFileName) {
                String(cString: UnsafeRawPointer($0).assumingMemoryBound(to: CChar.self))
            
            }
            
            let fpath = path + ("/" + itemName)
            error = EdsCreateFileStream(fpath,
                                        kEdsFileCreateDisposition_CreateAlways,
                                        kEdsAccess_ReadWrite, &stream)
        }

        //Set Progress
        if(error == EdsUInt32(EDS_ERR_OK))
        {
            let command: UnsafeMutableRawPointer = unsafeBitCast(self, to: UnsafeMutableRawPointer.self)
            let progressCallback: EdsProgressCallback = unsafeBitCast(ProgressFunc, to: EdsProgressCallback.self)
            error = EdsSetProgressCallback(stream, progressCallback, kEdsProgressOption_Periodically, command);
        }
        
        //Download image
        if(error == EdsUInt32(EDS_ERR_OK))
        {
            error = EdsDownload(_directoryItem, directoryItemInfo.size, stream)
        }
        
        //Forwarding completion
        if(error == EdsUInt32(EDS_ERR_OK))
        {
            error = EdsDownloadComplete(_directoryItem);
        }
        
        if(_directoryItem != nil)
        {
            error = EdsRelease(_directoryItem)
            _directoryItem = nil
        }
        
        //Release stream
        if(stream != nil)
        {
            EdsRelease(stream);
            stream = nil
        }
        
        // Forwarding completion notification
        if(error == EdsUInt32(EDS_ERR_OK))
        {
            number = NSNumber.init(value: 0 as Int32)
            var event = CameraEvent(type:.download_COMPLETED, arg: number as AnyObject)
            viewNotification.viewNotificationObservers(&event)
        }
        
        //Notification of error
        if(error != EdsUInt32(EDS_ERR_OK))
        {
            let obj: NSInteger = NSInteger(error)
            var event = CameraEvent( type:.error, arg: obj as AnyObject)
            viewNotification.viewNotificationObservers(&event)
        }

        return true
        
    }

    let ProgressFunc: @convention(c) (EdsUInt32, UnsafeMutableRawPointer, UnsafeMutablePointer<EdsBool>)->EdsError = {
        (inPercent, inContext, outCancel) -> EdsError in
        
        let viewNotification = ViewNotification()
            
        let obj: NSInteger = NSInteger(inPercent)
        var event = CameraEvent(type:.download_PROGRESS, arg: obj as AnyObject)
        viewNotification.viewNotificationObservers(&event)
            
        return 0
    }
    
}
