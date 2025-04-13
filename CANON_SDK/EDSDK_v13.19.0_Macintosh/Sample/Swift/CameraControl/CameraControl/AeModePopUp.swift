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

class AeModePopUp: PropertyPopUp {
    
    let PROPERTYLIST: NSDictionary = [
        0:"P",
        1:"Tv",
        2:"Av",
        3:"M",
        4:"Bulb",
        5:"A-DEP",
        6:"DEP",
        
        8:"Lock",
        9:"Auto",
        10:"Night Portrait",
        11:"Sports",
        12:"Portrait",
        13:"Landscape",
        14:"Close-up",
        15:"Flash Off",
       
        19:"Creative Auto",
        
        20:"Movies",
        
        22:"Scene Intelligent Auto",
        23:"Handheld Night Scene",
        24:"HDR Backlight Control",
        
        26:"Kids",
        27:"Food",
        28:"Candlelight",
        29:"Creative filters",
        
        30:"Grainy B/W",
        31:"Soft focus",
        32:"Toy camera effect",
        33:"Fish-eye effect",
        34:"Water painting effect",
        35:"Miniature effect",
        36:"HDR art standard",
        37:"HDR art vivid",
        38:"HDR art bold",
        39:"HDR art embossed",
        40:"Dream",
        41:"Old Movies",
        42:"Memory",
        43:"Dramatic B&W",
        44:"Miniature effect movie",
        45:"Panning",
        46:"Group Photo",
        49:"HDR Movie",
        
        50:"Self Portrait",
        51:"Plus Movie Auto",
        52:"Smooth skin",
        53:"Panorama",
        54:"Silent Mode",
        55:"Fv",
        56:"Art bold effect",
        57:"Fireworks",
        58:"Star portrait",
        59:"Star nightscape",
        60:"Star trails",
        61:"Star time-lapse movie",
        62:"Background blur",
        
        7:"C1",
        16:"C2",
        17:"C3",
        25:"SCN",
        
        0xffffffff:"unknown"]
        
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.removeAllItems()
    }
}
