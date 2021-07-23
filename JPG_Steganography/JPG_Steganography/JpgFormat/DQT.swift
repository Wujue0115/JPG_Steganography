//
//  Read.swift
//  JPG_Steganography
//
//  Created by 鄭子輿 on 2020/7/29.
//  Copyright © 2020 MCU. All rights reserved.
//

import Foundation

class DQT {
    //  (2bytes) Define quantization table marker (DQT開頭編號) (FFDB)
    var sMarker: String?
    //  (2bytes) Quantization table definition length (不包含Marker的DQT長度)
    var uiLength: UInt16?
    //  (4bits)  Quantization table element precision (量化表精度)
    //  Value 0 indicates 8-bit Qk values; Value 1 indicates 16-bit Qk values.
    var uiPq: UInt8?
    //  (4bits)  Quantization table destination identifier (量化表ID)
    var uiTq: UInt8?
    
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
        
        while (jpg.iIndex < iEndIndex!) {
            uiPq = jpg.dtData![jpg.iIndex] >> 4
            uiTq = (jpg.dtData![jpg.iIndex] << 4) >> 4
            jpg.iIndex += 1
            
            jpg.quantizationTables[Int(uiTq!)] = QuantizationTable(jpg: jpg, uiPq: uiPq!)
        }
    }
    
    func Print(jpg: JPG) {
        print("=============================================DQT")
        print("DQT_StartIndex : \(iStartIndex!)")
        print("DQT_Marker     : \(sMarker!)")
        print("DQT_Length     : \(uiLength!)")
        print("DQT_Pq         : \(uiPq!)")
        
        for tq in 0...1 {
            print("----------------DQT----------------")
            print("DQT_Tq         : \(tq)")
            jpg.quantizationTables[tq].Print()
        }
        
        print()
        print("DQT_EndIndex   : \(iEndIndex!)")
        print()
        print()
    }
}


class QuantizationTable {
    //  (4bits)  Quantization table element precision (量化表精度)
    //  Value 0 indicates 8-bit Qk values; Value 1 indicates 16-bit Qk values.
    var uiPq: UInt8?
    //  ((uiPq ? 2 : 1) * 64 bytes) Quantization table element (量化表) (8 * 8)
    var uiQk: [[UInt16]] = [[UInt16]](repeating: [UInt16](repeating: UInt16(), count: 8), count: 8)
    var PriorityTable: [(iIndex: Int, iVal: Int)] = [(iIndex: Int, iVal: Int)]()
    
    var Zigzag: [Int] = [
         0,  1,  5,  6, 14, 15, 27, 28,
         2,  4,  7, 13, 16, 26, 29, 42,
         3,  8, 12, 17, 25, 30, 41, 43,
         9, 11, 18, 24, 31, 40, 44, 53,
        10, 19, 23, 32, 39, 45, 52, 54,
        20, 22, 33, 38, 46, 51, 55, 60,
        21, 34, 37, 47, 50, 56, 59, 61,
        35, 36, 48, 49, 57, 58, 62, 63
    ]
    
    init(){}
    
    init(jpg: JPG, uiPq: UInt8){
        for i in 0...7 {
            for j in 0...7 {
                uiQk[i][j] = UInt16(jpg.dtData![jpg.iIndex])
                jpg.iIndex += 1
                
                if (uiPq == 1) {
                    uiQk[i][j] = (uiQk[i][j] << 8) | UInt16(jpg.dtData![jpg.iIndex])
                    jpg.iIndex += 1
                }
            }
        }
    }
    
    func Print(){
        print("--------------------------------")
        for i in 0...7 {
            for j in 0...7 {
                print(String(format: " %3d", uiQk[i][j]), terminator: "")
            }
            print()
        }
    }
    
    func SortPriorityAC(){
        var iIndex: Int = 0
        PriorityTable = [(iIndex: Int, iVal: Int)]()
        for i in 0...7 {
            for j in 0...7 {
                /*
                if ((i | j) != 0) {
                    PriorityTable.append((iIndex: Int(i * 8 + j), iVal: Int(uiQk[i][j])))
                }
                */
                if(Zigzag[iIndex] != 0){
                    PriorityTable.append((iIndex: Zigzag[iIndex], iVal: Int(uiQk[i][j])))
                }
                iIndex += 1
            }
        }
        PriorityTable.sort(by: {($0.iVal != $1.iVal ? $0.iVal < $1.iVal : $0.iIndex < $1.iIndex)})
    }
}
