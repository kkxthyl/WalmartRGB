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

class CameraModel{
    
    fileprivate var _camera: EdsCameraRef? = nil
    fileprivate let _viewNotification = ViewNotification()
    
    // Model name
    fileprivate var _modelString: Array<EdsChar> = Array(repeating: 32, count: 256)
    func getModelString() -> Array<EdsChar>{
        return _modelString
    }

    // Type DS
    fileprivate var isTypeDS: Bool = false
    func getIsTypeDS() -> Bool{
        return isTypeDS
    }
    
    fileprivate var _ownerName: Array<EdsChar> = Array(repeating: 32, count: 256)
        {didSet{_viewNotification.changeProperty(EdsUInt32(kEdsPropID_OwnerName))}}
   
    fileprivate var canDownloadImage: Bool = true
    
    func getCanDownloadImage() -> Bool{
        return canDownloadImage
    }
    func setCanDownloadImage(_ value: Bool){
        canDownloadImage = value
    }
    
    fileprivate var isEvfEnable: Bool = false
    
    func getIsEvfEnable() -> Bool{
        return isEvfEnable
    }
    func setIsEvfEnable(_ value: Bool){
        isEvfEnable = value
    }
    
    // Taking a picture parameter
    fileprivate var _AEMode: EdsUInt32 = 0
        {didSet{_viewNotification.changeProperty(EdsUInt32(kEdsPropID_AEModeSelect))}}
    fileprivate var _Av: EdsUInt32 = 0
        {didSet{_viewNotification.changeProperty(EdsUInt32(kEdsPropID_Av))}}
    fileprivate var _Tv: EdsUInt32 = 0
        {didSet{_viewNotification.changeProperty(EdsUInt32(kEdsPropID_Tv))}}
    fileprivate var _Iso: EdsUInt32 = 0
        {didSet{_viewNotification.changeProperty(EdsUInt32(kEdsPropID_ISOSpeed))}}
    fileprivate var _MeteringMode: EdsUInt32 = 0
        {didSet{_viewNotification.changeProperty(EdsUInt32(kEdsPropID_MeteringMode))}}
    fileprivate var _ExposureCompensation: EdsUInt32 = 0
        {didSet{_viewNotification.changeProperty(EdsUInt32(kEdsPropID_ExposureCompensation))}}
    fileprivate var _ImageQuality: EdsUInt32 = 0
        {didSet{_viewNotification.changeProperty(EdsUInt32(kEdsPropID_ImageQuality))}}
    fileprivate var _evfMode: EdsUInt32 = 0
    fileprivate var _startupEvfOutputDevice: EdsUInt32 = 0
    fileprivate var _evfOutputDevice: EdsUInt32 = 0xffffffff
        {didSet{_viewNotification.changeEvfData(EdsUInt32(kEdsPropID_Evf_OutputDevice))}}
    
