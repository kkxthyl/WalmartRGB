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

class TempStatusLabel: InfoLabel {
    
    func updateProperty(_ value: EdsUInt32){
        
        var desc = [String]()
        desc = ["Normal", "Warning", "FramerateDown", "DisableLiveview", "DisableRelease", "StillQualityWarning", "RestrictionMovieRecording", "unknown"]
        var infoText = ""
        if ((value & 0xffff0000) == 0x00020000)
        {
            infoText = desc[6]
        }
        else
        {
            if (desc.count > Int(value))
            {
                infoText = desc[Int(value)]
            }
            else
            {
                infoText = desc[desc.count - 1]
            }
        }
        self.UpdateString(infoText)
    }
}
