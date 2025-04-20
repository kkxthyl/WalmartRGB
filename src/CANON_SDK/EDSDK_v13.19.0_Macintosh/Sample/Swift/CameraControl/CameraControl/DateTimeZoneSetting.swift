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

class DateTimeZoneSetting : NSWindowController, NSWindowDelegate, NSTextFieldDelegate{

    @IBOutlet weak var _dateTime: NSTextField!
    @IBOutlet weak var _zoneSetting: NSPopUpButton!
    @IBOutlet weak var _summerTime: NSButton!
    @IBOutlet weak var _ok: NSButton!
    @IBOutlet weak var _cancel: NSButton!

    @IBAction func _dateTimeText(_ sender: NSTextField) {
        let utcTime: String = _dateTime.stringValue
        if (_localTimePrev != utcTime)
        {
            var date: Date = Date()
            if (!TryParse(time: utcTime, date: &date))
            {
                _dateTime.stringValue = _localTimePrev
            }
            _localTimePrev = _dateTime.stringValue
        }
    }

    @IBAction func _zoneSettingPopUp(_ sender: NSPopUpButton) {
        let array = getPropDesc2(_desc)
        let timeZone: Int32 = array[_zoneSetting.indexOfSelectedItem]
        if (_timeZonePrev != timeZone)
        {
            var date: Date = Date()
            if (TryParse(time: _dateTime.stringValue, date: &date))
            {
                // Old Zone -> UTC
                var timeDiff = extractInt16(value: _timeZonePrev)
                var timeInterval: TimeInterval = Double(timeDiff) * 60 * -1
                date = Date(timeInterval: timeInterval, since: date)

                // UTC -> New Zone
                timeDiff = extractInt16(value: timeZone)
                timeInterval = Double(timeDiff) * 60
                date = Date(timeInterval: timeInterval, since: date)

                _dateTime.stringValue = EdsTime2StrTime(edsTime: Date2EdsTime(date: date))
            }
        }
        _timeZonePrev = timeZone
    }
    
    @IBAction func _summerTimeButton(_ sender: NSButton) {
        if (_summerTimeSettingPrev != _summerTime.state)
        {
            let utcTime: String = _dateTime.stringValue
            var date: Date = Date()
            if (TryParse(time: utcTime, date: &date))
            {
                var timeInterval: TimeInterval = 60 * 60
                if (_summerTime.state == .off)
                {
                    timeInterval = 60 * 60 * -1
                }
                date = Date(timeInterval: timeInterval, since: date)

                _dateTime.stringValue = EdsTime2StrTime(edsTime: Date2EdsTime(date: date))
            }
        }
        _summerTimeSettingPrev = _summerTime.state
    }
    
    @IBAction func _okButton(_ sender: NSButton) {
        // Zone Setting
        let array = getPropDesc2(_desc)
        var timeZone: Int32 = array[_zoneSetting.indexOfSelectedItem]
        if (_timeZone != timeZone)
        {
            EdsSetPropertyData(_model.getCameraObject(), EdsPropertyID(kEdsPropID_TimeZone), 0, UInt32(MemoryLayout<UInt32>.size), &timeZone)
        }
        _timeZone = timeZone
        
        // Date / Time : (ex : 19/09/12 09:11)
        let localTime: String = _dateTime.stringValue
        if (_localTime != localTime)
        {
            var date: Date = Date()
            if (TryParse(time: localTime, date: &date))
            {
                // Time difference consideration
                let timeDiff = extractInt16(value: _timeZone)
                var timeInterval: TimeInterval = Double(timeDiff) * 60
                if (_summerTime.state == NSButton.StateValue.on)
                {
                    timeInterval += 60 * 60
                }
                timeInterval *= -1
                date = Date(timeInterval: timeInterval, since: date)
                var edsDateTime: EdsTime = Date2EdsTime(date: date)
                EdsSetPropertyData(_model.getCameraObject(), EdsPropertyID(kEdsPropID_UTCTime), 0, UInt32(MemoryLayout<EdsTime>.size), &edsDateTime)
            }
            else
            {
                return
            }
        }
        
        // Daylight Saving Time
        if (_summerTimeSetting != _summerTime.state)
        {
            var summerTimeSetting: EdsUInt32 = 0
            if (_summerTime.state == NSButton.StateValue.on)
            {
                summerTimeSetting = 1
            }
            EdsSetPropertyData(_model.getCameraObject(), EdsPropertyID(kEdsPropID_SummerTimeSetting), 0, UInt32(MemoryLayout<EdsUInt32>.size), &summerTimeSetting)
        }
        self.close()
    }
    
