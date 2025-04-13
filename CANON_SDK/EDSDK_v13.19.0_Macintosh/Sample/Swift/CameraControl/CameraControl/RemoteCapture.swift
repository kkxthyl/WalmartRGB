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

class RemoteCapture: NSWindowController, NSWindowDelegate{
    
    fileprivate var _model : CameraModel!
    fileprivate var _controller : CameraController!
    fileprivate var _liveView: CameraEvfData!
    fileprivate var _isLiveViewActive = false
    fileprivate var _isClickEvfImage = false
    fileprivate var _cursor = NSCursor.current

    @IBOutlet weak var _zoomValue: NSTextField!
    @IBOutlet weak var _flashMode: FlashModePopUp!
    @IBOutlet weak var _movieQuality: MovieQualityPopUp!
    @IBOutlet weak var _movieHFR: MovieHFRPopUp!
    @IBOutlet weak var _pictureStyle: PictureStylePopUp!
    
    @IBOutlet weak var _aspect: AspectPopUp!
    @IBOutlet weak var _sliderOfZoom: ZoomSlider!
    @IBOutlet weak var _battery: BatteryLevelLabel!
    @IBOutlet weak var _availableShots: AvailableShotsLabel!
    @IBOutlet weak var _tempStatus: TempStatusLabel!
    
    @IBOutlet weak var _driveMode: DriveModePopUp!
    
    @IBOutlet weak var _zoomLabel: NSTextField!
    @IBOutlet weak var _focusLabel: NSTextField!
    @IBOutlet weak var _focusPositionLabel: NSTextField!
    @IBOutlet weak var _zoomBarLabel: NSTextField!
    @IBOutlet weak var _flashModeLabel: NSTextField!
    
    @IBOutlet weak var _whiteBalance: WhiteBalancePopUp!
    @IBOutlet weak var _aeMode: AeModePopUp!
    @IBOutlet weak var _tv: TvPopUp!
    @IBOutlet weak var _av: AvPopUp!
    @IBOutlet weak var _iso: IsoPopUp!
    @IBOutlet weak var _metering: MeteringPopUp!
    @IBOutlet weak var _evfMode: EvfAfModePopUp!
    @IBOutlet weak var _imageQuality: ImageQualityPopUp!
    @IBOutlet weak var _exposureComp: ExposureCompPopUp!
    @IBOutlet weak var _afMode: AfModePopUp!
    
    @IBOutlet weak var _takePictureButton: ActionButton!
    @IBOutlet weak var _pressHalfway: ActionButton!
    @IBOutlet weak var _pressOff: ActionButton!
    @IBOutlet weak var _pressComplete: ActionButton!
    @IBOutlet weak var _stillImage: ActionRadioButton!
    @IBOutlet weak var _movieMode: ActionRadioButton!
    @IBOutlet weak var _recStart: ActionButton!
    @IBOutlet weak var _recEnd: ActionButton!
    @IBOutlet weak var _startEvfButton: ActionButton!
    @IBOutlet weak var _endEvfButton: ActionButton!
    @IBOutlet weak var _focusFar1: ActionButton!
    @IBOutlet weak var _focusFar2: ActionButton!
    @IBOutlet weak var _focusFar3: ActionButton!
    @IBOutlet weak var _focusNear1: ActionButton!
    @IBOutlet weak var _focusNear2: ActionButton!
    @IBOutlet weak var _focusNear3: ActionButton!
    @IBOutlet weak var _DoEvfAFON: ActionButton!
    @IBOutlet weak var _DoEvfAFOFF: ActionButton!
    @IBOutlet weak var _zoomFit: ActionButton!
    @IBOutlet weak var _zoomZoom: ActionButton!
    @IBOutlet weak var _positionUp: ActionButton!
    @IBOutlet weak var _positionLeft: ActionButton!
    @IBOutlet weak var _positionRight: ActionButton!
    @IBOutlet weak var _positionDown: ActionButton!
    @IBOutlet weak var _mirrorUpOn: ActionRadioButton!
    @IBOutlet weak var _mirrorUpOff: ActionRadioButton!

    @IBOutlet weak var _evfImage: EvfImageView!
    
    @IBOutlet weak var _downloadProgressBar: DownloadProgressBar!
    
    @IBOutlet weak var _rollPitchOnOff: ActionButton!
    @IBOutlet weak var _positionValue: NSTextField!
    @IBOutlet weak var _rollingValue: NSTextField!
    @IBOutlet weak var _pitchingValue: NSTextField!
    
    @IBOutlet weak var _clickWB: ActionButton!
    @IBOutlet weak var _clickAF: ActionButton!
    
    @IBAction func _stillMovie(_ sender: ActionButton) { sender.fireEvent() }
    @IBAction func action(_ sender: ActionButton) { sender.fireEvent() }
    
    @IBAction func PopUp(_ sender: PropertyPopUp) { sender.fireEvent() }
    
    @IBAction func Slider(_ sender: ZoomSlider) {
        sender.fireEvent()
        _zoomValue.stringValue = _sliderOfZoom.stringValue
    }
    @IBAction func _mirrorUp(_ sender: ActionButton) { if (!_isLiveViewActive && _controller.getCameraModel().getPropertyUInt32(EdsUInt32(kEdsPropID_FixedMovie)) == 0) { sender.fireEvent() } else { updateMirrorLockUpState(data: _model.getPropertyUInt32(EdsUInt32(kEdsPropID_MirrorLockUpState))) } }
    
    init(controller: CameraController){
        
        super.init(window: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.update), name: Notification.Name(rawValue: "MY_VIEW_UPDATE"), object: nil)
        Bundle.main.loadNibNamed("RemoteCapture", owner: self, topLevelObjects: nil)
        
        Thread.sleep(forTimeInterval: 0.5)
        
        self._controller = controller
        _model = _controller.getCameraModel()
        
        self.setupButtonCommand()
        self.setupPopUpCommand()
        
        self.setParameterToCameraControler()

