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

class RecordFuncCardSetting : NSWindowController, NSWindowDelegate, NSTextFieldDelegate{
    
    
    @IBOutlet weak var  _stillMovieDivideSettingPopUp : NSPopUpButton!
    @IBOutlet weak var _cardExtensionPopUp : NSPopUpButton!
    @IBOutlet weak var _stillCurrentMediaPopUp : NSPopUpButton!
    @IBOutlet weak var _movieCardExtensionPopUp: NSPopUpButton!
    @IBOutlet weak var _movieCurrentMediaPopUp: NSPopUpButton!
    
    @IBAction func _stillMovieDivideSettingPopUp(_ sender: NSPopUpButton) {
        let array = getPropDesc2(_desc1)
        var divideSetting: Int32 = array[_stillMovieDivideSettingPopUp.indexOfSelectedItem]
        
        if(_stillMovieDivideSettingPrev != divideSetting){
            _stillMovieDivideSettingPrev = divideSetting
        }
        if(_stillMovieDivideSetting != divideSetting){
            EdsSetPropertyData(_model.getCameraObject(), EdsPropertyID(kEdsPropID_StillMovieDivideSetting), 0,  UInt32(MemoryLayout<UInt32>.size), &divideSetting)
          
           
        }
        _stillMovieDivideSetting = divideSetting
        
    }
    
    @IBAction func _cardExtensionPopUp(_ sender: NSPopUpButton) {
        let array = getPropDesc2(_desc2)
        var cardExtension: Int32 = array[_cardExtensionPopUp.indexOfSelectedItem]
        
        if(_cardExtensionPrev != cardExtension){
            _cardExtensionPrev = cardExtension
        }
        if(_cardExtension != cardExtension){
            EdsSetPropertyData(_model.getCameraObject(), EdsPropertyID(kEdsPropID_CardExtension), 0,  UInt32(MemoryLayout<UInt32>.size), &cardExtension)
        }
        _cardExtension = cardExtension
    }
    
    @IBAction func _stillCurrentMediaPopUp(_ sender: NSPopUpButton) {
        let array = getPropDesc2(_desc3)
        var stillCurrentMedia: Int32 = array[_stillCurrentMediaPopUp.indexOfSelectedItem]
        if(_stillCurrentMediaPrev != stillCurrentMedia){
            _stillCurrentMediaPrev = stillCurrentMedia
        }
        if(_stillCurrentMedia != stillCurrentMedia){
            EdsSetPropertyData(_model.getCameraObject(), EdsPropertyID(kEdsPropID_StillCurrentMedia), 0,  UInt32(MemoryLayout<UInt32>.size), &stillCurrentMedia)
        }
        _stillCurrentMedia = stillCurrentMedia
    }
    
    @IBAction func _movieCardExtensionPopUp(_ sender: NSPopUpButton) {
        let array = getPropDesc2(_desc4)
        var movieCardExtension: Int32 = array[_movieCardExtensionPopUp.indexOfSelectedItem]
        if(_movieCardExtensionPrev != movieCardExtension){
            _movieCardExtensionPrev = movieCardExtension
        }
        if(_movieCardExtension != movieCardExtension){
            EdsSetPropertyData(_model.getCameraObject(), EdsPropertyID(kEdsPropID_MovieCardExtension), 0,  UInt32(MemoryLayout<UInt32>.size), &movieCardExtension)
        }
        _movieCardExtension = movieCardExtension
    }
    
    @IBAction func _movieCurrentMediaPopUp(_ sender: NSPopUpButton) {
        let array = getPropDesc2(_desc5)
        var movieCurrentMedia: Int32 = array[_movieCurrentMediaPopUp.indexOfSelectedItem]
        if(_movieCurrentMediaPrev != movieCurrentMedia){
            _movieCurrentMediaPrev = movieCurrentMedia
        }
        if(_movieCurrentMedia != movieCurrentMedia){
            EdsSetPropertyData(_model.getCameraObject(), EdsPropertyID(kEdsPropID_MovieCurrentMedia), 0,  UInt32(MemoryLayout<UInt32>.size), &movieCurrentMedia)
        }
        _movieCurrentMedia = movieCurrentMedia
    }
    
    
    fileprivate var _controller : CameraController!
    fileprivate var _model : CameraModel!
    fileprivate var _desc1: EdsPropertyDesc = EdsPropertyDesc()
    fileprivate var _desc2: EdsPropertyDesc = EdsPropertyDesc()
    fileprivate var _desc3: EdsPropertyDesc = EdsPropertyDesc()
    fileprivate var _desc4: EdsPropertyDesc = EdsPropertyDesc()
    fileprivate var _desc5: EdsPropertyDesc = EdsPropertyDesc()
    
