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

class CameraSetting : NSWindowController, NSWindowDelegate, NSTableViewDataSource{
    
    @IBOutlet weak var _tableView : NSTableView?
    @IBOutlet weak var _yearField: NSTextField!
    @IBOutlet weak var _monthField: NSTextField!
    @IBOutlet weak var _dayField: NSTextField!
    @IBOutlet weak var _hourField: NSTextField!
    @IBOutlet weak var _minuteField: NSTextField!
    @IBOutlet weak var _secondField: NSTextField!
    @IBOutlet weak var _changeOwnerNameField: NSTextField!
    @IBOutlet weak var _changeOwnerNameButton: NSButton!
    @IBOutlet weak var _memoryCardFormatButton: NSButton!
    @IBOutlet weak var _memoryCardFormatButton2: NSButton!
    @IBOutlet weak var _selectPropertyPopUp: NSPopUpButton!
    @IBOutlet weak var _sendCommandResult: NSTextFieldCell!
    @IBOutlet weak var _changeUTCTimeButton: NSButton!
    @IBOutlet weak var _selectAutoPowerOffPopUp: NSPopUpButton!
    
    @IBOutlet weak var _selectModeDialDisablePopUp: NSPopUpButton!
    @IBOutlet weak var _selectSensorCleaningPopUp: NSPopUpButton!
    @IBOutlet weak var _sendCommandButton: NSButton!
    
    @IBOutlet weak var _recordFuncCardSettingButton: NSButton!
    @IBAction func _recordFuncCardSettingButton(_ sender: Any) {
    }
    
    fileprivate let _keyString = "Key"
    fileprivate let _valueString = "Value"
    fileprivate let _productNameString  = "Product Name"
    fileprivate let _serialNumberString = "Serial Number"
    fileprivate let _firmwareVersionString = "Firmware Version"
    fileprivate let _ownerNameString = "Owner Name"
    fileprivate let _artistString = "Artist"
    fileprivate let _copyrightString = "Copyright"
    fileprivate let _shutterReleaseCountString = "Shutter Release Count"
    fileprivate let _onString = "On"
    fileprivate let _offString = "Off"
    
    fileprivate var _controller : CameraController!
    fileprivate var _model : CameraModel!
    fileprivate var _dataArray:[NSMutableDictionary] = []
    fileprivate var _descArray:[Int32] = []

    @IBAction func PopUp(_ sender: PropertyPopUp) {sender.fireEvent()}
    
    var AUTOPOWEROFFLIST: NSDictionary = NSMutableDictionary()