        // invalidate it in the DC
        self._zoomFit.isEnabled = _controller.getCameraModel().getIsTypeDS()
        self._zoomZoom.isEnabled = _controller.getCameraModel().getIsTypeDS()
        // Processing inside updateFixedMovie
//        self._focusFar1.isEnabled = _controller.getCameraModel().getIsTypeDS()
//        self._focusFar2.isEnabled = _controller.getCameraModel().getIsTypeDS()
//        self._focusFar3.isEnabled = _controller.getCameraModel().getIsTypeDS()
//        self._focusNear1.isEnabled = _controller.getCameraModel().getIsTypeDS()
//        self._focusNear2.isEnabled = _controller.getCameraModel().getIsTypeDS()
//        self._focusNear3.isEnabled = _controller.getCameraModel().getIsTypeDS()
        
        if(_controller.getCameraModel().getIsTypeDS()){
            self._zoomValue.textColor = .gray
            self._zoomBarLabel.textColor = .gray
            self._flashModeLabel.textColor = .gray
        }
        else{
            self._zoomLabel.textColor = .gray
            self._focusLabel.textColor = .gray
        }

        // invalidate it in the DS
        //self._flashMode.isEnabled = !_controller.getCameraModel().getIsTypeDS()
        self._sliderOfZoom.isEnabled = !_controller.getCameraModel().getIsTypeDS() // at the time of start, ZoomBar is disable
                        
        if (!_controller.getCameraModel().getIsTypeDS())
        {
            _controller.actionPerformed(ActionEvent(command: .remoteshooting_START, object: 0 as AnyObject))
        }       

        self._rollPitchOnOff.title = "Roll Pitch On"
        updateAngleInfoLabel(pos:"-", roll:"-", pitc:"-")

        updateFixedMovie(data: _model.getPropertyUInt32(EdsUInt32(kEdsPropID_FixedMovie)))
        
        if (0xffffffff == _model.getPropertyUInt32(EdsUInt32(kEdsPropID_MirrorUpSetting)) || (_model.startupEvfOutputDevice() & kEdsEvfOutputDevice_TFT.rawValue) != 0)
        {
            _mirrorUpOn.isEnabled = false
            _mirrorUpOff.isEnabled = false
        }
        updateMirrorLockUpState(data: _model.getPropertyUInt32(EdsUInt32(kEdsPropID_MirrorLockUpState)))
        
        controlFocusButton()
        
