//
//  RemoteControl.swift
//  CameraControl
//
//  Created by YamamotoAkihisa on 2016/10/25.
//
//

import Cocoa

class RemoteControl: NSWindowController, NSWindowDelegate{
    
    private var _model : CameraModel!
    private var _controller : CameraController!
    private var _liveView: CameraEvfData!
    private var _isLiveViewActive = false
    
    
    private let AEMODE_TAG: Int =               1
    private let TV_TAG: Int =                   2
    private let AV_TAG: Int =                   3
    private let ISO_TAG: Int =                  4
    private let METERING_TAG: Int =             5
    private let EXPOSURE_TAG: Int =             6
    private let IMAGEQUALITY_TAG: Int =         7
    private let EVF_AFMODE_TAG: Int =           8
    private let WHITEBALANCE_TAG: Int =         9
    private let DRIVEMODE_TAG: Int =            10
    private let ASPECTRATIO_TAG: Int =          11
    private let ZOOMSLIDER_TAG: Int =           12
    private let AFMODE_TAG: Int =               13
    private let STROBO_TAG: Int =               14
    
    @IBOutlet weak var zoomValue: NSTextField!
   
    @IBOutlet weak var Strobo: StroboPopUp!
    @IBOutlet weak var sliderOfZoom: ZoomSlider!
    @IBOutlet weak var Aspect: AspectRatio!
    @IBOutlet weak var Battery: BatteryLevel!
    @IBOutlet weak var Shots: AvailableShots!
    
    @IBOutlet weak var AFMode: AFModePopUp!
    @IBOutlet weak var DriveMode: DriveModePopUp!
    @IBOutlet weak var WhiteBalanceValue: WhiteBalancePopUp!
    @IBOutlet weak var AEMode: AEModePopUp!
    @IBOutlet weak var TV: TVPopUp!
    @IBOutlet weak var AV: AVPopUp!
    @IBOutlet weak var Iso: IsoPopUp!
    @IBOutlet weak var Metering: MeteringPopUp!
    @IBOutlet weak var EvfMode: EVFAFModePopUp!
    @IBOutlet weak var ImageQuality: ImageQualityPopUp!
    @IBOutlet weak var Exposure: ExposurePopUp!
    
    @IBOutlet weak var focusFar1: NSButton!
    @IBOutlet weak var focusFar2: NSButton!
    @IBOutlet weak var focusFar3: NSButton!
    
    @IBOutlet weak var focusNear1: NSButton!
    @IBOutlet weak var focusNear2: NSButton!
    @IBOutlet weak var focusNear3: NSButton!
    
    @IBOutlet weak var EndEVFbutton: NSButton!
    @IBOutlet weak var button: NSButton!
    @IBOutlet weak var StartEVFbutton: NSButton!
    @IBOutlet weak var evfImageView: EvfPictureView!
    @IBOutlet weak var halfway: NSButton!
    @IBOutlet weak var pressOff: NSButton!
    @IBOutlet weak var pressComplete: NSButton!
    
    @IBOutlet weak var pressEvfAFOn: NSButton!
    @IBOutlet weak var pressEvfAFOff: NSButton!
    