    var _stillMovieDivideSettingPrev: Int32 = 0
    var _cardExtensionPrev: Int32 = 0
    var _stillCurrentMediaPrev: Int32 = 0
    var _movieCardExtensionPrev: Int32 = 0
    var _movieCurrentMediaPrev: Int32 = 0
    
    var _stillMovieDivideSetting: Int32 = 0
    var _cardExtension: Int32 = 0
    var _stillCurrentMedia: Int32 = 0
    var _movieCardExtension: Int32 = 0
    var _movieCurrentMedia: Int32 = 0


    
    
    let PROPERTYLIST_1: NSDictionary = [
        0x00000000:"Disable",
        0x00000001:"Enable",
        0xffffffff:"unknown"
    ]
    let PROPERTYLIST_2: NSDictionary = [
        0x00000000:"Standard",
        0x00000001:"Rec. to multiple",
        0x00000002:"Rec. separately",
        0x00000003:"Auto switch card",
        0xffffffff:"unknown"
    ]
    let PROPERTYLIST_3: NSDictionary = [
        0x00000000:"Enable",
        0x00000001:"slot1",
        0x00000002:"slot2",
        0xffffffff:"unknown"
    ]
    let PROPERTYLIST_4: NSDictionary = [
        0x00000000:"Standard",
        0x00000001:"Rec. to multiple",
        0x00000002:"slot1=RAW and slot2=MP4",
        0x00000003:"Auto switch card",
        0xffffffff:"unknown"
    ]
    
    
    