        NSEvent.addLocalMonitorForEvents(matching: .mouseMoved){ (event) -> NSEvent in
            if (self._isClickEvfImage)
            {
                self.mouseMoved(with: event)
            }
            return event
        }
    }
    
    required init?(coder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
        
    }
    
    private func windowShouldClose(_ sender: Any) -> Bool { return true }
  
    func windowWillClose(_ notification: Notification) {
        
        self.ViewNone()
        self.removeActionSource()
        NSApp.stopModal()
        NSApp.abortModal()
        if (!_controller.getCameraModel().getIsTypeDS())
        {
            _controller.actionPerformed(ActionEvent(command: .remoteshooting_END, object: 0 as AnyObject))
        }
    }
        
    @objc func ViewImage() {
        
        if (_isLiveViewActive == false){
            _isLiveViewActive = true
            _controller.actionPerformed(ActionEvent(command: .start_EVF, object: 0 as AnyObject))
            self._sliderOfZoom.isEnabled = !_controller.getCameraModel().getIsTypeDS()
        }
    }
    
    @objc func ViewNone(){
        
        if (_isLiveViewActive){
            _isLiveViewActive = false
            self._evfImage.image = nil
            _controller.actionPerformed(ActionEvent(command: .evf_AF_OFF, object: 0 as AnyObject))
            _controller.actionPerformed(ActionEvent(command: .end_EVF, object: 0 as AnyObject))
            self._sliderOfZoom.isEnabled = false
        }
        _controller.actionPerformed(ActionEvent(command: .press_OFF, object: 0 as AnyObject))
    }
    
    @objc func update(_ notification: Notification?) {
        
        let event = notification?.object as! CameraEvent
        
        let arg = event.getArg()

        switch(event.getEvent()){
        case .download_EVF:
            _controller.actionPerformed(ActionEvent(command: .download_EVF, object: 0 as AnyObject))
        case .evf_DATA_CHANGED:         self.drawImage(arg)
        case .property_CHANGED:
            self.GetPropertyChangedMessage(arg)
        case .propertydesc_CHANGED:     self.GetPropertyDescChangedMessage(arg)
        case .terminate_APP:            self.tetminateApplication()
        case .download_PROGRESS:
            let argNumber = arg as! NSNumber
            let percentage = argNumber.int32Value
            self._downloadProgressBar.updateProperty(EdsUInt32(percentage))
        case .download_COMPLETED:
            Thread.sleep(forTimeInterval: 0.2)
            self._downloadProgressBar.doubleValue = 0.0
            break
        case .angle_INFO:
            let cameraPos: EdsCameraPos = arg as! EdsCameraPos
            if (cameraPos.status == 2)
            {
                let pos: Double = Double(cameraPos.position)
                let roll: Double = Double(cameraPos.rolling) * 0.01
                let pitc: Double = Double(cameraPos.pitching) * 0.01
                updateAngleInfoLabel(pos:String(pos), roll:String(roll), pitc:String(pitc))
            }
            else
            {
                updateAngleInfoLabel(pos:"-", roll:"-", pitc:"-")
            }
        case .mouse_CURSOR:
            let onOffPtr = arg as! NSNumber
            if (onOffPtr != 0)
            {
                changeMouseCursor(onOff: true)
            }
            else
            {
                changeMouseCursor(onOff: false)
                if(_controller.clickType == 1){
                    _controller.actionPerformed(ActionEvent(command: .click_MOUSE_WB, object: 0 as AnyObject))
                }
                if(_controller.clickType == 2){
                    _controller.actionPerformed(ActionEvent(command: .click_MOUSE_AF, object: 0 as AnyObject))
                }
            }
        case .device_BUSY:
            break
        case .error:
            break
        default:
            break;
        }
    }

    func drawImage(_ arg: AnyObject){
        
        let obj: NSInteger = NSInteger(kEdsPropID_FocusInfo)
        _controller.actionPerformed(ActionEvent(command: .get_PROPERTY, object: obj as AnyObject))
        self._evfImage.drawImage(_model, arg: arg)
        
        if (_isLiveViewActive){
            _controller.actionPerformed(ActionEvent(command: .download_EVF, object: 0 as AnyObject))
        }
    }

    func tetminateApplication(){
        
        self.ViewNone()
        self.removeActionSource()
        NSApp.stopModal()
        NSApp.abortModal()
        NSApp.terminate(NSApp.windows)
        
    }
    func GetPropertyChangedMessage(_ arg: AnyObject){

        let argNumber = arg as! NSNumber
        let propertyID = argNumber.int32Value
        let propertyId: EdsUInt32 = _model.getPropertyUInt32(EdsUInt32(propertyID))
        
        switch(propertyID){
        case Int32(kEdsPropID_AEModeSelect): self._aeMode.updateProperty(propertyId, PROPERTYLIST: _aeMode.PROPERTYLIST)
        case Int32(kEdsPropID_Tv): self._tv.updateProperty(propertyId, PROPERTYLIST: _tv.PROPERTYLIST)
        case Int32(kEdsPropID_Av): self._av.updateProperty(propertyId, PROPERTYLIST: _av.PROPERTYLIST)
        case Int32(kEdsPropID_ISOSpeed):
            self._iso.updateProperty(propertyId, PROPERTYLIST: _iso.PROPERTYLIST)
        case Int32(kEdsPropID_MeteringMode): self._metering.updateProperty(propertyId, PROPERTYLIST: _metering.PROPERTYLIST)
        case Int32(kEdsPropID_ExposureCompensation): self._exposureComp.updateProperty(propertyId, PROPERTYLIST: _exposureComp.PROPERTYLIST)
        case Int32(kEdsPropID_ImageQuality): self._imageQuality.updateProperty(propertyId, PROPERTYLIST: _imageQuality.PROPERTYLIST)
        case Int32(kEdsPropID_Evf_AFMode):
            // If property is 'Catch AF', make 'Evf_AFMode_LiveFace' forcibly.
            if (0x09 != _model.evfAFMode())
            {
                controlFocusButton()
                self._evfMode.updateProperty(propertyId, PROPERTYLIST: _evfMode.PROPERTYLIST)
            }
            else
            {
                var evfAFMode: EdsUInt32 = 0x02
                EdsSetPropertyData(_model.getCameraObject(), EdsPropertyID(kEdsPropID_Evf_AFMode), 0, EdsUInt32(MemoryLayout<EdsUInt32>.size), &evfAFMode)
            }
        case Int32(kEdsPropID_AvailableShots): self._availableShots.updateProperty(propertyId)
        case Int32(kEdsPropID_BatteryLevel): self._battery.updateProperty(propertyId)
        case Int32(kEdsPropID_TempStatus): self._tempStatus.updateProperty(propertyId)
        case Int32(kEdsPropID_WhiteBalance): self._whiteBalance.updateProperty(propertyId, PROPERTYLIST: _whiteBalance.PROPERTYLIST)
        case Int32(kEdsPropID_DriveMode): self._driveMode.updateProperty(propertyId, PROPERTYLIST: _driveMode.PROPERTYLIST)
        case Int32(kEdsPropID_DC_Strobe):
            self._flashMode.updateProperty(propertyId, PROPERTYLIST: _flashMode.PROPERTYLIST)
        case Int32(kEdsPropID_AFMode): self._afMode.updateProperty(propertyId, PROPERTYLIST: _afMode.PROPERTYLIST)
        case Int32(kEdsPropID_DC_Zoom):
            let value = _model.getPropertyUInt32(UInt32(kEdsPropID_DC_Zoom))
            self._zoomValue.stringValue = String(value)
            self._sliderOfZoom.updateProperty(value)
        case Int32(kEdsPropID_FixedMovie):
            updateFixedMovie(data: _model.getPropertyUInt32(EdsUInt32(kEdsPropID_FixedMovie)))
        case Int32(kEdsPropID_MirrorLockUpState):
            updateMirrorLockUpState(data: _model.getPropertyUInt32(EdsUInt32(kEdsPropID_MirrorLockUpState)))
        case Int32(kEdsPropID_MovieParam): self._movieQuality.updateProperty(propertyId, PROPERTYLIST: _movieQuality.PROPERTYLIST)
        case Int32(kEdsPropID_MovieHFRSetting): self._movieHFR.updateProperty(propertyId, PROPERTYLIST: _movieHFR.PROPERTYLIST)
        case Int32(kEdsPropID_PictureStyle): self._pictureStyle.updateProperty(propertyId, PROPERTYLIST: _pictureStyle.PROPERTYLIST)
        case Int32(kEdsPropID_Aspect): self._aspect.updateProperty(propertyId, PROPERTYLIST: _aspect.PROPERTYLIST)
        case Int32(kEdsPropID_Evf_ClickWBCoeffs):
            var cwbSize: EdsUInt32 = 0
            var type: EdsDataType = kEdsDataType_Unknown
            EdsGetPropertySize(_model.getCameraObject(), EdsPropertyID(propertyID), 0, &type, &cwbSize)

            var cwbCoefs: UnsafeMutablePointer<EdsManualWBData>
            cwbCoefs = UnsafeMutablePointer<EdsManualWBData>.allocate(capacity: Int(cwbSize))
            EdsGetPropertyData(_model.getCameraObject(), EdsPropertyID(propertyID), 0, cwbSize, cwbCoefs)

            let mwbSize: EdsUInt32 = cwbSize + 12
            var mwbBuff: UnsafeMutablePointer<EdsInt8>
            mwbBuff = UnsafeMutablePointer<EdsInt8>.allocate(capacity: Int(mwbSize))
            memcpy(mwbBuff, cwbCoefs, Int(cwbSize))
            var valid: EdsInt32 = 1
            memcpy(mwbBuff, &valid, MemoryLayout<EdsInt32>.size)
            var dataSize: EdsInt32 = cwbCoefs.pointee.dataSize + 12
            memcpy(mwbBuff.advanced(by: MemoryLayout<EdsInt32>.size), &dataSize, MemoryLayout<EdsInt32>.size)
            memcpy(mwbBuff.advanced(by: 52), mwbBuff.advanced(by: 40), Int(cwbCoefs.pointee.dataSize))
            memset(mwbBuff.advanced(by: 40), 0, Int(cwbCoefs.pointee.dataSize))
            EdsSetPropertyData(_model.getCameraObject(), EdsPropertyID(kEdsPropID_ManualWhiteBalanceData), 0, mwbSize, mwbBuff)

            var whiteBalance = kEdsWhiteBalance_WhitePaper
            EdsSetPropertyData(_model.getCameraObject(), EdsPropertyID(kEdsPropID_WhiteBalance), 0, EdsUInt32(MemoryLayout<EdsWhiteBalance>.size), &whiteBalance)

            cwbCoefs.deallocate()
            mwbBuff.deallocate()
        default:
            break
        }
    }
    func GetPropertyDescChangedMessage(_ arg: AnyObject){
        
        let argNumber = arg as! NSNumber
        let propertyID = argNumber.int32Value
        let propertyDesc = _model.getPropertyDesc(EdsUInt32(propertyID))
        switch(propertyID){
        case Int32(kEdsPropID_AEModeSelect):
            _aeMode.updatePropertyDesc(propertyDesc, PROPERTYLIST: _aeMode.PROPERTYLIST)
            _aeMode.setPropertyDesc(_model.getPropertyDesc(EdsUInt32(kEdsPropID_AEModeSelect)))
        case Int32(kEdsPropID_Tv):
            _tv.updatePropertyDesc(propertyDesc, PROPERTYLIST: _tv.PROPERTYLIST)
            _tv.setPropertyDesc(_model.getPropertyDesc(EdsUInt32(kEdsPropID_Tv)))
        case Int32(kEdsPropID_Av):
            _av.updatePropertyDesc(propertyDesc, PROPERTYLIST: _av.PROPERTYLIST)
            _av.setPropertyDesc(_model.getPropertyDesc(EdsUInt32(kEdsPropID_Av)))
        case Int32(kEdsPropID_ISOSpeed):
            _iso.updatePropertyDesc(propertyDesc, PROPERTYLIST: _iso.PROPERTYLIST)
            _iso.setPropertyDesc(_model.getPropertyDesc(EdsUInt32(kEdsPropID_ISOSpeed)))
        case Int32(kEdsPropID_MeteringMode):
            _metering.updatePropertyDesc(propertyDesc, PROPERTYLIST: _metering.PROPERTYLIST)
            _metering.setPropertyDesc(_model.getPropertyDesc(EdsUInt32(kEdsPropID_MeteringMode)))
        case Int32(kEdsPropID_ExposureCompensation):
            _exposureComp.updatePropertyDesc(propertyDesc, PROPERTYLIST: _exposureComp.PROPERTYLIST)
            _exposureComp.setPropertyDesc(_model.getPropertyDesc(EdsUInt32(kEdsPropID_ExposureCompensation)))
        case Int32(kEdsPropID_ImageQuality):
            _imageQuality.updatePropertyDesc(propertyDesc, PROPERTYLIST: _imageQuality.PROPERTYLIST)
            _imageQuality.setPropertyDesc(_model.getPropertyDesc(EdsUInt32(kEdsPropID_ImageQuality)))
        case Int32(kEdsPropID_Evf_AFMode):
            _evfMode.updatePropertyDesc(propertyDesc, PROPERTYLIST: _evfMode.PROPERTYLIST)
            _evfMode.setPropertyDesc(_model.getPropertyDesc(EdsUInt32(kEdsPropID_Evf_AFMode)))
        case Int32(kEdsPropID_WhiteBalance):
            _whiteBalance.updatePropertyDesc(propertyDesc, PROPERTYLIST: _whiteBalance.PROPERTYLIST)
            _whiteBalance.setPropertyDesc(_model.getPropertyDesc(EdsUInt32(kEdsPropID_WhiteBalance)))
        case Int32(kEdsPropID_DriveMode):
            _driveMode.updatePropertyDesc(propertyDesc, PROPERTYLIST: _driveMode.PROPERTYLIST)
            _driveMode.setPropertyDesc(_model.getPropertyDesc(EdsUInt32(kEdsPropID_DriveMode)))
        case Int32(kEdsPropID_DC_Strobe):
            _flashMode.updatePropertyDesc(propertyDesc, PROPERTYLIST: _flashMode.PROPERTYLIST)
            _flashMode.setPropertyDesc(_model.getPropertyDesc(EdsUInt32(kEdsPropID_DC_Strobe)))
        case Int32(kEdsPropID_DC_Zoom):
            _sliderOfZoom.updatePropertyDesc(propertyDesc)
        case Int32(kEdsPropID_AFMode):
            _afMode.updatePropertyDesc(propertyDesc, PROPERTYLIST: _afMode.PROPERTYLIST)
            _afMode.setPropertyDesc(_model.getPropertyDesc(EdsUInt32(kEdsPropID_AFMode)))
        case Int32(kEdsPropID_MovieParam):
            _movieQuality.updatePropertyDesc(propertyDesc, PROPERTYLIST: _movieQuality.PROPERTYLIST)
            _movieQuality.setPropertyDesc(_model.getPropertyDesc(EdsUInt32(kEdsPropID_MovieParam)))
        case Int32(kEdsPropID_MovieHFRSetting):
            _movieHFR.updatePropertyDesc(propertyDesc, PROPERTYLIST: _movieHFR.PROPERTYLIST)
            _movieHFR.setPropertyDesc(_model.getPropertyDesc(EdsUInt32(kEdsPropID_MovieHFRSetting)))
        case Int32(kEdsPropID_PictureStyle):
            _pictureStyle.updatePropertyDesc(propertyDesc, PROPERTYLIST: _pictureStyle.PROPERTYLIST)
            _pictureStyle.setPropertyDesc(_model.getPropertyDesc(EdsUInt32(kEdsPropID_PictureStyle)))
        case Int32(kEdsPropID_Aspect):
            _aspect.updatePropertyDesc(propertyDesc, PROPERTYLIST: _aspect.PROPERTYLIST)
            _aspect.setPropertyDesc(_model.getPropertyDesc(EdsUInt32(kEdsPropID_Aspect)))
        default:
            break
        }
    }
    
    func setParameterToCameraControler(){
        
        _aeMode.updatePropertyDesc(_model.getPropertyDesc(UInt32(kEdsPropID_AEModeSelect)), PROPERTYLIST: _aeMode.PROPERTYLIST )
        _tv.updatePropertyDesc(_model.getPropertyDesc(UInt32(kEdsPropID_Tv)), PROPERTYLIST: _tv.PROPERTYLIST)
        _av.updatePropertyDesc(_model.getPropertyDesc(UInt32(kEdsPropID_Av)), PROPERTYLIST: _av.PROPERTYLIST)
        _iso.updatePropertyDesc(_model.getPropertyDesc(UInt32(kEdsPropID_ISOSpeed)), PROPERTYLIST: _iso.PROPERTYLIST)
        _metering.updatePropertyDesc(_model.getPropertyDesc(UInt32(kEdsPropID_MeteringMode)), PROPERTYLIST: _metering.PROPERTYLIST)
        _exposureComp.updatePropertyDesc(_model.getPropertyDesc(UInt32(kEdsPropID_ExposureCompensation)), PROPERTYLIST: _exposureComp.PROPERTYLIST)
        _imageQuality.updatePropertyDesc(_model.getPropertyDesc(UInt32(kEdsPropID_ImageQuality)), PROPERTYLIST: _imageQuality.PROPERTYLIST)
        _evfMode.updatePropertyDesc(_model.getPropertyDesc(UInt32(kEdsPropID_Evf_AFMode)), PROPERTYLIST: _evfMode.PROPERTYLIST)
        _whiteBalance.updatePropertyDesc(_model.getPropertyDesc(UInt32(kEdsPropID_WhiteBalance)), PROPERTYLIST: _whiteBalance.PROPERTYLIST)
        _driveMode.updatePropertyDesc(_model.getPropertyDesc(UInt32(kEdsPropID_DriveMode)), PROPERTYLIST: _driveMode.PROPERTYLIST)
        _flashMode.updatePropertyDesc(_model.getPropertyDesc(UInt32(kEdsPropID_DC_Strobe)), PROPERTYLIST: _flashMode.PROPERTYLIST)
        _movieQuality.updatePropertyDesc(_model.getPropertyDesc(UInt32(kEdsPropID_MovieParam)), PROPERTYLIST: _movieQuality.PROPERTYLIST)
        _movieHFR.updatePropertyDesc(_model.getPropertyDesc(UInt32(kEdsPropID_MovieHFRSetting)), PROPERTYLIST: _movieHFR.PROPERTYLIST)
        _pictureStyle.updatePropertyDesc(_model.getPropertyDesc(UInt32(kEdsPropID_PictureStyle)), PROPERTYLIST: _pictureStyle.PROPERTYLIST)
        _aspect.updatePropertyDesc(_model.getPropertyDesc(UInt32(kEdsPropID_Aspect)), PROPERTYLIST: _aspect.PROPERTYLIST)
        _zoomValue.stringValue = "0"
        _sliderOfZoom.updatePropertyDesc(_model.getPropertyDesc(UInt32(kEdsPropID_DC_Zoom)))
        _afMode.updatePropertyDesc(_model.getPropertyDesc(UInt32(kEdsPropID_AFMode)), PROPERTYLIST: _afMode.PROPERTYLIST )
        
        _aeMode.updateProperty(_model.getPropertyUInt32(UInt32(kEdsPropID_AEModeSelect)), PROPERTYLIST: _aeMode.PROPERTYLIST)
        _tv.updateProperty(_model.getPropertyUInt32(UInt32(kEdsPropID_Tv)), PROPERTYLIST: _tv.PROPERTYLIST)
        _av.updateProperty(_model.getPropertyUInt32(UInt32(kEdsPropID_Av)), PROPERTYLIST: _av.PROPERTYLIST)
        _iso.updateProperty(_model.getPropertyUInt32(UInt32(kEdsPropID_ISOSpeed)), PROPERTYLIST: _iso.PROPERTYLIST)
        _metering.updateProperty(_model.getPropertyUInt32(UInt32(kEdsPropID_MeteringMode)), PROPERTYLIST: _metering.PROPERTYLIST)
        _exposureComp.updateProperty(_model.getPropertyUInt32(UInt32(kEdsPropID_ExposureCompensation)), PROPERTYLIST: _exposureComp.PROPERTYLIST)
        _imageQuality.updateProperty(_model.getPropertyUInt32(UInt32(kEdsPropID_ImageQuality)), PROPERTYLIST: _imageQuality.PROPERTYLIST)
        // At the time of application start, if the camera setting is 'Catch AF', make 'Evf_AFMode_LiveFace' forcibly.
        if (0x09 != _model.evfAFMode())
        {
            _evfMode.updateProperty(_model.getPropertyUInt32(UInt32(kEdsPropID_Evf_AFMode)), PROPERTYLIST: _evfMode.PROPERTYLIST)
        }
        else
        {
            var evfAFMode: EdsUInt32 = 0x02
            EdsSetPropertyData(_model.getCameraObject(), EdsPropertyID(kEdsPropID_Evf_AFMode), 0, EdsUInt32(MemoryLayout<EdsUInt32>.size), &evfAFMode)
        }
        _whiteBalance.updateProperty(_model.getPropertyUInt32(UInt32(kEdsPropID_WhiteBalance)), PROPERTYLIST: _whiteBalance.PROPERTYLIST)
        _driveMode.updateProperty(_model.getPropertyUInt32(UInt32(kEdsPropID_DriveMode)), PROPERTYLIST: _driveMode.PROPERTYLIST)
        _flashMode.updateProperty(_model.getPropertyUInt32(UInt32(kEdsPropID_DC_Strobe)), PROPERTYLIST: _flashMode.PROPERTYLIST)
        _movieQuality.updateProperty(_model.getPropertyUInt32(UInt32(kEdsPropID_MovieParam)), PROPERTYLIST: _movieQuality.PROPERTYLIST)
        _movieHFR.updateProperty(_model.getPropertyUInt32(UInt32(kEdsPropID_MovieHFRSetting)), PROPERTYLIST: _movieHFR.PROPERTYLIST)
        _pictureStyle.updateProperty(_model.getPropertyUInt32(UInt32(kEdsPropID_PictureStyle)), PROPERTYLIST: _pictureStyle.PROPERTYLIST)
        _aspect.updateProperty(_model.getPropertyUInt32(UInt32(kEdsPropID_Aspect)), PROPERTYLIST: _aspect.PROPERTYLIST)
        _afMode.updateProperty(_model.getPropertyUInt32(UInt32(kEdsPropID_AFMode)), PROPERTYLIST: _afMode.PROPERTYLIST)
        
        _availableShots.updateProperty(_model.getPropertyUInt32(UInt32(kEdsPropID_AvailableShots)))
        _battery.updateProperty(_model.getPropertyUInt32(UInt32(kEdsPropID_BatteryLevel)))
        _tempStatus.updateProperty(_model.getPropertyUInt32(UInt32(kEdsPropID_TempStatus)))
        _sliderOfZoom.updateProperty(_model.getPropertyUInt32(UInt32(kEdsPropID_DC_Zoom)))
        
    }
    
    func setupButtonCommand(){
        
        _takePictureButton.addActionListener(_controller)
        _takePictureButton.setCommand(ActionEvent.Command.take_PICTURE)
        
        _pressComplete.addActionListener(_controller)
        _pressComplete.setCommand(ActionEvent.Command.press_COMPLETELY)
        
        _pressHalfway.addActionListener(_controller)
        _pressHalfway.setCommand(ActionEvent.Command.press_HALFWAY)
        
        _pressOff.addActionListener(_controller)
        _pressOff.setCommand(ActionEvent.Command.press_OFF)
        
        _focusFar1.addActionListener(_controller)
        _focusFar1.setCommand(ActionEvent.Command.focus_FAR1)
        
        _focusFar2.addActionListener(_controller)
        _focusFar2.setCommand(ActionEvent.Command.focus_FAR2)
        
        _focusFar3.addActionListener(_controller)
        _focusFar3.setCommand(ActionEvent.Command.focus_FAR3)
        
        _focusNear1.addActionListener(_controller)
        _focusNear1.setCommand(ActionEvent.Command.focus_NEAR1)
        
        _focusNear2.addActionListener(_controller)
        _focusNear2.setCommand(ActionEvent.Command.focus_NEAR2)
        
        _focusNear3.addActionListener(_controller)
        _focusNear3.setCommand(ActionEvent.Command.focus_NEAR3)
        
        _DoEvfAFON.addActionListener(_controller)
        _DoEvfAFON.setCommand(ActionEvent.Command.evf_AF_ON)
        
        _DoEvfAFOFF.addActionListener(_controller)
        _DoEvfAFOFF.setCommand(ActionEvent.Command.evf_AF_OFF)
        
        _sliderOfZoom.addActionListener(_controller)
        _sliderOfZoom.setCommand(ActionEvent.Command.set_ZOOM)

        _zoomFit.addActionListener(_controller)
        _zoomFit.setCommand(ActionEvent.Command.zoom_FIT)

        _zoomZoom.addActionListener(_controller)
        _zoomZoom.setCommand(ActionEvent.Command.zoom_ZOOM)
        
        _positionUp.addActionListener(_controller)
        _positionUp.setCommand(ActionEvent.Command.zoom_UP)
        
        _positionLeft.addActionListener(_controller)
        _positionLeft.setCommand(ActionEvent.Command.zoom_LEFT)
        
        _positionRight.addActionListener(_controller)
        _positionRight.setCommand(ActionEvent.Command.zoom_RIGHT)

        _positionDown.addActionListener(_controller)
        _positionDown.setCommand(ActionEvent.Command.zoom_DOWN)

        _rollPitchOnOff.addActionListener(_controller)
        _rollPitchOnOff.setCommand(ActionEvent.Command.rool_PITCH)

        _stillImage.addActionListener(_controller)
        _stillImage.setCommand(ActionEvent.Command.press_STILL)

        _movieMode.addActionListener(_controller)
        _movieMode.setCommand(ActionEvent.Command.press_MOVIE)

        _recStart.addActionListener(_controller)
        _recStart.setCommand(ActionEvent.Command.rec_START)

        _recEnd.addActionListener(_controller)
        _recEnd.setCommand(ActionEvent.Command.rec_END)

        _clickWB.addActionListener(_controller)
        _clickWB.setCommand(ActionEvent.Command.click_WB)
        
        _clickAF.addActionListener(_controller)
        _clickAF.setCommand(ActionEvent.Command.click_AF)

        _mirrorUpOn.addActionListener(_controller)
        _mirrorUpOn.setCommand(ActionEvent.Command.mirrorup_ON)

        _mirrorUpOff.addActionListener(_controller)
        _mirrorUpOff.setCommand(ActionEvent.Command.mirrorup_OFF)

        _startEvfButton.action = #selector(self.ViewImage)
        _endEvfButton.action = #selector(self.ViewNone)
        _sliderOfZoom.action = #selector(self.Slider)

    }
    
    func setupPopUpCommand(){
        
        _aeMode.addActionListener(_controller)
        _aeMode.setCommand(ActionEvent.Command.set_AE_MODE)
        _aeMode.setPropertyDesc(_model.getPropertyDesc(EdsUInt32(kEdsPropID_AEModeSelect)))
        
        _tv.addActionListener(_controller)
        _tv.setCommand(ActionEvent.Command.set_TV)
        _tv.setPropertyDesc(_model.getPropertyDesc(EdsUInt32(kEdsPropID_Tv)))
        
        _av.addActionListener(_controller)
        _av.setCommand(ActionEvent.Command.set_AV)
        _av.setPropertyDesc(_model.getPropertyDesc(EdsUInt32(kEdsPropID_Av)))
        
        _iso.addActionListener(_controller)
        _iso.setCommand(ActionEvent.Command.set_ISO_SPEED)
        _iso.setPropertyDesc(_model.getPropertyDesc(EdsUInt32(kEdsPropID_ISOSpeed)))
     
        _metering.addActionListener(_controller)
        _metering.setCommand(ActionEvent.Command.set_METERING_MODE)
        _metering.setPropertyDesc(_model.getPropertyDesc(EdsUInt32(kEdsPropID_MeteringMode)))
        
        _exposureComp.addActionListener(_controller)
        _exposureComp.setCommand(ActionEvent.Command.set_EXPOSURE_COMPENSATION)
        _exposureComp.setPropertyDesc(_model.getPropertyDesc(EdsUInt32(kEdsPropID_ExposureCompensation)))
        
        _imageQuality.addActionListener(_controller)
        _imageQuality.setCommand(ActionEvent.Command.set_IMAGEQUALITY)
        _imageQuality.setPropertyDesc(_model.getPropertyDesc(EdsUInt32(kEdsPropID_ImageQuality)))
        
        _evfMode.addActionListener(_controller)
        _evfMode.setCommand(ActionEvent.Command.set_EVF_AFMODE)
        _evfMode.setPropertyDesc(_model.getPropertyDesc(EdsUInt32(kEdsPropID_Evf_AFMode)))

        _whiteBalance.addActionListener(_controller)
        _whiteBalance.setCommand(ActionEvent.Command.set_WHITE_BALANCE)
        _whiteBalance.setPropertyDesc(_model.getPropertyDesc(EdsUInt32(kEdsPropID_WhiteBalance)))
        
        _driveMode.addActionListener(_controller)
        _driveMode.setCommand(ActionEvent.Command.set_DRIVE_MODE)
        _driveMode.setPropertyDesc(_model.getPropertyDesc(EdsUInt32(kEdsPropID_DriveMode)))
        
        _flashMode.addActionListener(_controller)
        _flashMode.setCommand(ActionEvent.Command.set_STROBO)
        _flashMode.setPropertyDesc(_model.getPropertyDesc(EdsUInt32(kEdsPropID_DC_Strobe)))
        
        _movieQuality.addActionListener(_controller)
        _movieQuality.setCommand(ActionEvent.Command.set_MOVIEQUALITY)
        _movieQuality.setPropertyDesc(_model.getPropertyDesc(EdsUInt32(kEdsPropID_MovieParam)))
        
        _movieHFR.addActionListener(_controller)
        _movieHFR.setCommand(ActionEvent.Command.set_MOVIE_HFR)
        _movieHFR.setPropertyDesc(_model.getPropertyDesc(EdsUInt32(kEdsPropID_MovieHFRSetting)))
        
        _pictureStyle.addActionListener(_controller)
        _pictureStyle.setCommand(ActionEvent.Command.set_PICTURESTYLE)
        _pictureStyle.setPropertyDesc(_model.getPropertyDesc(EdsUInt32(kEdsPropID_PictureStyle)))
        
        _aspect.addActionListener(_controller)
        _aspect.setCommand(ActionEvent.Command.set_ASPECT)
        _aspect.setPropertyDesc(_model.getPropertyDesc(EdsUInt32(kEdsPropID_Aspect)))
        
        _afMode.addActionListener(_controller)
        _afMode.setCommand(ActionEvent.Command.set_AF_MODE)
        _afMode.setPropertyDesc(_model.getPropertyDesc(EdsUInt32(kEdsPropID_AFMode)))
        
    }
    
    func removeActionSource(){
        
        _takePictureButton.removeActionListener()
        _pressComplete.removeActionListener()
        _pressHalfway.removeActionListener()
        _pressOff.removeActionListener()
        _focusFar1.removeActionListener()
        _focusFar2.removeActionListener()
        _focusFar3.removeActionListener()
        _focusNear1.removeActionListener()
        _focusNear2.removeActionListener()
        _focusNear3.removeActionListener()
        _zoomFit.removeActionListener()
        _zoomZoom.removeActionListener()
        _positionUp.removeActionListener()
        _positionLeft.removeActionListener()
        _positionRight.removeActionListener()
        _positionDown.removeActionListener()
        _rollPitchOnOff.removeActionListener()
        _DoEvfAFON.removeActionListener()
        _DoEvfAFOFF.removeActionListener()
        _sliderOfZoom.removeActionListener()
        _aeMode.removeActionListener()
        _tv.removeActionListener()
        _av.removeActionListener()
        _iso.removeActionListener()
        _metering.removeActionListener()
        _exposureComp.removeActionListener()
        _imageQuality.removeActionListener()
        _evfMode.removeActionListener()
        _whiteBalance.removeActionListener()
        _driveMode.removeActionListener()
        _flashMode.removeActionListener()
        _afMode.removeActionListener()
        _pictureStyle.removeActionListener()
        _aspect.removeActionListener()
        
    }

    func controlFocusButton(){
        let onOff = 0x02 != _model.evfAFMode()
        _positionUp.isEnabled = onOff
        _positionLeft.isEnabled = onOff
        _positionRight.isEnabled = onOff
        _positionDown.isEnabled = onOff
    }
    
    func updateAngleInfoLabel(pos: String, roll: String, pitc: String){
        _positionValue.stringValue = pos
        _rollingValue.stringValue = roll
        _pitchingValue.stringValue = pitc

        if (0 == _model.getPropertyUInt32(EdsUInt32(kEdsPropID_EVF_RollingPitching)))
        {
            _rollPitchOnOff.title = "Roll Pitch Off"
        }
        else
        {
            _rollPitchOnOff.title = "Roll Pitch On"
        }
    }
    
    func updateFixedMovie(data: UInt32){
        if (data == 0)
        {
            _stillImage.state = NSControl.StateValue.on

            // Rec Button
            self._recStart.isEnabled = false
            self._recEnd.isEnabled = false
            
            if (_controller.getCameraModel().getIsTypeDS())
            {
                self._focusFar1.isEnabled = true
                self._focusFar2.isEnabled = true
                self._focusFar3.isEnabled = true
                self._focusNear1.isEnabled = true
                self._focusNear2.isEnabled = true
                self._focusNear3.isEnabled = true
            }
            
            // Clear EVF
            self.ViewNone()
        }
        else
        {
            _movieMode.state = NSControl.StateValue.on
            
            // Rec Button
            self._recStart.isEnabled = true
            self._recEnd.isEnabled = true
            
            self._focusFar1.isEnabled = false
            self._focusFar2.isEnabled = false
            self._focusFar3.isEnabled = false
            self._focusNear1.isEnabled = false
            self._focusNear2.isEnabled = false
            self._focusNear3.isEnabled = false
        }
    }
    
    
    func updateMirrorLockUpState(data: UInt32){
        if (data != 0)
        {
            _mirrorUpOn.state = NSControl.StateValue.on
        }
        else
        {
            _mirrorUpOff.state = NSControl.StateValue.on
        }
    }
    
    func changeMouseCursor(onOff: Bool){
        if (onOff)
        {
            let cursor: NSCursor = .crosshair
            cursor.set()
            _isClickEvfImage = true
            
            let point = NSPoint(x: _evfImage.frame.width * 0.5, y: _evfImage.frame.height * 0.5)
            let pointInWindow = _evfImage.convert(point, to: nil)
            if let pointOnScreen = _evfImage.window?.convertPoint(toScreen: pointInWindow)
            {
                let cgPoint = CGPoint(x: pointOnScreen.x, y: (NSScreen.main?.frame.maxY)! - pointOnScreen.y)
                CGWarpMouseCursorPosition(cgPoint)
            }
        }
        else
        {
            let cursor: NSCursor = _cursor
            cursor.set()
            _isClickEvfImage = false
        }
    }
    
    override func mouseDown(with event: NSEvent) {
        let clickPos = CGPoint(x: event.locationInWindow.x, y: event.locationInWindow.y)

        if (!_isClickEvfImage)
        {
            return
            
        }
        
        if (_evfImage.frame.minX <= clickPos.x && _evfImage.frame.maxX >= clickPos.x)
        {
            if (_evfImage.frame.minY <= clickPos.y && _evfImage.frame.maxY >= clickPos.y)
            {
                var JpegLWidth: Int32 = 6720
                var JpegLHeight: Int32 = 4480
                if (_model.getSizeJpeglarge().width != 0 && _model.getSizeJpeglarge().height != 0)
                {
                    JpegLWidth = _model.getSizeJpeglarge().width
                    JpegLHeight = _model.getSizeJpeglarge().height
                }
                
                let imageLocX: CGFloat = _evfImage.frame.origin.x
                let imageLocY: CGFloat = _evfImage.frame.origin.y + _evfImage.frame.size.height
                var clickPoint = EdsPoint()
                clickPoint.x = (EdsInt32)(Double(JpegLWidth) / Double(self._evfImage.frame.size.width) * Double(clickPos.x - imageLocX))
                clickPoint.y = (EdsInt32)(Double(JpegLHeight) / Double(self._evfImage.frame.size.height) * Double(abs(imageLocY - clickPos.y)))
                if (clickPoint.x > JpegLWidth - 1)
                {
                    clickPoint.x = JpegLWidth - 1
                }
                else
                {
                    if (clickPoint.x < 0)
                    {
                        clickPoint.x = 0
                    }
                }

                if (clickPoint.y > JpegLHeight - 1)
                {
                    clickPoint.y = JpegLHeight - 1
                }
                else
                {
                    if (clickPoint.y < 0)
                    {
                        clickPoint.y = 0
                    }
                }
                _model.setClickPoint(clickPoint.x << 16 | clickPoint.y)

                var event = CameraEvent(type:.mouse_CURSOR, arg: Int32(0) as AnyObject)
                let viewNotification = ViewNotification()
                viewNotification.viewNotificationObservers(&event)
                
                let cursor: NSCursor = _cursor
                cursor.set()
            }
        }
    }

    override func mouseMoved(with event: NSEvent) {

        var clickPos = CGPoint(x: event.locationInWindow.x, y: event.locationInWindow.y)
       
        if (clickPos.x < _evfImage.frame.minX)
        {
            clickPos.x = _evfImage.frame.minX
        }
        if (clickPos.x > _evfImage.frame.maxX)
        {
            clickPos.x = _evfImage.frame.maxX
        }

        if (clickPos.y < _evfImage.frame.minY)
        {
            clickPos.y = _evfImage.frame.minY
        }
        if (clickPos.y > _evfImage.frame.maxY)
        {
            clickPos.y = _evfImage.frame.maxY
        }

        if (clickPos != event.locationInWindow)
        {
            if let pointOnScreen = _evfImage.window?.convertPoint(toScreen: clickPos)
            {
                let cgPoint = CGPoint(x: pointOnScreen.x, y: (NSScreen.main?.frame.maxY)! - pointOnScreen.y)
                CGWarpMouseCursorPosition(cgPoint)
            }
        }
        return
    }
}
