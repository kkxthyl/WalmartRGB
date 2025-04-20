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

class WhiteBalancePopUp: PropertyPopUp {
    
    let PROPERTYLIST: NSDictionary = [
        0: "Auto: Ambience priority",
        1: "Daylight",
        2: "Cloudy",
        3: "Tungsten light",
        4: "White fluorescent light",
        5: "Flash",
        6: "Custom1",
       
        8: "Shade",
        9: "Color temp.",
        10: "Custom white balance: PC-1",
        11: "Custom white balance: PC-2",
        12: "Custom white balance: PC-3",
        
        15: "Custom2",
        16: "Custom3",
        17: "Underwater",
        18: "Custom4",
        19: "Custom5",
        20: "Custom white balance: PC-4",
        21: "Custom white balance: PC-5",
        23: "Auto: White priority",
        24: "Color temp.2",
        25: "Color temp.3",
        26: "Color temp.4",
        0xffffffff: "unknown"]
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.removeAllItems()
    }
    
}

