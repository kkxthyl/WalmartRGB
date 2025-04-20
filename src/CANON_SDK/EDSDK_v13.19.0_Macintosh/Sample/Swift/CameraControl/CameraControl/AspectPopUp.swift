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

class AspectPopUp : PropertyPopUp {
    
    let PROPERTYLIST : NSDictionary = [
        0x00000000 : "Full-frame",
        0x00000001 : "1:1(aspect ratio)",
        0x00000002 : "4:3(aspect ratio)",
        0x00000007 : "16:9(aspect ratio)",
        0x0000000d : "1.6x(crop)" ]
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.removeAllItems()
    }
    
}