    fileprivate var _evfDepthOfFieldPreview: EdsUInt32 = 0
    fileprivate var _evfAFMode: EdsUInt32 = 0
        {didSet{_viewNotification.changeProperty(EdsUInt32(kEdsPropID_Evf_AFMode))}}
    fileprivate var _availableShots: EdsUInt32 = 0
        {didSet{_viewNotification.changeProperty(EdsUInt32(kEdsPropID_AvailableShots))}}
    fileprivate var _batteryLevel: EdsUInt32 = 0
        {didSet{_viewNotification.changeProperty(EdsUInt32(kEdsPropID_BatteryLevel))}}
    fileprivate var _tempStatusLevel: EdsUInt32 = 0
        {didSet{_viewNotification.changeProperty(EdsUInt32(kEdsPropID_TempStatus))}}
    fileprivate var _rollPitch: EdsUInt32 = 1
        {didSet{_viewNotification.changeProperty(EdsUInt32(kEdsPropID_EVF_RollingPitching))}}
    fileprivate var _fixedMovie: EdsUInt32 = 1
        {didSet{_viewNotification.changeProperty(EdsUInt32(kEdsPropID_FixedMovie))}}
    fileprivate var _mirrorUpSetting: EdsUInt32 = 0xffffffff
        {didSet{_viewNotification.changeProperty(EdsUInt32(kEdsPropID_MirrorUpSetting))}}
    fileprivate var _mirrorLockUpState: EdsUInt32 = 0
        {didSet{_viewNotification.changeProperty(EdsUInt32(kEdsPropID_MirrorLockUpState))}}
    fileprivate var _whiteBalance: EdsUInt32 = 0
        {didSet{_viewNotification.changeProperty(EdsUInt32(kEdsPropID_WhiteBalance))}}
    fileprivate var _driveMode: EdsUInt32 = 0
        {didSet{_viewNotification.changeProperty(EdsUInt32(kEdsPropID_DriveMode))}}
    fileprivate var _AFMode: EdsUInt32 = 0
        {didSet{_viewNotification.changeProperty(EdsUInt32(kEdsPropID_AFMode))}}
    fileprivate var _zoom: EdsUInt32 = 0
         {didSet{_viewNotification.changeProperty(EdsUInt32(kEdsPropID_DC_Zoom))}}
    fileprivate var _flashMode: EdsUInt32 = 0
        {didSet{_viewNotification.changeProperty(EdsUInt32(kEdsPropID_DC_Strobe))}}
    fileprivate var _movieQuality: EdsUInt32 = 0
        {didSet{_viewNotification.changeProperty(EdsUInt32(kEdsPropID_MovieParam))}}
    fileprivate var _movieHFR: EdsUInt32 = 0
        {didSet{_viewNotification.changeProperty(EdsUInt32(kEdsPropID_MovieHFRSetting))}}
    fileprivate var _pictureStyle: EdsUInt32 = 0
        {didSet{_viewNotification.changeProperty(EdsUInt32(kEdsPropID_PictureStyle))}}
    fileprivate var _aspect: EdsUInt32 = 0
        {didSet{_viewNotification.changeProperty(EdsUInt32(kEdsPropID_Aspect))}}
    fileprivate var _clickWB = EdsManualWBData()
        {didSet{_viewNotification.changeProperty(EdsUInt32(kEdsPropID_Evf_ClickWBCoeffs))}}
    fileprivate var _clickPoint: EdsInt32 = 0
    func getClickPoint() -> EdsInt32{
        return _clickPoint
    }
    func setClickPoint(_ value:EdsInt32){
        _clickPoint = value
    }
    fileprivate var _autoPowerOff: EdsUInt32 = 0
        {didSet{_viewNotification.changeProperty(EdsUInt32(kEdsPropID_AutoPowerOffSetting))}}

    fileprivate var _sizeJpeglarge: EdsSize = EdsSize()
    func getSizeJpeglarge() -> EdsSize{
        return _sizeJpeglarge
    }
    func setSizeJpeglarge(_ value:EdsSize){
        _sizeJpeglarge = value
    }
    
