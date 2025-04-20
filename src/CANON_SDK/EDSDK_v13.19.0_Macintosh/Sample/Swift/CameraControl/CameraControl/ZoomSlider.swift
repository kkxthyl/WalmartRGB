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

class ZoomSlider: NSSlider, ActionSource{
    
    fileprivate var _listener: CameraController!
    
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
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        self.isEnabled = false

    }
    
    func updateProperty(_ value: EdsUInt32) {
        
       self.intValue = Int32(value)
        
    }
    
    func updatePropertyDesc(_ desc: EdsPropertyDesc) {
        
        if (desc.numElements == 0){
            
            self.isEnabled = false
            
        }else{
            
            let array = getPropDesc(desc)
            self.minValue = 0
            self.maxValue = Double(Double(array[0]) - 1.0)
            self.numberOfTickMarks = Int(array[0])
            self.allowsTickMarkValuesOnly = true
            self.isEnabled = true
            
        }
    }
    
    func fireEvent() {
        
        let data = self.doubleValue
        let event = ActionEvent(command: _command, object: NSInteger(data) as AnyObject)
        DispatchQueue.main.async{() in
            self._listener.actionPerformed(event)
        }
        
    }
}
