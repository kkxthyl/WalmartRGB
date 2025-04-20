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

class ActionRadioButton: NSButton, ActionSource {
    
   
    fileprivate var _listener: CameraController!
    fileprivate var _command: ActionEvent.Command = ActionEvent.Command.none
    
    func setCommand(_ command: ActionEvent.Command){
        
        _command = command
        
    }
    
    func addActionListener(_ listener: CameraController){
        _listener = listener
    }
    
    func removeActionListener(){
        _listener = nil
    }
    
    
    func fireEvent(){
        
        let event = ActionEvent(command: _command, object: 0 as AnyObject)
        DispatchQueue.main.async{() in
            self._listener.actionPerformed(event)
        }
    }
    
}

