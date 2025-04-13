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

class PictureStylePopUp: PropertyPopUp {
    
    let PROPERTYLIST: NSDictionary = [
        0x0081:"Standard",
        0x0082:"Portrait",
        0x0083:"Landscape",
        0x0084:"Nutral",
        0x0085:"Faithful",
        0x0086:"Monochrome",
        0x0087:"Auto",
        0x0088:"FineDetail",
        0x0021:"User Def. 1",
        0x0022:"User Def. 2",
        0x0023:"User Def. 3",
        0x0041:"PC1",
        0x0042:"PC2",
        0x0043:"PC3",
    ]
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.removeAllItems()
    }
    
}