    @IBAction func _cancelButton(_ sender: NSButton) {
        self.close()
    }

    fileprivate var _controller : CameraController!
    fileprivate var _model : CameraModel!
    fileprivate var _localTime: String = ""
    fileprivate var _localTimePrev: String = ""
    fileprivate var _timeZone: Int32 = 0
    fileprivate var _timeZonePrev: Int32 = 0
    fileprivate var _summerTimeSetting: NSButton.StateValue = .off
    fileprivate var _summerTimeSettingPrev: NSButton.StateValue = .off
    fileprivate var _desc: EdsPropertyDesc = EdsPropertyDesc()

    let PROPERTYLIST: NSDictionary = [
        0x00000000:"None",
        0x00000001:"Chatham Islands",
        0x00000002:"Wellington",
        0x00000003:"Solomon Islands",
        0x00000004:"Sydney",
        0x00000005:"Adelaide",
        0x00000006:"Tokyo",
        0x00000007:"Hong Kong",
        0x00000008:"Bangkok",
        0x00000009:"Yangon",
        0x0000000A:"Dhaka",
        0x0000000B:"Kathmandu",
        0x0000000C:"Delhi",
        0x0000000D:"Karachi",
        0x0000000E:"Kabul",
        0x0000000F:"Dubai",
        0x00000010:"Tehran",
        0x00000011:"Moscow",
        0x00000012:"Cairo",
        0x00000013:"Paris",
        0x00000014:"London",
        0x00000015:"Azores",
        0x00000016:"Fernando",
        0x00000017:"Sao Paulo",
        0x00000018:"Newfoundland",
        0x00000019:"Santiago",
        0x0000001A:"Caracas",
        0x0000001B:"New York",
        0x0000001C:"Chicago",
        0x0000001D:"Denver",
        0x0000001E:"Los Angeles",
        0x0000001F:"Anchorage",
        0x00000020:"Honolulu",
        0x00000021:"Samoa",
        0x00000022:"Riyadh",
        0x00000023:"Manaus",
        0x00000100:"UTC",
        0xffffffff:"unknown"]
    
    init(controller: CameraController) {
        super.init(window: nil)

        Bundle.main.loadNibNamed("DateTimeZoneSetting", owner: self, topLevelObjects: nil)
        _controller = controller
        _model = _controller.getCameraModel()
        
        // Date / Time
        var utcTime: EdsTime = EdsTime()
        EdsGetPropertyData(_model.getCameraObject(), EdsPropertyID(kEdsPropID_UTCTime), 0, UInt32(MemoryLayout<EdsTime>.size), &utcTime)

        // Zone Setting
        EdsGetPropertyData(_model.getCameraObject(), EdsPropertyID(kEdsPropID_TimeZone), 0, UInt32(MemoryLayout<UInt32>.size), &_timeZone)
        EdsGetPropertyDesc(_model.getCameraObject(), EdsPropertyID(kEdsPropID_TimeZone), &_desc)
        _zoneSetting.removeAllItems()
        if (_desc.numElements != 0)
        {
            let array = getPropDesc2(_desc)
            for i in 0 ..< _desc.numElements {
                var outString: String = ""
                let value: Int = Int(array[Int(i)] >> 16)
                if (value >= 0)
                {
                    outString = PROPERTYLIST[value] as! String
                }
                if (outString != "" && outString != "unknown")
                {
                    // Create list of combo box
                    _zoneSetting.addItem(withTitle: outString)
                    if (_timeZone == UInt32(array[Int(i)]))
                    {
                        // Select item of combo box
                        _zoneSetting.selectItem(withTitle: outString)
                        _timeZone = array[Int(i)]
                        _timeZonePrev = _timeZone
                    }
                }
            }
        }

        // Daylight Saving Time
        var summerTimeSetting: UInt32 = 0
        EdsGetPropertyData(_model.getCameraObject(), EdsPropertyID(kEdsPropID_SummerTimeSetting), 0, UInt32(MemoryLayout<UInt32>.size), &summerTimeSetting)
        if (summerTimeSetting == 0x01)
        {
            _summerTime.state = NSButton.StateValue.on
        }
        _summerTimeSetting = _summerTime.state
        _summerTimeSettingPrev = _summerTimeSetting

        // Time difference consideration
        var date = EdsTime2Date(edsTime: utcTime)
        let timeDiff = extractInt16(value: _timeZone)
        var timeInterval: TimeInterval = Double(timeDiff) * 60

        if (_summerTime.state == NSButton.StateValue.on)
        {
            timeInterval += 60 * 60
        }
        date = Date(timeInterval: timeInterval, since: date)
        utcTime = Date2EdsTime(date: date)

        _localTime = EdsTime2StrTime(edsTime: utcTime)
        _localTimePrev = _localTime
        _dateTime.stringValue = _localTime
    }

