/******************************************************************************
 *                                                                             *
 *   PROJECT : PowerShot G7X Mark II Software Development Kit PSG7XMK2SDK      *
 *                                                                             *
 *   Description: This is the Sample code to show the usage of PSG7XMK2SDK.    *
 *                                                                             *
 *                                                                             *
 *******************************************************************************
 *                                                                             *
 *   Written and developed by Canon Inc.                                       *
 *   Copyright Canon Inc. 2017 All Rights Reserved                             *
 *                                                                             *
 *******************************************************************************/

import Cocoa

class PreFlashModePopUp: PropertyPopUp {
    
    let PROPERTYLIST: NSDictionary = [
        0x00:"Auto",
        0x01:"Manual"]
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.removeAllItems()
    }
}