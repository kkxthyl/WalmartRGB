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

class CameraEvfData: NSObject {
    
    fileprivate var _stream: Data = Data()		// JPEG stream
    fileprivate var _zoom: EdsUInt32 = 1
    fileprivate var _zoomRect: EdsRect = EdsRect()
    fileprivate var _zoomPosition: EdsPoint = EdsPoint()
    fileprivate var _imagePosition: EdsPoint = EdsPoint()
    fileprivate var _sizeJpeglarge: EdsSize = EdsSize()
    fileprivate var _imageSize: EdsUInt64 = 0
    fileprivate var _visibleRect: EdsRect = EdsRect()
    
    func setImageSize(_ imageSize: EdsUInt64){
        _imageSize = imageSize
    }
    
    func imageSize() -> EdsUInt64{
        return _imageSize
    }
    
    func setStream(_ stream: Data){
        _stream = stream
    }
    
    func setZoom(_ zoom: EdsUInt32)
    {
        _zoom = zoom
    }
    
    func setZoomRect(_ zoomRect: EdsRect)
    {
        _zoomRect = zoomRect
    }
    
    func setZoomPosition(_ zoomPosition: EdsPoint)
    {
        _zoomPosition = zoomPosition
    }
    
    func setImagePosition(_ imagePosition: EdsPoint)
    {
        _imagePosition = imagePosition
    }
    
    func setSizeJpeglarge(_ sizeJpeglarge: EdsSize)
    {
        _sizeJpeglarge = sizeJpeglarge;
    }
    
    func setVisibleRect(_ visibleRect: EdsRect)
    {
        _visibleRect = visibleRect;
    }
    
    func strem() -> Data
    {
    return _stream;
    }
    
    func zoom() -> EdsUInt32
    {
    return _zoom;
    }
    
    func zoomRect() -> EdsRect
    {
    return _zoomRect;
    }
    
    func zoomPosition() -> (EdsPoint)
    {
    return _zoomPosition;
    }
    
    func imgaePosition() -> (EdsPoint)
    {
    return _imagePosition;
    }
    
    func visibleRect() -> EdsRect
    {
        return _visibleRect;
    }
    func sizeJpeglarge() -> (EdsSize)
    {
    return _sizeJpeglarge;
    }
    
}
