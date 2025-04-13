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

class ExposureCompPopUp: PropertyPopUp {
    
    // List of value and display name
    let PROPERTYLIST: NSDictionary = [
        0x28: "+5" ,
        0x25: "+4 2/3",
        0x24: "+4 1/2",
        0x23: "+4 1/3",
        0x20: "+4" ,
        0x1d: "+3 2/3",
        0x1c: "+3 1/2",
        0x1b: "+3 1/3",
        0x18: "+3",
        0x15: "+2 2/3",
        0x14: "+2 1/2",
        0x13: "+2 1/3",
        0x10: "+2",
        0x0d: "+1 2/3",
        0x0c: "+1 1/2",
        0x0b: "+1 1/3",
        0x08: "+1",
        0x05: "+2/3",
        0x04: "+1/2",
        0x03: "+1/3",
        0x00: "0",
        0xfd: "-1/3",
        0xfc: "-1/2",
        0xfb: "-2/3",
        0xf8: "-1",
        0xf5: "-1 1/3",
        0xf4: "-1 1/2",
        0xf3: "-1 2/3",
        0xf0: "-2",
        0xed: "-2 1/3",
        0xec: "-2 1/2",
        0xeb: "-2 2/3",
        0xe8: "-3",
        0xe5: "-3 1/3",
        0xe4: "-3 1/2",
        0xe3: "-3 2/3",
        0xe0: "-4",
        0xdd: "-4 1/3",
        0xdc: "-4 1/2",
        0xdb: "-4 2/3",
        0xd8: "-5",
        0xffffffff: "unknown"]
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.removeAllItems()
    }
}
