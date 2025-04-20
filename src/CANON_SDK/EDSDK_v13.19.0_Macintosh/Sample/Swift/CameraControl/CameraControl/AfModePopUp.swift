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

class AfModePopUp: PropertyPopUp {
    
    let PROPERTYLIST: NSDictionary = [
        0x00:"One-Shot AF",
        0x01:"AI Servo AF",
        0x02:"AI Focus AF",
        0x03:"Manual Focus",
        0xffffffff:"unknown"]
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.removeAllItems()
    }
}