    private func EdsTime2Date(edsTime: EdsTime) -> Date {
        let calendar = Calendar.current
        var dateComponents = DateComponents()
        dateComponents.year = Int(edsTime.year)
        dateComponents.month = Int(edsTime.month)
        dateComponents.day = Int(edsTime.day)
        dateComponents.hour = Int(edsTime.hour)
        dateComponents.minute = Int(edsTime.minute)
        dateComponents.second = Int(edsTime.second)
        let date = calendar.date(from: dateComponents)
        return date!
    }

    private func Date2EdsTime(date: Date) -> EdsTime {
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        var edsTime = EdsTime()
        edsTime.year = EdsUInt32(dateComponents.year!)
        edsTime.month = EdsUInt32(dateComponents.month!)
        edsTime.day = EdsUInt32(dateComponents.day!)
        edsTime.hour = EdsUInt32(dateComponents.hour!)
        edsTime.minute = EdsUInt32(dateComponents.minute!)
        edsTime.second = EdsUInt32(dateComponents.second!)
        return edsTime
    }

    private func TryParse(time: String, date: inout Date) -> Bool {
        // String -> Date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm"
        // format check
        if let workDate = dateFormatter.date(from: time)
        {
            // yyyy/MM/dd HH:mm
            let pattern = "^[0-9]{4}/[0-9]{2}/[0-9]{2}.[0-9]{2}:[0-9]{2}$"
            let regex = try! NSRegularExpression(pattern: pattern, options: [])
            let matches = regex.matches(in: time, options: [], range: NSMakeRange(0, time.count))
            if (matches.count == 1)
            {
                // yyyy -> 2019 - 2050
                if let year = Int(time.prefix(4))
                {
                    if (year >= 2019 && year <= 2050)
                    {
                        date = workDate
                        return true
                    }
                    else
                    {
                        let alert = NSAlert()
                        alert.addButton(withTitle: "OK")
                        alert.messageText = "Year must be between 2019 and 2050"
                        alert.runModal()
                        _dateTime.stringValue = _localTimePrev
                        return false
                    }
                }
            }
        }

        let alert = NSAlert()
        alert.addButton(withTitle: "OK")
        alert.messageText = "Enter in the \"yyyy/MM/dd HH:mm\" format."
        alert.runModal()
        _dateTime.stringValue = _localTimePrev
        return false
    }

    private func EdsTime2StrTime(edsTime: EdsTime) -> String {
        let strTime = String(format: "%04d", edsTime.year) + "/" +
                      String(format: "%02d", edsTime.month) + "/" +
                      String(format: "%02d", edsTime.day) + " " +
                      String(format: "%02d", edsTime.hour) + ":" +
                      String(format: "%02d", edsTime.minute)
        return strTime
    }

    private func getPropDesc2(_ propertyDesc: EdsPropertyDesc) -> Array<EdsInt32> {
        let test = propertyDesc.propDesc
        // C Tuple -> Array<EdsInt32>
        let arrInt32: Array<EdsInt32> = Mirror(reflecting: test).children.map { $0.value as! EdsInt32 }
        return arrInt32
    }

    private func extractInt16(value: Int32) -> Int32 {
        var valueInt32 = value & 0x0000ffff
        var valueInt16: Int16 = 0
        // Int32 -> Int16
        memcpy(&valueInt16, &valueInt32, 2)
        return Int32(valueInt16)
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