    // List of value in which taking a picture parameter can be set
    fileprivate var _AEModeDesc: EdsPropertyDesc = EdsPropertyDesc()
        {didSet{_viewNotification.changePropertyDesc(EdsUInt32(kEdsPropID_AEModeSelect))}}
    fileprivate var _AvDesc: EdsPropertyDesc = EdsPropertyDesc()
        {didSet{_viewNotification.changePropertyDesc(EdsUInt32(kEdsPropID_Av))}}
    fileprivate var _TvDesc: EdsPropertyDesc = EdsPropertyDesc()
        {didSet{_viewNotification.changePropertyDesc(EdsUInt32(kEdsPropID_Tv))}}
    fileprivate var _IsoDesc: EdsPropertyDesc = EdsPropertyDesc()
        {didSet{_viewNotification.changePropertyDesc(EdsUInt32(kEdsPropID_ISOSpeed))}}
    fileprivate var _MeteringModeDesc: EdsPropertyDesc = EdsPropertyDesc()
        {didSet{_viewNotification.changePropertyDesc(EdsUInt32(kEdsPropID_MeteringMode))}}
    fileprivate var _ExposureCompensationDesc: EdsPropertyDesc = EdsPropertyDesc()
        {didSet{_viewNotification.changePropertyDesc(EdsUInt32(kEdsPropID_ExposureCompensation))}}
    fileprivate var _ImageQualityDesc: EdsPropertyDesc = EdsPropertyDesc()
        {didSet{_viewNotification.changePropertyDesc(EdsUInt32(kEdsPropID_ImageQuality))}}
    fileprivate var _evfAFModeDesc: EdsPropertyDesc = EdsPropertyDesc()
        {didSet{_viewNotification.changePropertyDesc(EdsUInt32(kEdsPropID_Evf_AFMode))}}
    fileprivate var _whiteBalanceDesc: EdsPropertyDesc = EdsPropertyDesc()
        {didSet{_viewNotification.changePropertyDesc(EdsUInt32(kEdsPropID_WhiteBalance))}}
    fileprivate var _driveModeDesc: EdsPropertyDesc = EdsPropertyDesc()
        {didSet{_viewNotification.changePropertyDesc(EdsUInt32(kEdsPropID_DriveMode))}}
    fileprivate var _zoomDesc: EdsPropertyDesc = EdsPropertyDesc()
        {didSet{_viewNotification.changePropertyDesc(EdsUInt32(kEdsPropID_DC_Zoom))}}
    fileprivate var _flashModeDesc: EdsPropertyDesc = EdsPropertyDesc()
        {didSet{_viewNotification.changePropertyDesc(EdsUInt32(kEdsPropID_DC_Strobe))}}
    fileprivate var _movieQualityDesc: EdsPropertyDesc = EdsPropertyDesc()
        {didSet{_viewNotification.changePropertyDesc(EdsUInt32(kEdsPropID_MovieParam))}}
    fileprivate var _movieHFRDesc: EdsPropertyDesc = EdsPropertyDesc()
        {didSet{_viewNotification.changePropertyDesc(EdsUInt32(kEdsPropID_MovieHFRSetting))}}
    fileprivate var _pictureStyleDesc: EdsPropertyDesc = EdsPropertyDesc()
        {didSet{_viewNotification.changePropertyDesc(EdsUInt32(kEdsPropID_PictureStyle))}}
    fileprivate var _aspectDesc: EdsPropertyDesc = tagEdsPropertyDesc()
        {didSet{_viewNotification.changePropertyDesc(EdsUInt32(kEdsPropID_Aspect))}}
    fileprivate var _autoPowerOffDesc: EdsPropertyDesc = EdsPropertyDesc()
        {didSet{_viewNotification.changePropertyDesc(EdsUInt32(kEdsPropID_AutoPowerOffSetting))}}

    fileprivate var _evfZoom: EdsUInt32 = 0
    fileprivate var _evfZoomPosition: EdsPoint = EdsPoint()
    
    fileprivate var _focusInfo: EdsFocusInfo = EdsFocusInfo()
         {didSet{_viewNotification.changeProperty(EdsUInt32(kEdsPropID_FocusInfo))}}
    
    fileprivate var _storageFileNum:Int = -1{didSet{_viewNotification.changeFileCount(NSInteger(_storageFileNum))}}
    
    fileprivate var _selectedVolumeIndex:EdsUInt32 = 0xff
    
    func setStorageFileNum(_ value:Int){
        _storageFileNum = value
    }
    
    fileprivate var _isFileTransferring = false
    func setFileTransferring(_ value : Bool){
        _isFileTransferring = value
    }
    func getFileTransferring()->Bool{
        return _isFileTransferring
    }
    
    fileprivate var _isFileDeleting = false
    func setFileDeleting(_ value : Bool){
        _isFileDeleting = value
    }
    func getFileDeleting()->Bool{
        return _isFileDeleting
    }
    func setSelectedVolume(_ value : EdsUInt32){
        _selectedVolumeIndex = value
    }
    func getSelectedVolume()->EdsUInt32{
        return _selectedVolumeIndex
    }
    init(camera:EdsCameraRef){
        _camera = camera
    }
    
    internal func getCameraObject()->EdsCameraRef?{
        return _camera
    }
    
