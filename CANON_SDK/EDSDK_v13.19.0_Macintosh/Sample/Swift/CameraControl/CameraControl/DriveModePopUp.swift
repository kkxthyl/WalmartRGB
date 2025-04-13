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

class DriveModePopUp: PropertyPopUp {
    
    let PROPERTYLIST: NSDictionary = [
        0x00:"Single shooting",
        0x01:"Medium speed continuous",
        0x02:"Video",
        0x03:"Not used",
        0x04:"High speed continuous",
        0x05:"Low speed continuous",
        0x06:"Single Silent(Soft) shooting",
        0x07:"Self-timer:Continuous",
        0x10:"Self-timer:10 sec",
        0x11:"Self-timer:2 sec",
        0x12:"High speed continuous +",
        0x13:"Silent single shooting",
        0x14:"Silent(Soft) contin shooting",
        0x15:"Silent HS continuous",
        0x16:"Silent(Soft) LS continuous",
        0xffffffff:"unknown"]
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.removeAllItems()
    }
}


