//
//  HEADER.swift
//  JPG_Steganography
//
//  Created by 鄭子輿 on 2020/8/24.
//  Copyright © 2020 MCU. All rights reserved.
//

import Foundation

class JPG_HEADER {
    var sMarker: String = ""
    var uiLength: UInt16?
    
    init(){}
    
    init(dtData: Data, iIndex: Int) {
        guard iIndex+2 < dtData.count else { return }
        sMarker = getMarker(dtData: dtData, iIndex: iIndex)
        guard iIndex+4 < dtData.count else { return }
        uiLength = getMarkerLength(dtData: dtData, iIndex: iIndex+2)
    }
    
    func getLength() -> Int {
        guard uiLength != nil else { return 2 }
        return 2+Int(uiLength!)
    }
}