    func getPropertyUInt32(_ propertyID: EdsUInt32) -> EdsUInt32{
     
        switch(propertyID)
        {
        case EdsUInt32(kEdsPropID_AEModeSelect):            return _AEMode
        case EdsUInt32(kEdsPropID_Tv):                      return _Tv
        case EdsUInt32(kEdsPropID_Av):                      return _Av
        case EdsUInt32(kEdsPropID_ISOSpeed):                return _Iso
        case EdsUInt32(kEdsPropID_MeteringMode):            return _MeteringMode
        case EdsUInt32(kEdsPropID_ExposureCompensation):    return _ExposureCompensation
        case EdsUInt32(kEdsPropID_Evf_Mode):                return _evfMode
        case EdsUInt32(kEdsPropID_Evf_OutputDevice):        return _evfOutputDevice
        case EdsUInt32(kEdsPropID_Evf_DepthOfFieldPreview): return _evfDepthOfFieldPreview
        case EdsUInt32(kEdsPropID_ImageQuality):            return _ImageQuality
        case EdsUInt32(kEdsPropID_Evf_AFMode):              return _evfAFMode
        case EdsUInt32(kEdsPropID_AvailableShots):          return _availableShots
        case EdsUInt32(kEdsPropID_BatteryLevel):            return _batteryLevel
        case EdsUInt32(kEdsPropID_TempStatus):              return _tempStatusLevel
        case EdsUInt32(kEdsPropID_WhiteBalance):            return _whiteBalance
        case EdsUInt32(kEdsPropID_DriveMode):               return _driveMode
        case EdsUInt32(kEdsPropID_DC_Zoom):                 return _zoom
        case EdsUInt32(kEdsPropID_DC_Strobe):               return _flashMode
        case EdsUInt32(kEdsPropID_MovieParam):              return _movieQuality
        case EdsUInt32(kEdsPropID_MovieHFRSetting):         return _movieHFR
        case EdsUInt32(kEdsPropID_PictureStyle):            return _pictureStyle
        case EdsUInt32(kEdsPropID_Aspect):                  return _aspect
        case EdsUInt32(kEdsPropID_AFMode):                  return _AFMode
        case EdsUInt32(kEdsPropID_FixedMovie):              return _fixedMovie
        case EdsUInt32(kEdsPropID_MirrorLockUpState):       return _mirrorLockUpState
        case EdsUInt32(kEdsPropID_MirrorUpSetting):         return _mirrorUpSetting
        case EdsUInt32(kEdsPropID_AutoPowerOffSetting):     return _autoPowerOff
        case EdsUInt32(kEdsPropID_EVF_RollingPitching):     return _rollPitch
        default:        break;
        }
        return 0xffffffff
    }
    
    
    //Acquisition of value list that can set taking a picture parameter
    func getPropertyDesc(_ propertyID: EdsUInt32) -> EdsPropertyDesc{
        
        let propertyDesc: EdsPropertyDesc = EdsPropertyDesc()
        switch(propertyID)
        {
        case EdsUInt32(kEdsPropID_AEModeSelect):            return _AEModeDesc
        case EdsUInt32(kEdsPropID_Tv):                      return _TvDesc
        case EdsUInt32(kEdsPropID_Av):                      return _AvDesc
        case EdsUInt32(kEdsPropID_ISOSpeed):                return _IsoDesc
        case EdsUInt32(kEdsPropID_MeteringMode):            return _MeteringModeDesc
        case EdsUInt32(kEdsPropID_ExposureCompensation):    return _ExposureCompensationDesc
        case EdsUInt32(kEdsPropID_ImageQuality):            return _ImageQualityDesc
        case EdsUInt32(kEdsPropID_Evf_AFMode):              return _evfAFModeDesc
        case EdsUInt32(kEdsPropID_WhiteBalance):            return _whiteBalanceDesc
        case EdsUInt32(kEdsPropID_DriveMode):               return _driveModeDesc
        case EdsUInt32(kEdsPropID_DC_Zoom):                 return _zoomDesc
        case EdsUInt32(kEdsPropID_DC_Strobe):               return _flashModeDesc
        case EdsUInt32(kEdsPropID_MovieParam):              return _movieQualityDesc
        case EdsUInt32(kEdsPropID_MovieHFRSetting):         return _movieHFRDesc
        case EdsUInt32(kEdsPropID_PictureStyle):            return _pictureStyleDesc
        case EdsUInt32(kEdsPropID_Aspect):                  return _aspectDesc
        case EdsUInt32(kEdsPropID_AutoPowerOffSetting):     return _autoPowerOffDesc
        default:        break;
        }
        return propertyDesc;
    }
    
    
    //Setting of taking a picture parameter(UInt32)
    func SetProperty(_ propertyID: EdsUInt32, property: EdsUInt32){
        
        switch propertyID{
        case EdsUInt32(kEdsPropID_AEModeSelect):            _AEMode = property
        case EdsUInt32(kEdsPropID_Tv):                      _Tv = property
        case EdsUInt32(kEdsPropID_Av):                      _Av = property
        case EdsUInt32(kEdsPropID_ISOSpeed):                _Iso = property
        case EdsUInt32(kEdsPropID_MeteringMode):            _MeteringMode = property
        case EdsUInt32(kEdsPropID_ExposureCompensation):    _ExposureCompensation = property
        case EdsUInt32(kEdsPropID_Evf_Mode):                _evfMode = property
        case EdsUInt32(kEdsPropID_Evf_OutputDevice):        if (_evfOutputDevice == 0xffffffff) { _startupEvfOutputDevice = property }; _evfOutputDevice = property
        case EdsUInt32(kEdsPropID_Evf_DepthOfFieldPreview): _evfDepthOfFieldPreview = property
        case EdsUInt32(kEdsPropID_ImageQuality):            _ImageQuality = property
        case EdsUInt32(kEdsPropID_Evf_AFMode):              _evfAFMode = property
        case EdsUInt32(kEdsPropID_AvailableShots):          _availableShots = property
        case EdsUInt32(kEdsPropID_BatteryLevel):            _batteryLevel = property
        case EdsUInt32(kEdsPropID_TempStatus):              _tempStatusLevel = property
        case EdsUInt32(kEdsPropID_WhiteBalance):            _whiteBalance = property
        case EdsUInt32(kEdsPropID_DriveMode):               _driveMode = property
        case EdsUInt32(kEdsPropID_DC_Zoom):                 _zoom = property
        case EdsUInt32(kEdsPropID_DC_Strobe):               _flashMode = property
        case EdsUInt32(kEdsPropID_MovieParam):              _movieQuality = property
        case EdsUInt32(kEdsPropID_MovieHFRSetting):         _movieHFR = property
        case EdsUInt32(kEdsPropID_PictureStyle):            _pictureStyle = property
        case EdsUInt32(kEdsPropID_Aspect):                  _aspect = property
        case EdsUInt32(kEdsPropID_AFMode):                  _AFMode = property
        case EdsUInt32(kEdsPropID_FixedMovie):              _fixedMovie = property
        case EdsUInt32(kEdsPropID_MirrorUpSetting):         _mirrorUpSetting = property
        case EdsUInt32(kEdsPropID_MirrorLockUpState):       _mirrorLockUpState = property
        case EdsUInt32(kEdsPropID_AutoPowerOffSetting):     _autoPowerOff = property
        case EdsUInt32(kEdsPropID_EVF_RollingPitching):     _rollPitch = property
        default:        break;
        }
    }
    