    init(controller: CameraController)
    {
        super.init(window: nil)
        
        Bundle.main.loadNibNamed("CameraSetting", owner: self, topLevelObjects: nil)
        self._controller = controller
        _model = _controller.getCameraModel()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.update), name: Notification.Name(rawValue: "MY_VIEW_UPDATE"), object: nil)
        
        let camera: EdsCameraRef? = _controller.getCameraModel().getCameraObject()
        
        let tcKey: NSTableColumn = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(rawValue: _keyString))
        tcKey.width = ((_tableView?.bounds.width)! * 1/3)
        tcKey.title = _keyString
        tcKey.isEditable = false
        _tableView!.addTableColumn(tcKey)
        
        let tcValue: NSTableColumn = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(rawValue: _valueString))
        tcValue.width = ((_tableView?.bounds.width)! * 2/3)
        tcValue.title = _valueString
        tcValue.isEditable = false
        _tableView!.addTableColumn(tcValue)
        
        var productName : [EdsChar] = Array<EdsChar>(repeating: 0, count: 256)
        var serialNumber : [EdsChar] = Array<EdsChar>(repeating: 0, count: 256)
        var firmwareVersion : [EdsChar] = Array<EdsChar>(repeating: 0, count: 256)
        var ownerName : [EdsChar] = Array<EdsChar>(repeating: 0, count: 256)
        var artist : [EdsChar] = Array<EdsChar>(repeating: 0, count: 256)
        var copyright : [EdsChar] = Array<EdsChar>(repeating: 0, count: 256)

        EdsGetPropertyData(camera, EdsPropertyID(kEdsPropID_ProductName), 0, EdsUInt32(MemoryLayout<UInt8>.size*Int(EDS_MAX_NAME)), &productName)
        let stProductName = String(cString: productName,encoding: String.Encoding.ascii)
        
        EdsGetPropertyData(camera, EdsPropertyID(kEdsPropID_BodyIDEx), 0, EdsUInt32(MemoryLayout<EdsChar>.size * Int(EDS_MAX_NAME)), &serialNumber)
        let stSerialNumber = String(cString: serialNumber,encoding: String.Encoding.ascii )
        
        EdsGetPropertyData(camera, EdsPropertyID(kEdsPropID_FirmwareVersion), 0, EdsUInt32(MemoryLayout<EdsChar>.size * Int(EDS_MAX_NAME)), &firmwareVersion)
        let stFirmwareVersion = String(cString: firmwareVersion,encoding: String.Encoding.ascii )
        
        EdsGetPropertyData(camera, EdsPropertyID(kEdsPropID_OwnerName), 0, EdsUInt32(MemoryLayout<EdsChar>.size * Int(EDS_MAX_NAME)), &ownerName)
        let stOwnerName : String = String(cString: ownerName,encoding: String.Encoding.ascii)!

        EdsGetPropertyData(camera, EdsPropertyID(kEdsPropID_Artist), 0, EdsUInt32(MemoryLayout<EdsChar>.size * Int(EDS_MAX_NAME)), &artist)
        let stArtist : String = String(cString: artist,encoding: String.Encoding.ascii)!
        
        EdsGetPropertyData(camera, EdsPropertyID(kEdsPropID_Copyright), 0, EdsUInt32(MemoryLayout<EdsChar>.size * Int(EDS_MAX_NAME)), &copyright)
        let stCopyright : String = String(cString: copyright,encoding: String.Encoding.ascii)!
        
        _dataArray = [[_keyString:_productNameString,_valueString:stProductName!],
                      [_keyString:_serialNumberString,_valueString:stSerialNumber!],
                      [_keyString:_firmwareVersionString,_valueString:stFirmwareVersion!],
                      [_keyString:_ownerNameString,_valueString:stOwnerName],
                      [_keyString:_artistString,_valueString:stArtist],
                      [_keyString:_copyrightString,_valueString:stCopyright]]
        
        _tableView!.reloadData()
        
        self._changeOwnerNameField.stringValue = stOwnerName
        
        let stProperty = ["Change Owner Name", "Change Artist", "Change Copyright"]
        _selectPropertyPopUp.removeAllItems()
        stProperty.forEach {
            _selectPropertyPopUp.addItem(withTitle: $0)
        }

        // ModeDialDisablePopUp
        _selectModeDialDisablePopUp.removeAllItems()
        _selectModeDialDisablePopUp.addItem(withTitle: "0x00:Off")
        _selectModeDialDisablePopUp.addItem(withTitle: "0x01:On")
        
        // AutoPowerOffPopUp
        _selectAutoPowerOffPopUp.removeAllItems()
        let autoPowerOffDesc = _model.getPropertyDesc(EdsUInt32(kEdsPropID_AutoPowerOffSetting))
        _descArray = arrayFromTuple(tuple: autoPowerOffDesc.propDesc) as [Int32]
        for i in 0..<autoPowerOffDesc.numElements
        {
            var value: String
            let key = _descArray[Int(i)]
            // for off
            if (key == 0)
            {
                value = "Off"
            }
            // for shutdown
            else if (key == -1) // key == 0xffffffff
            {
                value = "Shutdown"
            }
            // for seconds
            else if (key < 60)
            {
                value = key.description + "\""
            }
            // for minutes
            else
            {
                value = (key / 60).description + "'"
            }
            AUTOPOWEROFFLIST.setValue(value, forKey: String(key))

            let string: String = AUTOPOWEROFFLIST[String(key)] as! String
            var index = _selectAutoPowerOffPopUp.indexOfItem(withTitle: string)
            if (index == -1){
                _selectAutoPowerOffPopUp.addItem(withTitle: string as String)
                index = _selectAutoPowerOffPopUp.indexOfItem(withTitle: string as String)
            }

            if (UInt32(_model.getPropertyUInt32(EdsUInt32(kEdsPropID_AutoPowerOffSetting))) == key)
            {
                _selectAutoPowerOffPopUp.selectItem(at: index)
            }
        }
        if (_selectAutoPowerOffPopUp.numberOfItems == 0)
        {
            _selectAutoPowerOffPopUp.isEnabled = false
        }

        self.getVolumeInfo()
        
    }
    
    func updateTimeDiffPopup (_ timeDiff: Int16)
    {
    }
    
    @IBAction func sendCommandButtonClick(_ sender: NSButton) {
        
        let camera: EdsCameraRef? = _controller.getCameraModel().getCameraObject()
        let param: EdsInt32
        
        _sendCommandResult.stringValue = "----"
        _sendCommandResult.stringValue = "Running"
        
        param = Int32(_selectSensorCleaningPopUp.indexOfSelectedItem)
        
        var error: EdsError = EdsUInt32(EDS_ERR_OK)
        
        error = EdsSendCommand(camera, EdsUInt32(kEdsCameraCommand_RequestSensorCleaning), param)
        
        
        if(error == EdsError(EDS_ERR_OK)){
            _sendCommandResult.stringValue = "SUCCESS!!!"
        } else {
            _sendCommandResult.stringValue = String(format: "Err!!! ->0x%08x<-", error)
        }
    }
    
    
    @IBAction func changeOwnerNameButtonClick(_ sender: NSButton)
    {
        let camera: EdsCameraRef? = _controller.getCameraModel().getCameraObject()
        
        var asciiCodeSet = CharacterSet()
        asciiCodeSet.formUnion(CharacterSet.alphanumerics)
        asciiCodeSet.formUnion(CharacterSet.punctuationCharacters)
        asciiCodeSet.insert("+")
        asciiCodeSet.insert("=")
        asciiCodeSet.insert("$")
        asciiCodeSet.insert("<")
        asciiCodeSet.insert(">")
        asciiCodeSet.insert(" ")
        
        let checkSet = CharacterSet (charactersIn: self._changeOwnerNameField.stringValue)
        
        if !asciiCodeSet.isSuperset(of: checkSet)
        {
            return
        }
        // Confirtm whether a multibyte character is not included.
        if (self._changeOwnerNameField.stringValue.count != self._changeOwnerNameField.stringValue.lengthOfBytes(using: String.Encoding.ascii))
        {
            return;
        }

        let propertyTable = [kEdsPropID_OwnerName, kEdsPropID_Artist, kEdsPropID_Copyright]
        
        var currentOwnerName : [EdsChar] = self._changeOwnerNameField.stringValue.cString(using: String.Encoding.ascii)!
        EdsSetPropertyData(camera, EdsPropertyID(propertyTable[_selectPropertyPopUp.indexOfSelectedItem]), 0, EdsUInt32(MemoryLayout<EdsChar>.size * currentOwnerName.count), &currentOwnerName)
        
        var keyString = ""
        switch(_selectPropertyPopUp.indexOfSelectedItem)
        {
        case 0:
            keyString = _ownerNameString
            
        case 1:
            keyString = _artistString
            
        case 2:
            keyString = _copyrightString
            
        default: break
        }
        _dataArray[3 + _selectPropertyPopUp.indexOfSelectedItem] = [_keyString:keyString, _valueString:self._changeOwnerNameField.stringValue]
        _tableView!.reloadData()
    }
   
    @IBAction func changeUTCTimeButtonClick(_ sender: NSButton) {
        let utcTimeCtrl = DateTimeZoneSetting(controller: _controller)
        let anApplication = NSApplication.shared
        anApplication.runModal(for: utcTimeCtrl.window!)
    }
    
    
    @IBAction func recordFuncCardSettingButtonClick(_ sender: NSButton) {
        let recFuncCardCtrl = RecordFuncCardSetting(controller: _controller)
        let anApplication = NSApplication.shared
        anApplication.runModal(for: recFuncCardCtrl.window!)
    }
    
    @IBAction func memoryCardFormatButtonClick(_ sender: NSButton)
    {
        if !viewAlert("Format the memory Card?")
        {
            return;
        }
        _model.setSelectedVolume(0)
    _controller.actionPerformed(ActionEvent(command: .format_VOLUME, object: 0 as AnyObject))
    }

    @IBAction func memoryCardFormatButton2Click(_ sender: NSButton) {
        if !viewAlert("Format the memory Card?")
        {
            return;
        }
        _model.setSelectedVolume(1)
    _controller.actionPerformed(ActionEvent(command: .format_VOLUME, object: 0 as AnyObject))
    }
    
    @IBAction func selectPropertyPopUpButton(_ sender: NSPopUpButton) {
        let data = _dataArray[3 + _selectPropertyPopUp.indexOfSelectedItem] as NSMutableDictionary
        self._changeOwnerNameField.stringValue = (data["Value"] as! String as AnyObject) as! String
    }
    
    @IBAction func selectAutoPowerOffPopUpButton(_ sender: NSPopUpButton) {
        var data = _descArray[_selectAutoPowerOffPopUp.indexOfSelectedItem]
        EdsSetPropertyData(_controller.getCameraModel().getCameraObject(), EdsUInt32(kEdsPropID_AutoPowerOffSetting), 0, EdsUInt32(MemoryLayout<EdsUInt32>.size), &data)
    }
    
    
    @IBAction func _selectModeDialDisablePopUpButton(_ sender: NSPopUpButton) {
        let camera: EdsCameraRef? = _controller.getCameraModel().getCameraObject()
        let param: EdsInt32
        param = Int32(_selectModeDialDisablePopUp.indexOfSelectedItem)
        
        EdsSendCommand(camera, EdsUInt32(kEdsCameraCommand_SetModeDialDisable), param)
        
    }
    
    func viewAlert(_ displayText:String)->Bool
    {
        let alert = NSAlert()
        alert.messageText = displayText
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "Cancel")
        alert.alertStyle = NSAlert.Style.critical
        return alert.runModal() == NSApplication.ModalResponse.alertFirstButtonReturn
    }
    
    
    func numberOfRows(in tableview: NSTableView) -> Int
    {
        return _dataArray.count
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any?
    {
        let object = _dataArray[row] as NSMutableDictionary
        
        var str = ""
        str = tableColumn!.identifier.rawValue
        
        if str == _keyString
        {
            return object[str] as! String as AnyObject
        }
        else if str == _valueString
        {
            return object[str] as! String as AnyObject
        }
        
        return nil
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func windowWillClose(_ notification: Notification) {
        NotificationCenter.default.removeObserver(self)
        NSApp.stopModal()
        NSApp.abortModal()
    }
    
    func getPropertyChangedMessage(_ arg: AnyObject)
    {
        let argNumber = arg as? NSNumber
        let propertyID = argNumber!.int32Value
        var error: EdsError = EdsUInt32(EDS_ERR_OK)
        let camera: EdsCameraRef? = _controller.getCameraModel().getCameraObject()
        
        switch(propertyID)
        {
        case Int32(kEdsPropID_OwnerName):
            
            var ownerName : [EdsChar] = Array<EdsChar>(repeating: 0, count: 256)
            
            error = EdsGetPropertyData(camera, EdsPropertyID(kEdsPropID_OwnerName), 0, EdsUInt32(MemoryLayout<EdsChar>.size * Int(EDS_MAX_NAME)), &ownerName)
            
            if error != EdsUInt32(EDS_ERR_OK)
            {
                return
            }
            
            let stOwnerName : String = String(cString: ownerName,encoding: String.Encoding.ascii )!
            
            _dataArray[3] = [_keyString:_ownerNameString,_valueString:stOwnerName]
            
            _tableView!.reloadData()
        
        case Int32(kEdsPropID_Artist):
            
            var artist : [EdsChar] = Array<EdsChar>(repeating: 0, count: 256)
            
            error = EdsGetPropertyData(camera, EdsPropertyID(kEdsPropID_Artist), 0, EdsUInt32(MemoryLayout<EdsChar>.size * Int(EDS_MAX_NAME)), &artist)
            
            if error != EdsUInt32(EDS_ERR_OK)
            {
                return
            }
            
            let stArtist : String = String(cString: artist,encoding: String.Encoding.ascii )!
            
            _dataArray[4] = [_keyString:_artistString,_valueString:stArtist]
            
            _tableView!.reloadData()
            
        case Int32(kEdsPropID_Copyright):
            
            var copyright : [EdsChar] = Array<EdsChar>(repeating: 0, count: 256)
            
            error = EdsGetPropertyData(camera, EdsPropertyID(kEdsPropID_Copyright), 0, EdsUInt32(MemoryLayout<EdsChar>.size * Int(EDS_MAX_NAME)), &copyright)
            
            if error != EdsUInt32(EDS_ERR_OK)
            {
                return
            }
            
            let stCopyright : String = String(cString: copyright,encoding: String.Encoding.ascii )!
            
            _dataArray[5] = [_keyString:_copyrightString,_valueString:stCopyright]
            
            _tableView!.reloadData()
        
        default: break
        }
    }
    
    func getPropertyDescChangedMessage(_ arg: AnyObject){
        
        let argNumber = arg as? NSNumber
        let propertyID = argNumber!.int32Value
        switch(propertyID){
        default: break
        }
    }
    
    @objc func update(_ notification: Notification?)
    {
        let event = notification?.object as! CameraEvent
        let arg = event.getArg()
        
        switch(event.getEvent())
        {
        case .property_CHANGED:         self.getPropertyChangedMessage(arg)
        case .propertydesc_CHANGED:     self.getPropertyDescChangedMessage(arg)
        default:
            break;
        }
    }
    
    func getVolumeInfo(){
        var volume : EdsVolumeRef? = nil
        var volumeCount = 0 as EdsUInt32
        var volumeInfo = EdsVolumeInfo()
        
        EdsGetChildCount(_controller.getCameraModel().getCameraObject(), &volumeCount)
        if(volumeCount > 0){
            EdsGetChildAtIndex(_controller.getCameraModel().getCameraObject(), 0, &volume)
            EdsGetVolumeInfo(volume, &volumeInfo)
            if(volumeInfo.storageType != kEdsStorageType_Non.rawValue){
                _memoryCardFormatButton.isEnabled = true
                let stVolumeLabel = withUnsafePointer(to: volumeInfo.szVolumeLabel) {
                    $0.withMemoryRebound(to: UInt8.self, capacity: MemoryLayout.size(ofValue: volumeInfo.szVolumeLabel)) {
                        String(cString: $0)
                    }
                }
                _memoryCardFormatButton.title = "Memory Card 1 (" + stVolumeLabel + ")"
            }
            if(volumeCount > 1){
                EdsGetChildAtIndex(_controller.getCameraModel().getCameraObject(), 1, &volume)
                EdsGetVolumeInfo(volume, &volumeInfo)
                if(volumeInfo.storageType != kEdsStorageType_Non.rawValue){
                    _memoryCardFormatButton2.isEnabled = true
                    let stVolumeLabel = withUnsafePointer(to: volumeInfo.szVolumeLabel) {
                        $0.withMemoryRebound(to: UInt8.self, capacity: MemoryLayout.size(ofValue: volumeInfo.szVolumeLabel)) {
                            String(cString: $0)
                        }
                    }
                    _memoryCardFormatButton2.title = "Memory Card 2 (" + stVolumeLabel + ")"
                }
            }
        }
    }
}
