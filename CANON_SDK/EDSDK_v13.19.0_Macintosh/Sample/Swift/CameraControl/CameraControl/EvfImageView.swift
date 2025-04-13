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

class EvfImageView: NSImageView {
    
    fileprivate var _model : CameraModel? = nil
    fileprivate var _isLiveViewActive: Bool = false
    fileprivate var _afFrameInfo: EdsFocusInfo = EdsFocusInfo()
    fileprivate var _afFrameArray = Array<EdsFocusPoint>()
    fileprivate var _afMode: EdsUInt32 = 0
    fileprivate var _focusRect: NSRect = NSRect()
    fileprivate var _zoom: EdsUInt32 = 0
    fileprivate var _zoomRect: EdsRect = EdsRect()
    fileprivate var _aspectRatio: UInt32 = 0
    fileprivate var _sizeJpeglarge: EdsSize = EdsSize()
    fileprivate var _visibleRect: EdsRect = EdsRect()
    fileprivate var aspratio: EdsUInt32 = 0
    fileprivate var rect_width: EdsInt32 = 0
    fileprivate var rect_height: EdsInt32 = 0
    fileprivate var rectRight: NSRect = NSRect()
    fileprivate var rectLeft: NSRect = NSRect()
    fileprivate var rectTop: NSRect = NSRect()
    fileprivate var rectBottom: NSRect = NSRect()
    
    init(frameRect: NSRect) {
        super.init(frame: frameRect)
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.image = nil
    }
    
    func drawImage(_ model: CameraModel, arg: AnyObject){
        
        _model = model
        _afFrameInfo = model.focusInfo()
        var xRatio: Float = 1
        var yRatio: Float = 1
        let windowRect: NSRect = self.bounds
        
        xRatio = Float(windowRect.size.width)/(Float(_afFrameInfo.imageRect.size.width))
        yRatio = Float(windowRect.size.height)/(Float(_afFrameInfo.imageRect.size.height))
    
        _afFrameArray = self.getFocusPoint(_afFrameInfo)
        
        for i in 0..<_afFrameInfo.pointNumber
        {
            let workValue: EdsFocusPoint = _afFrameArray[Int(i)]
            _afFrameArray[Int(i)].rect.size.width = Int32(Float(workValue.rect.size.width) * xRatio)
            _afFrameArray[Int(i)].rect.size.height = Int32(Float(workValue.rect.size.height) * yRatio)
            _afFrameArray[Int(i)].rect.point.x = Int32(Float(workValue.rect.point.x) * xRatio)
            _afFrameArray[Int(i)].rect.point.y = Int32((Float(windowRect.size.height) - Float(workValue.rect.point.y) * yRatio)
            - Float(_afFrameArray[Int(i)].rect.size.height))
            
        }

        
        let evfData: CameraEvfData = arg as! CameraEvfData
        
        _zoom = evfData.zoom()
        _afMode =  model.evfAFMode()
        _zoomRect = evfData.zoomRect()
        _sizeJpeglarge = evfData.sizeJpeglarge()
        _visibleRect = evfData.visibleRect()
        aspratio = _model!.getPropertyUInt32(EdsUInt32(kEdsPropID_Aspect))
        rect_width = _visibleRect.size.width
        rect_height = _visibleRect.size.height
        
        let liveviewRect: NSRect = self.bounds
        let iWidth: CGFloat = liveviewRect.size.width
        let iHeight: CGFloat = liveviewRect.size.height
      
        
        //When aspect ratio is 1:1 or 4:3
        if(aspratio == 1 || aspratio == 2)
        {
            var hvRatio: Float = 0
            var rWidth: CGFloat = 0
            hvRatio = Float(rect_width)/(Float(rect_height))
            rWidth = (iWidth - iHeight * CGFloat(hvRatio)) / 2
            
            rectLeft = NSRect(x: 0, y: 0, width: rWidth, height: iHeight)
            rectRight = NSRect(x: (rWidth + iHeight * CGFloat(hvRatio)), y: 0, width: rWidth, height: iHeight)
            
        }
        
        //When aspect ratio is 16:9
        if(aspratio == 7)
        {
            var vhRatio: Float = 0
            var rHeight: CGFloat = 0
            vhRatio = Float(rect_height)/(Float(rect_width))
            rHeight = (iHeight - iWidth * CGFloat(vhRatio)) / 2
            
            rectTop = NSRect(x: 0, y: 0, width: iWidth, height: rHeight)
            rectBottom = NSRect(x: 0, y: (rHeight + iWidth * CGFloat(vhRatio)), width: iWidth, height: rHeight)
            
        }
        
        if (_model?.getIsEvfEnable())!
        {
            self.image = NSImage.init(data: evfData.strem() as Data)
            self.animates = true
        }
        else
        {
            self.image = nil
        }
    }
    