    //Setting of value list that can set taking a picture parameter
    func setPropertyDesc(_ propertyID: EdsUInt32, propertyDesc: EdsPropertyDesc){
        
        switch(propertyID)
        {
        case EdsUInt32(kEdsPropID_AEModeSelect):            _AEModeDesc = propertyDesc
        case EdsUInt32(kEdsPropID_Tv):                      _TvDesc = propertyDesc
        case EdsUInt32(kEdsPropID_Av):                      _AvDesc = propertyDesc
        case EdsUInt32(kEdsPropID_ISOSpeed):                _IsoDesc = propertyDesc
        case EdsUInt32(kEdsPropID_MeteringMode):            _MeteringModeDesc = propertyDesc
        case EdsUInt32(kEdsPropID_ExposureCompensation):    _ExposureCompensationDesc = propertyDesc
        case EdsUInt32(kEdsPropID_ImageQuality):            _ImageQualityDesc = propertyDesc
        case EdsUInt32(kEdsPropID_Evf_AFMode):              _evfAFModeDesc = propertyDesc
        case EdsUInt32(kEdsPropID_WhiteBalance):            _whiteBalanceDesc = propertyDesc
        case EdsUInt32(kEdsPropID_DriveMode):               _driveModeDesc = propertyDesc
        case EdsUInt32(kEdsPropID_DC_Zoom):                 _zoomDesc = propertyDesc
        case EdsUInt32(kEdsPropID_DC_Strobe):               _flashModeDesc = propertyDesc
        case EdsUInt32(kEdsPropID_MovieParam):              _movieQualityDesc = propertyDesc
        case EdsUInt32(kEdsPropID_MovieHFRSetting):         _movieHFRDesc = propertyDesc
        case EdsUInt32(kEdsPropID_PictureStyle):            _pictureStyleDesc = propertyDesc
        case EdsUInt32(kEdsPropID_Aspect):                  _aspectDesc = propertyDesc
            // Ignore PropertyDesc when shooting still images.
            if (getPropertyUInt32(EdsUInt32(kEdsPropID_FixedMovie)) == 0)
            {
                _movieQualityDesc.numElements = 0
            }
        case EdsUInt32(kEdsPropID_AutoPowerOffSetting):     _autoPowerOffDesc = propertyDesc
        default:        break;
        }
    }
    
