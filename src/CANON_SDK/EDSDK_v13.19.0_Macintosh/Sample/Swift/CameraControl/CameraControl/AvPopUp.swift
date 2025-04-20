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

class AvPopUp: PropertyPopUp {

    // List of value and display name
    let PROPERTYLIST:NSDictionary = [
        0x00: "00",
        0x08: "1.0",
        0x0B: "1.1",
        0x0C: "1.2",
        0x0D: "1.2",
        0x10: "1.4",
        0x13: "1.6",
        0x14: "1.8",
        0x15: "1.8",
        0x18: "2.0",
        0x1B: "2.2",
        0x1C: "2.5",
        0x1D: "2.5",
        0x20: "2.8",
        0x23: "3.2",
        0x80: "3.3",
        0x85: "3.4",
        0x24: "3.5",
        0x25: "3.5",
        0x28: "4.0",
        0x2B: "4.5",
        0x2C: "4.5",
        0x2D: "5.0",
        0x30: "5.6",
        0x33: "6.3",
        0x34: "6.7",
        0x35: "7.1",
        0x38: "8.0",
        0x3B: "9.0",
        0x3C: "9.5",
        0x3D: "10" ,
        0x40: "11" ,
        0x43: "13" ,
        0x44: "13" ,
        0x45: "14" ,
        0x48: "16" ,
        0x4B: "18" ,
        0x4C: "19" ,
        0x4D: "20" ,
        0x50: "22" ,
        0x53: "25" ,
        0x54: "27" ,
        0x55: "29" ,
        0x58: "32" ,
        0x5B: "36" ,
        0x5C: "38" ,
        0x5D: "40" ,
        0x60: "45" ,
        0x63: "51" ,
        0x64: "54" ,
        0x65: "57" ,
        0x68: "64" ,
        0x6B: "72" ,
        0x6C: "76" ,
        0x6D: "80" ,
        0x70: "91" ,
        0xFF: "Auto" ,
        0xffffffff: "unknown"]

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.removeAllItems()
    }
}
