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

class MovieHFRPopUp: PropertyPopUp {
    
     // List of value and display name
    let PROPERTYLIST: NSDictionary = [
        0: "Disable",    
        1: "Enable",
        0xffffffff: "unknown"]
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.removeAllItems()
    }
}