    @IBAction func PopUp(sender: AnyObject) {
        
        var property: EdsUInt32 = 0
        var propertyID: EdsUInt32 = 0
        
        switch sender.tag {
        case AEMODE_TAG:
            propertyID = EdsUInt32(kEdsPropID_AEMode)
            property = AEMode.GetPropertyFromPropertyList(_model.getPropertyDesc(propertyID))
        case TV_TAG:
            propertyID = EdsUInt32(kEdsPropID_Tv)
            property = TV.GetPropertyFromPropertyList(_model.getPropertyDesc(propertyID))
        case AV_TAG:
            propertyID = EdsUInt32(kEdsPropID_Av)
            property = AV.GetPropertyFromPropertyList(_model.getPropertyDesc(propertyID))
        case ISO_TAG:
            propertyID = EdsUInt32(kEdsPropID_ISOSpeed)
            property = Iso.GetPropertyFromPropertyList(_model.getPropertyDesc(propertyID))
        case METERING_TAG:
            propertyID = EdsUInt32(kEdsPropID_MeteringMode)
            property = Metering.GetPropertyFromPropertyList(_model.getPropertyDesc(propertyID))
        case EXPOSURE_TAG:
            propertyID = EdsUInt32(kEdsPropID_ExposureCompensation)
            property = Exposure.GetPropertyFromPropertyList(_model.getPropertyDesc(propertyID))
        case IMAGEQUALITY_TAG:
            propertyID = EdsUInt32(kEdsPropID_ImageQuality)
            property = ImageQuality.GetPropertyFromPropertyList(_model.getPropertyDesc(propertyID))
        case EVF_AFMODE_TAG:
            propertyID = EdsUInt32(kEdsPropID_Evf_AFMode)
            property = EvfMode.GetPropertyFromPropertyList(_model.getPropertyDesc(propertyID))
        case WHITEBALANCE_TAG:
            propertyID = EdsUInt32(kEdsPropID_WhiteBalance)
            property = WhiteBalanceValue.GetPropertyFromPropertyList(_model.getPropertyDesc(propertyID))
        case DRIVEMODE_TAG:
            propertyID = EdsUInt32(kEdsPropID_DriveMode)
            property = DriveMode.GetPropertyFromPropertyList(_model.getPropertyDesc(propertyID))
        case ASPECTRATIO_TAG:
            propertyID = EdsUInt32(kEdsPropID_Aspect)
            property = Aspect.GetPropertyFromPropertyList(_model.getPropertyDesc(propertyID))
        case AFMODE_TAG:
            propertyID = EdsUInt32(kEdsPropID_AFMode)
            property = AFMode.GetPropertyFromPropertyList(_model.getPropertyDesc(propertyID))
        case STROBO_TAG:
            propertyID = EdsUInt32(kEdsPropID_DC_Strobe)
            property = Strobo.GetPropertyFromPropertyList(_model.getPropertyDesc(propertyID))
        case ZOOMSLIDER_TAG:
            propertyID = EdsUInt32(kEdsPropID_DC_Zoom)
            property = EdsUInt32(sender.doubleValue)
        default:
            break
        }
        
        _controller.postCommand(SetPropertyCommandWithData(model: _model, propertyID: propertyID, data: property))
        
    }
    
    init(controller: CameraController){
        
        super.init(window: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.update(_:)), name: "MY_VIEW_UPDATE", object: nil)
        NSBundle.mainBundle().loadNibNamed("CameraControl", owner: self, topLevelObjects: nil)
        
        self._controller = controller
        _model = _controller.getCameraModel()
        
        self.setupButtonCommand()
        self.setTag()
        
