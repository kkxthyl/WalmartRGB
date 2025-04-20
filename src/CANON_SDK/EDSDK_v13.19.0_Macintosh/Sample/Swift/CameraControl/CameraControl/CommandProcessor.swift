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

class CommandProcessor{
    let _commandQueue = DispatchQueue(label: "commandQueue")
    
    func executeCommand(_ command : Command){
        if(!command.execute())
        {
            //If commands that were issued fail ( because of DeviceBusy or other reasons )
            // and retry is required , note that some cameras may become unstable if multiple
            // commands are issued in succession without an intervening interval.
            //Thus, leave an interval of about 500 ms before commands are reissued.
            Thread.sleep(forTimeInterval: 0.5)
            _commandQueue.async{() in
                self.executeCommand(command)
            }
        }
        
    }
    
    func postCommand(_ command : Command){
        Thread.sleep(forTimeInterval: 0.001)
        _commandQueue.async{() in
            self.executeCommand(command)
        }
    }
}