    //Setting of taking a picture parameter(String)
    func setPropertyString(_ propertyID: EdsUInt32, string: inout Array<EdsChar>){
        
        switch(propertyID)
        {
        case EdsUInt32(kEdsPropID_ProductName):
            self._modelString = string
            isTypeDS = ((String(cString: self._modelString, encoding: String.Encoding.ascii))?.contains("EOS"))!
        case EdsUInt32(kEdsPropID_OwnerName):
            self._ownerName = string
            break
        default:
            break
        }
    }
    
    func setPropertyByteBlock(_ propertyID: EdsUInt32, byte: inout Array<UInt8>){
        
        switch(propertyID)
        {
        case EdsUInt32(kEdsPropID_MovieParam):
            let value = UnsafePointer(byte).withMemoryRebound(to: UInt32.self, capacity: 1) {
                $0.pointee
            }
            self._movieQuality = value
        case EdsUInt32(kEdsPropID_Evf_ClickWBCoeffs):
            memcpy(&_clickWB, byte, MemoryLayout<EdsManualWBData>.size)
        default:
            break
        }
    }
    
    //Access to camera
    func evfMode() -> EdsUInt32{ return _evfMode }
    
    func evfAFMode() -> EdsUInt32{ return _evfAFMode }

    func startupEvfOutputDevice() -> EdsUInt32{ return _startupEvfOutputDevice }

    func evfOutputDevice() -> EdsUInt32{ return _evfOutputDevice }
    func setEvfOutputDevice(_ evfOutputDevice: EdsUInt32){ _evfOutputDevice = evfOutputDevice }

    func evfDepthOfFieldPreview() -> EdsUInt32{ return _evfDepthOfFieldPreview }
    
    func setEvfZoom(_ evfZoom: EdsUInt32){ _evfZoom = evfZoom }
    
    func setEvfZoomPosition(_ evfZoomPosition: EdsPoint){ _evfZoomPosition = evfZoomPosition }
    
    func evfZoomPosition() -> EdsPoint{ return _evfZoomPosition }
    
    func focusInfo() -> EdsFocusInfo { return _focusInfo }
    
    func setFocusInfo(_ focusInfo: EdsFocusInfo){ _focusInfo = focusInfo }
    
    func modelString() -> String {
        
        // Warning: CameraControl/CameraModel.swift:355:43: Comparing non-optional value of type 'String' to nil always returns true
//        if (String(cString: _modelString) != nil ){
            return String(cString: _modelString)
//        }else{
//            return ""
//        }
    }
    
}