        self.setParameterToCameraControler()
        
    }
    
    required init?(coder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
        
    }
    
    func windowShouldClose(sender: AnyObject) -> Bool { return true }
    
    func windowWillClose(notification: NSNotification) {
        
        self.ViewNone()
        NSApp.stopModal()
        NSApp.abortModal()
        
    }
    
    func PressOff(){ _controller.postCommand(PressingShutterButtomCommand(model: _model,
        parameter: EdsInt32(kEdsCameraCommand_ShutterButton_OFF.rawValue)))
        }
    
    func TakePicture(){ _controller.postCommand(TakePictureCommand(model: _model)) }
    
    func Halfway(){ _controller.postCommand(PressingShutterButtomCommand(model: _model,
        parameter: EdsInt32(kEdsCameraCommand_ShutterButton_Halfway.rawValue)))
    }
    
    func PressComplete(){ _controller.postCommand(PressingShutterButtomCommand(model: _model,
        parameter: EdsInt32(kEdsCameraCommand_ShutterButton_Completely.rawValue)))
    }
    
    func PressEvfAFOn(){
        _controller.postCommand(EvfAFCommand(model: _model, parameter: EdsInt32(kEdsCameraCommand_EvfAf_ON.rawValue)))
        
    }
    func PressEvfAFOff(){
        _controller.postCommand(EvfAFCommand(model: _model, parameter: EdsInt32(kEdsCameraCommand_EvfAf_OFF.rawValue)))
    }
    
    func FocusToFar1(){
        
        _controller.postCommand(DriveLensEvfCommand(model: _model, parameter: EdsInt32(kEdsEvfDriveLens_Far1.rawValue)))
        
    }
    
    func FocusToNear1(){
        
        _controller.postCommand(DriveLensEvfCommand(model: _model, parameter: EdsInt32(kEdsEvfDriveLens_Near1.rawValue)))
    }
    
    func FocusToFar2(){
        
        _controller.postCommand(DriveLensEvfCommand(model: _model, parameter: EdsInt32(kEdsEvfDriveLens_Far2.rawValue)))
        
    }
    
    func FocusToNear2(){
        
        _controller.postCommand(DriveLensEvfCommand(model: _model, parameter: EdsInt32(kEdsEvfDriveLens_Near2.rawValue)))
    }
    
    func FocusToFar3(){
        
        _controller.postCommand(DriveLensEvfCommand(model: _model, parameter: EdsInt32(kEdsEvfDriveLens_Far3.rawValue)))
        
    }
    
    func FocusToNear3(){
        
        _controller.postCommand(DriveLensEvfCommand(model: _model, parameter: EdsInt32(kEdsEvfDriveLens_Near3.rawValue)))
    }
    
    func ViewImage() {
        
        if (_isLiveViewActive == false){
            _isLiveViewActive = true
            _controller.postCommand(StartEvfCommand(model: _model))
        }
        
    }
    
    func ViewNone(){
        
        if (_isLiveViewActive){
            _isLiveViewActive = false
            self.evfImageView.image = nil
            _controller.postCommand(EndEvfCommand(model: _model))
            self.sliderOfZoom.enabled = false
        }
    }
    
    func update(notification: NSNotification?) {
        
        let event = notification?.object as! CameraEvent
        
        let arg = event.getArg()
        
        switch(event.getEvent()){
        case .DOWNLOAD_EVF:             _controller.postCommand(DownloadEvfCommand(model: _model))
        case .EVF_DATA_CHANGED:         self.drawImage(arg)
        case .PROPERTY_CHANGED:         self.GetPropertyChangedMessage(arg)
        case .PROPERTYDESC_CHANGED:     self.GetPropertyDescChangedMessage(arg)
        case .TERMINATE_APP:            self.tetminateApplication()
        case .PROGRESS_REPORT:
            break
        case .DEVICE_BUSY:
            break
        case .ERROR:
            break
        default:
            break;
        }
    }
    
    func drawImage(arg: AnyObject){
        
         _controller.postCommand(GetPropertyCommand(model: _model, propertyID: EdsUInt32(kEdsPropID_FocusInfo)))
        self.evfImageView.drawImage(_model, arg: arg)
        
        if (_isLiveViewActive){
            _controller.postCommand(DownloadEvfCommand(model: _model))
        }
    }

    func tetminateApplication(){
        
        self.ViewNone()
        NSApp.stopModal()
        NSApp.abortModal()
        NSApp.terminate(NSApp.windows)
        
    }
    
    func GetPropertyChangedMessage(arg: AnyObject){
        
        let propertyID = arg.intValue
        let propertyId: EdsUInt32 = _model.getPropertyUInt32(EdsUInt32(propertyID))
        
        switch(propertyID){
        case Int32(kEdsPropID_AEMode): self.AEMode.updateProperty(propertyId, PROPERTYLIST: AEMode.PROPERTYLIST)
        case Int32(kEdsPropID_Tv): self.TV.updateProperty(propertyId, PROPERTYLIST: TV.PROPERTYLIST)
        case Int32(kEdsPropID_Av): self.AV.updateProperty(propertyId, PROPERTYLIST: AV.PROPERTYLIST)
        case Int32(kEdsPropID_ISOSpeed): self.Iso.updateProperty(propertyId, PROPERTYLIST: Iso.PROPERTYLIST)
        case Int32(kEdsPropID_MeteringMode): self.Metering.updateProperty(propertyId, PROPERTYLIST: Metering.PROPERTYLIST)
        case Int32(kEdsPropID_ExposureCompensation): self.Exposure.updateProperty(propertyId, PROPERTYLIST: Exposure.PROPERTYLIST)
        case Int32(kEdsPropID_ImageQuality): self.ImageQuality.updateProperty(propertyId, PROPERTYLIST: ImageQuality.PROPERTYLIST)
        case Int32(kEdsPropID_Evf_AFMode): self.EvfMode.updateProperty(propertyId, PROPERTYLIST: EvfMode.PROPERTYLIST)
        case Int32(kEdsPropID_AvailableShots): self.Shots.updateProperty(propertyId)
        case Int32(kEdsPropID_BatteryLevel): self.Battery.updateProperty(propertyId)
        case Int32(kEdsPropID_WhiteBalance): self.WhiteBalanceValue.updateProperty(propertyId, PROPERTYLIST: WhiteBalanceValue.PROPERTYLIST)
        case Int32(kEdsPropID_DriveMode): self.DriveMode.updateProperty(propertyId, PROPERTYLIST: DriveMode.PROPERTYLIST)
        case Int32(kEdsPropID_Aspect): self.Aspect.updateProperty(propertyId, PROPERTYLIST: Aspect.PROPERTYLIST)
        case Int32(kEdsPropID_AFMode): self.AFMode.updateProperty(propertyId, PROPERTYLIST: AFMode.PROPERTYLIST)
        case Int32(kEdsPropID_DC_Strobe): self.Strobo.updateProperty(propertyId, PROPERTYLIST: Strobo.PROPERTYLIST)
        case Int32(kEdsPropID_FocusInfo):
            _controller.postCommand(GetPropertyCommand(model: _model, propertyID: EdsUInt32(kEdsPropID_FocusInfo)))
        case Int32(kEdsPropID_DC_Zoom):
            let value = _model.getPropertyUInt32(UInt32(kEdsPropID_DC_Zoom))
            self.zoomValue.stringValue = String(value)
            self.sliderOfZoom.updateProperty(value)
        default:
            break
        }
    }
    
    func GetPropertyDescChangedMessage(arg: AnyObject){
        
        let propertyID = arg.intValue
        let propertyDesc = _model.getPropertyDesc(EdsUInt32(propertyID))
        switch(propertyID){
        case Int32(kEdsPropID_AEMode):
            self.AEMode.updatePropertyDesc(propertyDesc, PROPERTYLIST: AEMode.PROPERTYLIST)
        case Int32(kEdsPropID_Tv):
            self.TV.updatePropertyDesc(propertyDesc, PROPERTYLIST: TV.PROPERTYLIST)
        case Int32(kEdsPropID_Av):
            self.AV.updatePropertyDesc(propertyDesc, PROPERTYLIST: AV.PROPERTYLIST)
        case Int32(kEdsPropID_ISOSpeed):
            self.Iso.updatePropertyDesc(propertyDesc, PROPERTYLIST: Iso.PROPERTYLIST)
        case Int32(kEdsPropID_MeteringMode):
            self.Metering.updatePropertyDesc(propertyDesc, PROPERTYLIST: Metering.PROPERTYLIST)
        case Int32(kEdsPropID_ExposureCompensation):
            self.Exposure.updatePropertyDesc(propertyDesc, PROPERTYLIST: Exposure.PROPERTYLIST)
        case Int32(kEdsPropID_ImageQuality):
            self.ImageQuality.updatePropertyDesc(propertyDesc, PROPERTYLIST: ImageQuality.PROPERTYLIST)
        case Int32(kEdsPropID_Evf_AFMode):
            self.EvfMode.updatePropertyDesc(propertyDesc, PROPERTYLIST: EvfMode.PROPERTYLIST)
        case Int32(kEdsPropID_WhiteBalance):
            self.WhiteBalanceValue.updatePropertyDesc(propertyDesc, PROPERTYLIST: WhiteBalanceValue.PROPERTYLIST)
        case Int32(kEdsPropID_DriveMode):
            self.DriveMode.updatePropertyDesc(propertyDesc, PROPERTYLIST: DriveMode.PROPERTYLIST)
        case Int32(kEdsPropID_Aspect):
            self.Aspect.updatePropertyDesc(propertyDesc, PROPERTYLIST: Aspect.PROPERTYLIST)
        case Int32(kEdsPropID_AFMode):
            self.AFMode.updatePropertyDesc(propertyDesc, PROPERTYLIST: AFMode.PROPERTYLIST)
        case Int32(kEdsPropID_DC_Strobe):
            self.Strobo.updatePropertyDesc(propertyDesc, PROPERTYLIST: Strobo.PROPERTYLIST)
        case Int32(kEdsPropID_DC_Zoom):
            self.sliderOfZoom.updatePropertyDesc(propertyDesc)
        default:
            break
        }
    }
    
    func setParameterToCameraControler(){
        
        AEMode.updatePropertyDesc(_model.getPropertyDesc(UInt32(kEdsPropID_AEMode)), PROPERTYLIST: AEMode.PROPERTYLIST )
        TV.updatePropertyDesc(_model.getPropertyDesc(UInt32(kEdsPropID_Tv)), PROPERTYLIST: TV.PROPERTYLIST)
        AV.updatePropertyDesc(_model.getPropertyDesc(UInt32(kEdsPropID_Av)), PROPERTYLIST: AV.PROPERTYLIST)
        Iso.updatePropertyDesc(_model.getPropertyDesc(UInt32(kEdsPropID_ISOSpeed)), PROPERTYLIST: Iso.PROPERTYLIST)
        Metering.updatePropertyDesc(_model.getPropertyDesc(UInt32(kEdsPropID_MeteringMode)), PROPERTYLIST: Metering.PROPERTYLIST)
        Exposure.updatePropertyDesc(_model.getPropertyDesc(UInt32(kEdsPropID_ExposureCompensation)), PROPERTYLIST: Exposure.PROPERTYLIST)
        ImageQuality.updatePropertyDesc(_model.getPropertyDesc(UInt32(kEdsPropID_ImageQuality)), PROPERTYLIST: ImageQuality.PROPERTYLIST)
        EvfMode.updatePropertyDesc(_model.getPropertyDesc(UInt32(kEdsPropID_Evf_AFMode)), PROPERTYLIST: EvfMode.PROPERTYLIST)
        WhiteBalanceValue.updatePropertyDesc(_model.getPropertyDesc(UInt32(kEdsPropID_WhiteBalance)), PROPERTYLIST: WhiteBalanceValue.PROPERTYLIST)
        DriveMode.updatePropertyDesc(_model.getPropertyDesc(UInt32(kEdsPropID_DriveMode)), PROPERTYLIST: DriveMode.PROPERTYLIST)
        Aspect.updatePropertyDesc(_model.getPropertyDesc(UInt32(kEdsPropID_Aspect)), PROPERTYLIST: Aspect.PROPERTYLIST)
        AFMode.updatePropertyDesc(_model.getPropertyDesc(UInt32(kEdsPropID_AFMode)), PROPERTYLIST: AFMode.PROPERTYLIST)
        Strobo.updatePropertyDesc(_model.getPropertyDesc(UInt32(kEdsPropID_DC_Strobe)), PROPERTYLIST: Strobo.PROPERTYLIST)
        zoomValue.stringValue = ""
        sliderOfZoom.updatePropertyDesc(_model.getPropertyDesc(UInt32(kEdsPropID_DC_Zoom)))
        
        AEMode.updateProperty(_model.getPropertyUInt32(UInt32(kEdsPropID_AEMode)), PROPERTYLIST: AEMode.PROPERTYLIST)
        TV.updateProperty(_model.getPropertyUInt32(UInt32(kEdsPropID_Tv)), PROPERTYLIST: TV.PROPERTYLIST)
        AV.updateProperty(_model.getPropertyUInt32(UInt32(kEdsPropID_Av)), PROPERTYLIST: AV.PROPERTYLIST)
        Iso.updateProperty(_model.getPropertyUInt32(UInt32(kEdsPropID_ISOSpeed)), PROPERTYLIST: Iso.PROPERTYLIST)
        Metering.updateProperty(_model.getPropertyUInt32(UInt32(kEdsPropID_MeteringMode)), PROPERTYLIST: Metering.PROPERTYLIST)
        Exposure.updateProperty(_model.getPropertyUInt32(UInt32(kEdsPropID_ExposureCompensation)), PROPERTYLIST: Exposure.PROPERTYLIST)
        ImageQuality.updateProperty(_model.getPropertyUInt32(UInt32(kEdsPropID_ImageQuality)), PROPERTYLIST: ImageQuality.PROPERTYLIST)
        EvfMode.updateProperty(_model.getPropertyUInt32(UInt32(kEdsPropID_Evf_AFMode)), PROPERTYLIST: EvfMode.PROPERTYLIST)
        WhiteBalanceValue.updateProperty(_model.getPropertyUInt32(UInt32(kEdsPropID_WhiteBalance)), PROPERTYLIST: WhiteBalanceValue.PROPERTYLIST)
        DriveMode.updateProperty(_model.getPropertyUInt32(UInt32(kEdsPropID_DriveMode)), PROPERTYLIST: DriveMode.PROPERTYLIST)
        Shots.updateProperty(_model.getPropertyUInt32(UInt32(kEdsPropID_AvailableShots)))
        Battery.updateProperty(_model.getPropertyUInt32(UInt32(kEdsPropID_BatteryLevel)))
        Aspect.updateProperty(_model.getPropertyUInt32(UInt32(kEdsPropID_Aspect)), PROPERTYLIST: Aspect.PROPERTYLIST)
        AFMode.updateProperty(_model.getPropertyUInt32(UInt32(kEdsPropID_AFMode)), PROPERTYLIST: AFMode.PROPERTYLIST)
        Strobo.updateProperty(_model.getPropertyUInt32(UInt32(kEdsPropID_DC_Strobe)), PROPERTYLIST: Strobo.PROPERTYLIST)
        sliderOfZoom.updateProperty(_model.getPropertyUInt32(UInt32(kEdsPropID_DC_Zoom)))
        
    }
    
    func setTag(){
       
        AEMode.tag = AEMODE_TAG
        TV.tag =  TV_TAG
        AV.tag = AV_TAG
        Iso.tag = ISO_TAG
        Metering.tag = METERING_TAG
        Exposure.tag = EXPOSURE_TAG
        ImageQuality.tag = IMAGEQUALITY_TAG
        EvfMode.tag = EVF_AFMODE_TAG
        WhiteBalanceValue.tag = WHITEBALANCE_TAG
        DriveMode.tag = DRIVEMODE_TAG
        Aspect.tag = ASPECTRATIO_TAG
        sliderOfZoom.tag = ZOOMSLIDER_TAG
        Strobo.tag = STROBO_TAG
        AFMode.tag = AFMODE_TAG
        
      
    }
    
    func setupButtonCommand(){
        
        button.action = #selector(self.TakePicture)
        StartEVFbutton.action = #selector(self.ViewImage)
        EndEVFbutton.action = #selector(self.ViewNone)
        halfway.action = #selector(self.Halfway)
        pressOff.action = #selector(self.PressOff)
        pressComplete.action = #selector(self.PressComplete)
        pressEvfAFOn.action = #selector(self.PressEvfAFOn)
        pressEvfAFOff.action = #selector(self.PressEvfAFOff)
        
        focusNear1.action = #selector(self.FocusToNear1)
        focusFar1.action = #selector(self.FocusToFar1)
        focusNear2.action = #selector(self.FocusToNear2)
        focusFar2.action = #selector(self.FocusToFar2)
        focusNear3.action = #selector(self.FocusToNear3)
        focusFar3.action = #selector(self.FocusToFar3)

    }
}

