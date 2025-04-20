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

class BatteryLevelLabel: InfoLabel {
    
    func updateProperty(_ value: EdsUInt32){
        
        var infoText = "AC"
        if (0xffffffff != value)
        {
            infoText = String(value) + "%"
        }
        self.UpdateString(infoText)
    }
    
}