protocol __Notification {
    func changeProperty(_ value: EdsUInt32)
    func changePropertyDesc(_ value: EdsUInt32)
    func changeFileCount(_ value: NSInteger)
    func errorNotification(_ error: EdsError) -> Bool
}

class ViewNotification: __Notification {
    
    func changeEvfData(_ value: EdsUInt32){
        var event = CameraEvent(type:.download_EVF, arg: NSNumber.init(value: Int32(value)) as AnyObject)
        self.viewNotificationObservers(&event)
    }
    
    func changeProperty(_ value: EdsUInt32){
        var event = CameraEvent(type:.property_CHANGED, arg: NSNumber.init(value: Int32(value)) as AnyObject)
        self.viewNotificationObservers(&event)
    }
    
    func changePropertyDesc(_ value: EdsUInt32){
        var event = CameraEvent(type:.propertydesc_CHANGED, arg: NSNumber.init(value: Int32(value)) as AnyObject)
        self.viewNotificationObservers(&event)
    }
    
    func changeFileCount(_ value: NSInteger) {
        var event = CameraEvent( type:.file_COUNT_COMPLETED, arg: value as AnyObject)
        self.viewNotificationObservers(&event)
    }
    
    func errorNotification(_ error: EdsError) -> Bool{
    
        //Notification of error
        if(error != EdsError(EDS_ERR_OK))
        {
            // It retries it at device busy
            if(error == EdsError(EDS_ERR_DEVICE_BUSY))
            {
                let obj: NSInteger = NSInteger(error)
                var event = CameraEvent( type:.device_BUSY, arg: obj as AnyObject)
                self.viewNotificationObservers(&event)
                //Swift.print("DEVICE BUSY ERROR: " + String(obj))
                return false
            }
            
            let obj: NSInteger = NSInteger(error)
            var event = CameraEvent(type:.error, arg: obj as AnyObject)
          //  Swift.print("Other ERROR: " + String(obj))
            self.viewNotificationObservers(&event)
            
        }
        return true
    }
    
    func errorNotificationShutter(_ error: EdsError) -> Bool{
        
        //Notification of error
        if(error != EdsError(EDS_ERR_OK))
        {
            // It retries it at device busy
            if(error == EdsError(EDS_ERR_DEVICE_BUSY))
            {
                let obj: NSInteger = NSInteger(error)
                var event = CameraEvent( type:.device_BUSY, arg: obj as AnyObject)
                self.viewNotificationObservers(&event)
                //Swift.print("DEVICE BUSY ERROR: " + String(obj))
                return true
            }
            else
            {
            let obj: NSInteger = NSInteger(error)
            var event = CameraEvent(type:.error, arg: obj as AnyObject)
            //  Swift.print("Other ERROR: " + String(obj))
            self.viewNotificationObservers(&event)
            return true
            }
        }
        return true
    }
    
    func errorNotificationWithRetry(_ error: EdsError) -> Bool{
        
        //Notification of error
        if(error != EdsError(EDS_ERR_OK))
        {
            // It retries it at device busy
            if(error == EdsError(EDS_ERR_DEVICE_BUSY))
            {
                let obj: NSInteger = NSInteger(error)
                var event = CameraEvent( type:.device_BUSY, arg: obj as AnyObject)
                self.viewNotificationObservers(&event)
             //   Swift.print("DEVICE BUSY ERROR: " + String(obj))
                return false
            }
            
            let obj: NSInteger = NSInteger(error)
            var event = CameraEvent( type:.error, arg: obj as AnyObject)
            self.viewNotificationObservers(&event)
           // Swift.print("Other ERROR: " + String(obj))
            return false
        }
        
        return true
        
    }
    
    func viewNotificationObservers(_ event : inout CameraEvent){
        if(Thread.isMainThread){
            NotificationCenter.default.post(name: Notification.Name(rawValue: "MY_VIEW_UPDATE"), object: event)
        }else{
            DispatchQueue.main.async {[event] in
                NotificationCenter.default.post(name: Notification.Name(rawValue:"MY_VIEW_UPDATE"), object: event)
            }
        }
    }
}
