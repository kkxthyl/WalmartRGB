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

class EvfAfModePopUp: PropertyPopUp {
    
    // List of value and display name
    let PROPERTYLIST: NSDictionary = [
        0x00: "Quick mode",
        0x01: "1-point AF",
        0x02: "Face+Tracking",
        0x03: "Live FlexiZone-Multi mode",
        0x04: "Zone AF",
        0x05: "Expand AF area",
        0x06: "Expand AF area: Around",
        0x07: "Large Zone AF: Horizontal",
        0x08: "Large Zone AF: Vertical",
        0x09: "Catch AF",
        0x0a: "Spot AF",
        0x0b: "Flexible Zone AF 1",
        0x0c: "Flexible Zone AF 2",
        0x0d: "Flexible Zone AF 3",
        0x0e: "Whole area AF",
        0x0f: "No Traking Spot AF",
        0x10: "No Traking 1-point AF",
        0x11: "No Traking Expand AF area",
        0x12: "No Traking Expand AF area: Around",
        0xffffffff: "unknown"]
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.removeAllItems()
    }
}
