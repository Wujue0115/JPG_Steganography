//
//  SOF0.swift
//  JPG_Steganography
//
//  Created by 鄭子輿 on 2020/8/14.
//  Copyright © 2020 MCU. All rights reserved.
//

import Foundation

class SOF0 {
    //  (2bytes) Start of frame marker (SOF0開頭編號) (FFC0)
    var sMarker: String?
    //  (2bytes) Frame header length (不包含sMarker的SOF0長度)
    var uiLength: UInt16?
    //  (1byte)  Sample precision
    //  Specifies the precision in bits for the samples of the components in the frame.
    var uiP: UInt8?
    //  (2bytes) Number of lines
    var uiY: UInt16?
    //  (2bytes) Number of samples per line
    var uiX: UInt16?
    //  (1byte)  Number of image components in frame
    var uiNf: UInt8?
    
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
        
        uiP = jpg.dtData![jpg.iIndex]
        jpg.iIndex += 1
        
        uiY = (UInt16(jpg.dtData![jpg.iIndex]) << 8) | UInt16(jpg.dtData![jpg.iIndex+1])
        jpg.iImageY = Int(uiY!)
        jpg.iIndex += 2
        
        uiX = (UInt16(jpg.dtData![jpg.iIndex]) << 8) | UInt16(jpg.dtData![jpg.iIndex+1])
        jpg.iImageX = Int(uiX!)
        jpg.iIndex += 2
        
        uiNf = jpg.dtData![jpg.iIndex]
        jpg.iIndex += 1
        
        for _ in 0..<uiNf! {
            jpg.frameComponents.append(FrameComponent(jpg: jpg))
        }
    }
    
    func Print(jpg: JPG){
        print("=============================================SOF0")
        print("SOF0_StartIndex: \(iStartIndex!)")
        print("SOF0_Marker    : \(sMarker!)")
        print("SOF0_Length    : \(uiLength!)")
        print("SOF0_P         : \(uiP!)")
        print("SOF0_Y         : \(uiY!)")
        print("SOF0_X         : \(uiX!)")
        print("SOF0_Nf        : \(uiNf!)")
        
        for nf in 0..<Int(uiNf!) {
            print("----------------Frame----------------")
            print("SOF0_Tq        : \(nf)")
            jpg.frameComponents[nf].Print()
        }
        
        print()
        print("SOF0_EndIndex  : \(iEndIndex!)")
        print()
        print()
    }
}


class FrameComponent {
    //  (1byte)  Component identifier
    var uiCi: UInt8?
    //  (4bits)  Horizontal sampling factor
    var uiHi: UInt8?
    //  (4bits)  Vertical sampling factor
    var uiVi: UInt8?
    //  (1byte)  Quantization table destination selector
    var uiTqi: UInt8?
    
    init(){}
    
    init(jpg: JPG){
        uiCi = jpg.dtData![jpg.iIndex]
        jpg.iIndex += 1
        
        uiHi = jpg.dtData![jpg.iIndex] >> 4
        uiVi = (jpg.dtData![jpg.iIndex] << 4) >> 4
        jpg.iIndex += 1
        
        if (uiHi! > jpg.iHMax) { jpg.iHMax = Int(uiHi!) }
        if (uiVi! > jpg.iVMax) { jpg.iVMax = Int(uiVi!) }
        
        uiTqi = jpg.dtData![jpg.iIndex]
        jpg.iIndex += 1
    }
    
    func Print(){
        print("Frame_Ci       : \(uiCi!)")
        print("Frame_Hi       : \(uiHi!)")
        print("Frame_Vi       : \(uiVi!)")
        print("Frame_Tqi      : \(uiTqi!)")
    }
}