    init(controller: CameraController) {
        super.init(window: nil)

        Bundle.main.loadNibNamed("RecordFuncCardSetting", owner: self, topLevelObjects: nil)
        _controller = controller
        _model = _controller.getCameraModel()
        
        
        //stillMovieDivideSetting
        EdsGetPropertyData(_model.getCameraObject(), EdsPropertyID(kEdsPropID_StillMovieDivideSetting), 0, UInt32(MemoryLayout<UInt32>.size), &_stillMovieDivideSetting)
        EdsGetPropertyDesc(_model.getCameraObject(), EdsPropertyID(kEdsPropID_StillMovieDivideSetting), &_desc1)
        _stillMovieDivideSettingPopUp.removeAllItems()
        if (_desc1.numElements != 0)
        {
            let array = getPropDesc2(_desc1)
            for i in 0 ..< _desc1.numElements {
                var outString_1: String = ""
                let value: Int = Int(array[Int(i)])
                if (value >= 0)
                {
                    outString_1 = PROPERTYLIST_1[value] as! String
                }
                if (outString_1 != "" && outString_1 != "unknown")
                {
                    // Create list of combo box
                    _stillMovieDivideSettingPopUp.addItem(withTitle: outString_1)
                    if (_stillMovieDivideSetting == UInt32(array[Int(i)]))
                    {
                        // Select item of combo box
                        _stillMovieDivideSettingPopUp.selectItem(withTitle: outString_1)
                        _stillMovieDivideSetting = array[Int(i)]
                        _stillMovieDivideSettingPrev = _stillMovieDivideSetting
                    }
                }
            }
        }
        
        //CardExtension setting
        EdsGetPropertyData(_model.getCameraObject(), EdsPropertyID(kEdsPropID_CardExtension), 0, UInt32(MemoryLayout<UInt32>.size), &_cardExtension)
        EdsGetPropertyDesc(_model.getCameraObject(), EdsPropertyID(kEdsPropID_CardExtension), &_desc2)
        _cardExtensionPopUp.removeAllItems()
            
            if (_desc2.numElements != 0)
            {
                let array = getPropDesc2(_desc2)
                for i in 0 ..< _desc2.numElements {
                    var outString_2: String = ""
                    let value: Int = Int(array[Int(i)])
                    if (value >= 0)
                    {
                        outString_2 = PROPERTYLIST_2[value] as! String
                    }
                    if (outString_2 != "" && outString_2 != "unknown")
                    {
                        // Create list of combo box
                        _cardExtensionPopUp.addItem(withTitle: outString_2)
                        if (_cardExtension == UInt32(array[Int(i)]))
                        {
                            // Select item of combo box
                            _cardExtensionPopUp.selectItem(withTitle: outString_2)
                            _cardExtension = array[Int(i)]
                            _cardExtensionPrev = _cardExtension
                        }
                    }
                }
            
            }
        
        //stillCurrentMediaSetting
       EdsGetPropertyData(_model.getCameraObject(), EdsPropertyID(kEdsPropID_StillCurrentMedia), 0, UInt32(MemoryLayout<UInt32>.size), &_stillCurrentMedia)
        EdsGetPropertyDesc(_model.getCameraObject(), EdsPropertyID(kEdsPropID_StillCurrentMedia), &_desc3)
        _stillCurrentMediaPopUp.removeAllItems()
            
            if (_desc3.numElements != 0)
            {
                let array = getPropDesc2(_desc3)
                for i in 0 ..< _desc3.numElements {
                    var outString_3: String = ""
                    let value: Int = Int(array[Int(i)])
                    if (value >= 0)
                    {
                        outString_3 = PROPERTYLIST_3[value] as! String
                    }
                    if (outString_3 != "" && outString_3 != "unknown")
                    {
                        // Create list of combo box
                        _stillCurrentMediaPopUp.addItem(withTitle: outString_3)
                        if (_stillCurrentMedia == UInt32(array[Int(i)]))
                        {
                            // Select item of combo box
                            _stillCurrentMediaPopUp.selectItem(withTitle: outString_3)
                            _stillCurrentMedia = array[Int(i)]
                            _stillCurrentMediaPrev = _stillCurrentMedia
                        }
                    }
                }
            }
        
        //MovieCardExtensionSetting
       EdsGetPropertyData(_model.getCameraObject(), EdsPropertyID(kEdsPropID_MovieCardExtension), 0, UInt32(MemoryLayout<UInt32>.size), &_movieCardExtension)
        EdsGetPropertyDesc(_model.getCameraObject(), EdsPropertyID(kEdsPropID_MovieCardExtension), &_desc4)
        _movieCardExtensionPopUp.removeAllItems()
            
            if (_desc4.numElements != 0)
            {
                let array = getPropDesc2(_desc4)
                for i in 0 ..< _desc4.numElements {
                    var outString_4: String = ""
                    let value: Int = Int(array[Int(i)])
                    if (value >= 0)
                    {
                        outString_4 = PROPERTYLIST_4[value] as! String
                    }
                    if (outString_4 != "" && outString_4 != "unknown")
                    {
                        // Create list of combo box
                        _movieCardExtensionPopUp.addItem(withTitle: outString_4)
                        if (_movieCardExtension == UInt32(array[Int(i)]))
                        {
                            // Select item of combo box
                            _movieCardExtensionPopUp.selectItem(withTitle: outString_4)
                            _movieCardExtension = array[Int(i)]
                            _movieCardExtensionPrev = _movieCardExtension
                        }
                    }
                }
            
            }
        
        //MovieCurrentMediaSetting
        EdsGetPropertyData(_model.getCameraObject(), EdsPropertyID(kEdsPropID_MovieCurrentMedia), 0, UInt32(MemoryLayout<UInt32>.size), &_movieCurrentMedia)
        EdsGetPropertyDesc(_model.getCameraObject(), EdsPropertyID(kEdsPropID_MovieCurrentMedia), &_desc5)
        _movieCurrentMediaPopUp.removeAllItems()
            
            if (_desc5.numElements != 0)
            {
                let array = getPropDesc2(_desc5)
                for i in 0 ..< _desc5.numElements {
                    var outString_5: String = ""
                    let value: Int = Int(array[Int(i)])
                    if (value >= 0)
                    {
                        outString_5 = PROPERTYLIST_3[value] as! String
                    }
                    if (outString_5 != "" && outString_5 != "unknown")
                    {
                        // Create list of combo box
                        _movieCurrentMediaPopUp.addItem(withTitle: outString_5)
                        if (_movieCurrentMedia == UInt32(array[Int(i)]))
                        {
                            // Select item of combo box
                            _movieCurrentMediaPopUp.selectItem(withTitle: outString_5)
                            _movieCurrentMedia = array[Int(i)]
                            _movieCurrentMediaPrev = _movieCurrentMedia
                        }
                    }
                }
            
            }

            
            
    }
        
        
    
    private func getPropDesc2(_ propertyDesc: EdsPropertyDesc) -> Array<EdsInt32> {
        let test = propertyDesc.propDesc
        // C Tuple -> Array<EdsInt32>
        let arrInt32: Array<EdsInt32> = Mirror(reflecting: test).children.map { $0.value as! EdsInt32 }
        return arrInt32
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func windowWillClose(_ notification: Notification) {
        NotificationCenter.default.removeObserver(self)
        NSApp.stopModal()
        NSApp.abortModal()
    }
}
