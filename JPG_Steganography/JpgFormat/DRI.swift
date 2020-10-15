//
//  DRI.swift
//  JPG_Steganography
//
//  Created by 鄭子輿 on 2020/8/23.
//  Copyright © 2020 MCU. All rights reserved.
//

import Foundation

class DRI {
    //  (2bytes) Define quantization table marker (DRI開頭編號) (FFDD)
    var sMarker: String?
    //  (2bytes) Quantization table definition length (不包含Marker的DRI長度)
    var uiLength: UInt16?
    //  (2bytes) Restart interval – Specifies the number of MCU in the restart interval
    var uiRi: UInt16?
    
    //  Start of DQT index
    var iStartIndex: Int?
    //  End of DQT index
    var iEndIndex: Int?
    
    init(){}
    
    init(jpg: JPG){
        sMarker = getMarker(dtData: jpg.dtData!, iIndex: jpg.iIndex)
        iStartIndex = jpg.iIndex
        jpg.iIndex += 2
        
        uiLength = getMarkerLength(dtData: jpg.dtData!, iIndex: jpg.iIndex)
        iEndIndex = jpg.iIndex + Int(uiLength!)
        jpg.iIndex += 2
        
        uiRi = (UInt16(jpg.dtData![jpg.iIndex]) << 8) | UInt16(jpg.dtData![jpg.iIndex+1])
        jpg.iIndex += 2
    }
    
    func Print(){
        print("=============================================DRI")
        print("DRI_StartIndex : \(iStartIndex!)")
        print("DRI_Marker     : \(sMarker!)")
        print("DRI_Length     : \(uiLength!)")
        print("DRI_RI         : \(uiRi!)")
        
        print()
        print("DHT_EndIndex   : \(iEndIndex!)")
        print()
        print()
    }
}
