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

class MeteringPopUp: PropertyPopUp {
    
     // List of value and display name
    let PROPERTYLIST: NSDictionary = [
        1: "Spot metering",
        3: "Evaluative metering",
        4: "Partial metering",
        5: "Center-weighted average",
        0xffffffff: "unknown"]
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.removeAllItems()
    }
}
