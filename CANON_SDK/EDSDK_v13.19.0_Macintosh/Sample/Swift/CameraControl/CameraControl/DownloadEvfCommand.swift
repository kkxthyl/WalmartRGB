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

class DownloadEvfCommand: Command {
    
    fileprivate var _model: CameraModel
    
    override init(model: CameraModel) {
        
        _model = model
        super.init(model: model)
        
    }
    
    override func execute() -> Bool {
        
        var error:EdsError = EdsUInt32(EDS_ERR_OK)
        var streamRef: EdsStreamRef? = nil
        var imageRef: EdsEvfImageRef? = nil
        let bufferSize:EdsUInt64  = 2 * 1024 * 1024;
        var zoom: EdsUInt32 = 0
        var zoomRect: EdsRect = EdsRect()
        var imagePosition: EdsPoint = EdsPoint()
        var sizeJpegLarge: EdsSize = EdsSize()
        var visibleRect: EdsRect = EdsRect()
        
        var evfData: CameraEvfData!
        
        
        // Exit unless during live view.
        if( (_model.evfOutputDevice() & kEdsEvfOutputDevice_PC.rawValue) == 0)
        {
        return true
        }
        
        Thread.sleep(forTimeInterval: 0.1)
        
        // Create memory stream.
        error = EdsCreateMemoryStream(bufferSize, &streamRef)
        
        
        // Create EvfImageRef.
        if(error == EdsError(EDS_ERR_OK))
        {
            error = EdsCreateEvfImageRef(streamRef, &imageRef)
        }
        
        // Download live view image data.
        if(error == EdsError(EDS_ERR_OK))
        {
            error = EdsDownloadEvfImage(_model.getCameraObject(), imageRef)
        }
        
        // Get meta data for live view image data.
        if(error == EdsError(EDS_ERR_OK))
        {
            
            evfData = CameraEvfData()
           // evfData.setStream(streamRef)
            
            // Get magnification ratio (x1, x5, or x10).
            EdsGetPropertyData(imageRef, EdsUInt32(kEdsPropID_Evf_Zoom), 0, EdsUInt32(MemoryLayout<EdsUInt32>.size), &zoom)
            evfData.setZoom(zoom)
            
            EdsGetPropertyData(imageRef, EdsUInt32(kEdsPropID_Evf_ZoomRect), 0, EdsUInt32(MemoryLayout<EdsRect>.size), &zoomRect)
            evfData.setZoomRect(zoomRect)
            
            // Get position of image data. (when enlarging)
            // Upper left coordinate using JPEG Large size as a reference.
            EdsGetPropertyData(imageRef, EdsUInt32(kEdsPropID_Evf_ImagePosition), 0, EdsUInt32(MemoryLayout<EdsPoint>.size), &imagePosition);
            evfData.setImagePosition(imagePosition)
            
            // Set the size of Jpeg Large.
            EdsGetPropertyData(imageRef, EdsUInt32(kEdsPropID_Evf_CoordinateSystem), 0,  EdsUInt32(MemoryLayout<EdsSize>.size), &sizeJpegLarge);
            evfData.setSizeJpeglarge(sizeJpegLarge)
            // Set JPEG L size
            _model.setSizeJpeglarge(sizeJpegLarge)
            
            EdsGetPropertyData(imageRef, EdsUInt32(kEdsPropID_Evf_VisibleRect), 0,
                EdsUInt32(MemoryLayout<EdsRect>.size), &visibleRect);
            evfData.setVisibleRect(visibleRect)
            
            
            // Set to model.
            _model.setEvfZoom(zoom)
            _model.setEvfZoomPosition(zoomRect.point)
            
            // Live view image transfer complete notification.
            if(error == EdsError(EDS_ERR_OK))
            {
                
                var imageSize: EdsUInt64 = 0
                var pImage: UnsafeMutableRawPointer? = nil
                
                EdsGetPointer(streamRef, &pImage)
                EdsGetLength(streamRef, &imageSize)
                
                evfData.setStream(Data.init(bytes: UnsafeMutableRawPointer(pImage)!, count: Int(imageSize)))
                
                var event = CameraEvent(type:.evf_DATA_CHANGED, arg: evfData)
                let viewNotification = ViewNotification()
                viewNotification.viewNotificationObservers(&event)
                
            }
            
            // Get Evf_RollingPitching data.
            if (error == EdsError(EDS_ERR_OK))
            {
                if (0 == _model.getPropertyUInt32(EdsUInt32(kEdsPropID_EVF_RollingPitching)))
                {
                    var cameraPos: EdsCameraPos = EdsCameraPos()
                    error = EdsGetPropertyData(imageRef, EdsPropertyID(kEdsPropID_EVF_RollingPitching), 0, EdsUInt32(MemoryLayout<EdsCameraPos>.size), &cameraPos)
                    if (error == EdsError(EDS_ERR_OK))
                    {
                        var event = CameraEvent(type:.angle_INFO, arg: cameraPos as AnyObject)
                        let viewNotification = ViewNotification()
                        viewNotification.viewNotificationObservers(&event)
                    }
                }
            }
            
            // Live view image transfer complete notification.
            if(streamRef != nil)
            {
                EdsRelease(streamRef)
            }
            
            if(imageRef != nil)
            {
                EdsRelease(imageRef)
                
            }
        }
        
        if(streamRef != nil)
        {
            EdsRelease(streamRef)
            
        }
        
        if(imageRef != nil)
        {
            EdsRelease(imageRef)
            
        }
        
        //Notification of error
        if(error != EdsError(EDS_ERR_OK))
        {
            
            // Retry getting image data if EDS_ERR_OBJECT_NOTREADY is returned
            // when the image data is not ready yet.
            if(error == EdsError(EDS_ERR_OBJECT_NOTREADY))
            {
                return false
            }
            
        }
            
        //Notification of error(Retry)
        let viewNotification = ViewNotification()
        return viewNotification.errorNotificationWithRetry(error)
        
    }
}