    func getFocusPoint(_ focusInfo: EdsFocusInfo) -> Array<EdsFocusPoint> {
        
        let test = focusInfo.focusPoint
        return Mirror(reflecting: test).children.map { $0.value as! EdsFocusPoint }
        
    }
    
    
    func resizeImage(_ image: NSImage, maxSize: NSSize) -> NSImage{
        
        let imageWidth = Float(image.size.width)
        let imageHeight = Float(image.size.height)
        let maxWidth = Float(maxSize.width)
        let maxHeight = Float(maxSize.height)
        
        let aspectWidth = maxWidth / imageWidth
        let aspectHeight = maxHeight / imageHeight
        let ratio = min(aspectWidth, aspectHeight)
        
        let newWidth = imageWidth * ratio
        let newHeight = imageHeight * ratio
        
        let newSize: NSSize = NSSize(width: Int(newWidth), height: Int(newHeight))
        
        var imageRect: CGRect = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
        
        let imageRef = image.cgImage(forProposedRect: &imageRect, context: nil, hints: nil)
        
        let imageWithNewSize = NSImage(cgImage: imageRef!, size: newSize)
        
        return imageWithNewSize
        
    }
    
    func setZoomRect()
    {
        // The zoomPosition is given by the coordinates of the upper left of the focus border using Jpeg Large size as a reference.
    
        // The size of the focus border is one fifth the size of Jpeg Large.
        // Because the image fills the entire window, the height and width to be drawn is one fifth of the window size.
    
        let imageWidth: CGFloat = CGFloat(self._sizeJpeglarge.width)
        let imageHeight: CGFloat = CGFloat(self._sizeJpeglarge.height)
        let windowRect: NSRect = self.bounds
            
        // width coordinate to be drawn.
        _focusRect.size.width = CGFloat(self._zoomRect.size.width) * windowRect.size.width / imageWidth
        // height coordinate to be drawn.
        _focusRect.size.height = CGFloat(self._zoomRect.size.height) * windowRect.size.height / imageHeight
            
        // Lower left coordinate to be drawn.
        _focusRect.origin.x = CGFloat(self._zoomRect.point.x) * windowRect.size.width / imageWidth
        _focusRect.origin.y = windowRect.height - (CGFloat(self._zoomRect.point.y) * windowRect.size.height / imageHeight)
        _focusRect.origin.y -= _focusRect.size.height
        
    }
    
    override func draw(_ rect: NSRect) {
        
        super.draw(rect)
        
  
        //Draw black Rect for aspect ratio(1:1 or 4:3)
        if((aspratio == 1 || aspratio == 2) && (_model?.getIsEvfEnable())!)
        {
            NSColor.black.set()
            NSBezierPath.fill(rectLeft)
            NSBezierPath.fill(rectRight)
        }
        //Draw black Rect for aspect ratio(16:9)
        if((aspratio == 7) && (_model?.getIsEvfEnable())!)
        {
            NSColor.black.set()
            NSBezierPath.fill(rectTop)
            NSBezierPath.fill(rectBottom)
        }
        
        
        NSBezierPath.defaultLineWidth=1.5
        if(_zoom == 1 && (_model?.getIsEvfEnable())!)
        {
            // Draw Zoom Rect
            if(_afMode != 2 && (_model?.getIsTypeDS())!)
            {
                setZoomRect()

                NSColor.white.set()
                NSBezierPath.stroke(_focusRect)
            }
            
            // Draw AF Frames
            for i in 0..<_afFrameInfo.pointNumber{
                
                let workValue: EdsFocusPoint = _afFrameArray[Int(i)]
               
                if(workValue.valid == 1) {
                    
                    // Selecte Just Focus Pen
                    if((workValue.justFocus & 0x0f) == 1) {
                        NSColor.green.set()
                    } else if((workValue.justFocus & 0x0f) == 2) {
                        NSColor.red.set()
                    } else if((workValue.justFocus & 0x0f) == 4) {
                        NSColor(red: 0.25490, green: 0.58039, blue: 0.90980, alpha: 1.0).set()
                    } else {
                        NSColor.white.set()
                    }
                    if(workValue.selected != 1)
                    {
                        NSColor.gray.set()
                    }
                    // Set Frame Rect
                    var frame: NSRect = NSRect(x: 0, y: 0, width: 0, height: 0)
                    frame.origin.x = CGFloat(workValue.rect.point.x)
                    frame.origin.y = CGFloat(workValue.rect.point.y)
                    frame.size.width = CGFloat(workValue.rect.size.width)
                    frame.size.height = CGFloat(workValue.rect.size.height)
                    NSBezierPath.stroke(frame)
                
                }
            }
        }
    
    }
    
}

