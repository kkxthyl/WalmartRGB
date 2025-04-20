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

class IsoPopUp: PropertyPopUp {
    
    // List of value and display name
    let PROPERTYLIST: NSDictionary = [
        0x00: "Auto",
        0x28: "6" ,
        0x30: "12" ,
        0x38: "25" ,
        0x40: "50" ,
        0x48: "100" ,
        0x4b: "125" ,
        0x4d: "160" ,
        0x50: "200" ,
        0x53: "250" ,
        0x55: "320" ,
        0x58: "400" ,
        0x5b: "500" ,
        0x5d: "640" ,
        0x60: "800" ,
        0x63: "1000" ,
        0x65: "1250" ,
        0x68: "1600" ,
        0x6b: "2000" ,
        0x6d: "2500" ,
        0x70: "3200" ,
        0x73: "4000" ,
        0x75: "5000" ,
        0x78: "6400" ,
        0x7b: "8000" ,
        0x7d: "10000" ,
        0x80: "12800" ,
        0x83: "16000" ,
        0x85: "20000" ,
        0x88: "25600" ,
        0x8b: "32000" ,
        0x8d: "40000" ,
        0x90: "51200" ,
        0x93: "64000" ,
        0x95: "80000" ,
        0x98: "102400" ,
        0xa0: "204800" ,
        0xa8: "409600" ,
        0xb0: "819200" ,
        
        0xffffffff: "unknown"]
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.removeAllItems()
    }
}
