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

class DownloadAllFilesCommand : FileCounterCommand{
    
    fileprivate var _model: CameraModel
    fileprivate var _imageItems : Array<EdsDirectoryItemRef> = []
    var targetFileName : String = "DCIM"
    
    override init(model: CameraModel) {
        _model = model
        super.init(model: model)
    }
        
    override func execute()->Bool {
        
        while (true){
            
            var fileCount = 0
            var directoryItem : EdsBaseRef? = nil
            _imageItems = []
            
            var error = countImages(_model.getCameraObject()!,
                                    volumeIndex: _model.getSelectedVolume(),
                                    targetFileName: &targetFileName,
                                    outCount: &fileCount,
                                    outItem : &directoryItem,
                                    outImageItems : &_imageItems )

            if (directoryItem == nil){
                break;
            }
            
            if (error == EdsError(EDS_ERR_OK))
            {
                //_model.setStorageFileNum(fileCount) // Observer will notifiy the update
                var event = CameraEvent( type:.file_COUNT_COMPLETED, arg: fileCount as AnyObject)
                let viewNotification = ViewNotification()
                viewNotification.viewNotificationObservers(&event)
                
                // download
                for fileIndex in 0..<fileCount{
                    if (!_model.getFileTransferring()){
                        var event = CameraEvent(type: .close_PROGRESS, arg: 0 as AnyObject)
                        let viewNotification = ViewNotification()
                        viewNotification.viewNotificationObservers(&event)
                        return true
                    }

                    error = download(Int(fileIndex))
                    
                    if (error != EdsError(EDS_ERR_OK)){
                        var event = CameraEvent(type: .close_PROGRESS, arg: 0 as AnyObject)
                        let viewNotification = ViewNotification()
                        viewNotification.viewNotificationObservers(&event)
                        return true
                    }

                    var event = CameraEvent( type:.file_DOWNLOAD_COMPLETED, arg: 0 as AnyObject)
                    let viewNotification = ViewNotification()
                    viewNotification.viewNotificationObservers(&event)
                }

            }
            else
            {
                var event = CameraEvent( type:.close_PROGRESS, arg: 0 as AnyObject)
                let viewNotification = ViewNotification()
                viewNotification.viewNotificationObservers(&event)
            }
            changeTargetFileName(targetFileName: &targetFileName)
        }
        var event = CameraEvent(type: .close_PROGRESS, arg: 0 as AnyObject)
        let viewNotification = ViewNotification()
        viewNotification.viewNotificationObservers(&event)
        
        return true
    }
    
    func download(_ index : Int)->EdsError{

        let fileItem : EdsDirectoryItemRef? = _imageItems[index]
        
        let path = NSSearchPathForDirectoriesInDomains(.picturesDirectory, .userDomainMask, true)[0] as String
        
        var dirItemInfo = EdsDirectoryItemInfo()
        var error = EdsGetDirectoryItemInfo(fileItem, &dirItemInfo)
        if (error != EdsError(EDS_ERR_OK)){
            return error
        }
        
        var stream : EdsStreamRef? = nil
        
        let itemName = withUnsafePointer(to: &dirItemInfo.szFileName) {
            String(cString: UnsafeRawPointer($0).assumingMemoryBound(to: CChar.self))
        }
        
        let fpath = path + ("/" + itemName)
        
        error = EdsCreateFileStream(fpath, EdsFileCreateDisposition(kEdsFileCreateDisposition_CreateAlways.rawValue), EdsAccess(kEdsAccess_ReadWrite.rawValue), &stream)
        if (error != EdsError(EDS_ERR_OK)){
            return error
        }
        
        error = EdsDownload(fileItem, dirItemInfo.size, stream)
        if (error != EdsError(EDS_ERR_OK)){
            return error
        }
        
        error = EdsDownloadComplete(fileItem)
        if (error != EdsError(EDS_ERR_OK)){
            return error
        }
        
        if(stream != nil){
            EdsRelease(stream)
        }
        
        if(fileItem != nil){
            EdsRelease(fileItem)
        }
        return error
    }
}
