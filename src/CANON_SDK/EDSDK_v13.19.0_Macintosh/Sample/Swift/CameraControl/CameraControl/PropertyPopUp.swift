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

class PropertyPopUp: NSPopUpButton, ActionSource {
    
    fileprivate var _listener: CameraController!
    fileprivate var _propertyDesc: EdsPropertyDesc = EdsPropertyDesc()
    fileprivate var _command: ActionEvent.Command = ActionEvent.Command.none

    func setCommand(_ command: ActionEvent.Command){
        _command = command
    }
    
    func addActionListener(_ listener: CameraController){
        _listener = listener
    }
    
    func removeActionListener() {
        _listener = nil
    }
    
    func setPropertyDesc(_ desc: EdsPropertyDesc){
        _propertyDesc = desc
    }
    
    func fireEvent() {
        
        let data = self.GetPropertyFromPropertyList(_propertyDesc)
        let event = ActionEvent(command: _command, object: NSInteger(data) as AnyObject)
        DispatchQueue.main.async{() in
            self._listener.actionPerformed(event)
        }
        
    }
    
    func updateProperty(_ value: EdsUInt32, PROPERTYLIST: NSDictionary) {
        
        if (PROPERTYLIST[Int(value)] != nil)
        {
        
            let string: String = PROPERTYLIST[Int(value)] as! String
        
            var index = self.indexOfItem(withTitle: string)
        
            if (index == -1){
                
                self.addItem(withTitle: string as String)
                index = self.indexOfItem(withTitle: string as String)
            
            }
            
            self.selectItem(at: index)
            
        }
        
    }
    
    func updatePropertyDesc(_ desc: EdsPropertyDesc, PROPERTYLIST: NSDictionary) {
        
        var selectedString: String = ""
      
        if(self.numberOfItems) > 0{
            if nil != self.titleOfSelectedItem
            {
                selectedString = self.titleOfSelectedItem!
            }
            else
            {
                return
            }
        }
        
        self.removeAllItems()
        
        if(desc.numElements == 0 || desc.numElements == 1){
            
            self.addItem(withTitle: selectedString as String)
            self.isEnabled = false
            
        } else {
            
            let array = getPropDesc(desc)
            var tblValString: String = ""
            for count in 0 ..< desc.numElements {
                
                tblValString = PROPERTYLIST[Int(array[Int(count)])] as? String ?? ""
                if (tblValString != ""){
                    self.addItem(withTitle: tblValString)
                    self.isEnabled = true
                } else {
                    self.isEnabled = false
                }
            }
            self.selectItem(withTitle: selectedString as String)
        }        
    }

    func GetPropertyFromPropertyList(_ propertyDesc: EdsPropertyDesc) -> EdsUInt32 {
        
        var number: EdsUInt32 = 0
        
        let array = getPropDesc(propertyDesc)
        
        let selectedIndex = self.indexOfSelectedItem
        
        number = array[Int(selectedIndex)]
        
        return number
        
    }
    
}

func arrayFromTuple<T, U>(tuple: T) -> [U] {
    return Mirror(reflecting: tuple).children.map { $0.value as! U }
}

func getPropDesc(_ propertyDesc: EdsPropertyDesc) -> Array<EdsUInt32> {
    
    let test = propertyDesc.propDesc
    // C Tuple -> Array<EdsInt32>
    let arrInt32: Array<EdsInt32> = Mirror(reflecting: test).children.map { $0.value as! EdsInt32 }
    // Array<EdsInt32> -> Array<EdsUInt32>
    var arrUInt32: Array<EdsUInt32> = Array()
    for i in 0..<propertyDesc.numElements {
        // Int32->UInt32 Cast Caution!!
        arrUInt32.append( EdsUInt32( arrInt32[Int(i)] & 0x7fffffff ) )
    }
    return arrUInt32
}

