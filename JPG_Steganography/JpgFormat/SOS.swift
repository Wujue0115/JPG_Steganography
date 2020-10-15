//
//  SOS.swift
//  JPG_Steganography
//
//  Created by 鄭子輿 on 2020/8/10.
//  Copyright © 2020 MCU. All rights reserved.
//

import Foundation

class SOS {
    //  (2bytes) Start of scan marker (SOS開頭編號) (FFDA)
    var sMarker: String?
    //  (2bytes) Scan header length (不包含sMarker的SOS長度)
    var uiLength: UInt16?
    //  (1byte)  Number of image components in scan
    var uiNs: UInt8?
    //  (1byte)  Start of spectral or predictor selection
    var uiSs: UInt8?
    //  (1byte)  End of spectral selection
    var uiSe: UInt8?
    //  (4bits)  Successive approximation bit position high
    var uiAh: UInt8?
    //  (4bits)  Successive approximation bit position low or point transform
    var uiAl: UInt8?
    
    var iMCUCounts: Int?
    var PreMCU: MCU?
    
    
    //  Components types (Y: 0, CbCr: 1)
    var c: Int = 0
    //  i * Hi + j
    var m: Int = 0
    //  8 * 8 index
    var n: Int = 0
    var iZeroCounts: Int = 0
    
    
    //  Start of DQT index
    var iStartIndex: Int?
    //  End of DQT index
    var iEndIndex: Int?
    
    init(){}
    
    init(jpg: JPG) {
        sMarker = getMarker(dtData: jpg.dtData!, iIndex: jpg.iIndex)
        iStartIndex = jpg.iIndex
        jpg.iIndex += 2
        
        uiLength = getMarkerLength(dtData: jpg.dtData!, iIndex: jpg.iIndex)
        iEndIndex = jpg.iIndex + Int(uiLength!)
        jpg.iIndex += 2
        
        uiNs = jpg.dtData![jpg.iIndex]
        jpg.iIndex += 1
        
        for _ in 0..<uiNs! {
            jpg.scanComponents.append(ScanComponent(jpg: jpg))
        }
        
        uiSs = jpg.dtData![jpg.iIndex]
        jpg.iIndex += 1
        
        uiSe = jpg.dtData![jpg.iIndex]
        jpg.iIndex += 1
        
        uiAh = jpg.dtData![jpg.iIndex] >> 4
        uiAl = (jpg.dtData![jpg.iIndex] << 4) >> 4
        jpg.iIndex += 1
        
        jpg.iMCUY = Int(ceil(Double(jpg.iImageY) / Double(jpg.iVMax * 8)))
        jpg.iMCUX = Int(ceil(Double(jpg.iImageX) / Double(jpg.iHMax * 8)))
        jpg.mcus = [[MCU]](repeating: [MCU](repeating: MCU(), count: jpg.iMCUX), count: jpg.iMCUY)
        
        iMCUCounts = 0
        jpg.uiMAXCapacity = 0
        PreMCU = MCU(frameComponents: jpg.frameComponents)
        for i in 0..<jpg.iMCUY {
            for j in 0..<jpg.iMCUX {
                // print("===================================MCU_\(iMCUCounts! + 1)")
                
                jpg.mcus![i][j] = MCU(jpg: jpg, PreMCU: PreMCU!)
                
                iMCUCounts! += 1
                if (jpg.dri != nil && jpg.dri!.uiRi! != 0 && (iMCUCounts! % Int(jpg.dri!.uiRi!)) == 0) {
                    // print("DRI")
                    jpg.iBits = 0
                    jpg.iIndex += 2
                    PreMCU = MCU(frameComponents: jpg.frameComponents)
                }
                else { PreMCU = jpg.mcus![i][j] }
            }
        }
    }
    
    func Print(jpg: JPG){
        print("=============================================SOS")
        print("SOS_StartIndex : \(iStartIndex!)")
        print("SOS_Marker     : \(sMarker!)")
        print("SOS_Length     : \(uiLength!)")
        print("SOS_Ns         : \(uiNs!)")
        
        for ns in 0..<Int(uiNs!) {
            print("----------------Scan----------------")
            print("SOS_Ns         : \(ns)")
            jpg.scanComponents[ns].Print()
        }
        
        print("---------------------")
        print("SOS_Ss         : \(uiSs!)")
        print("SOS_Se         : \(uiSe!)")
        print("SOS_Ah         : \(uiAh!)")
        print("SOS_Al         : \(uiAl!)")
        
        print()
        print("SOF0_EndIndex  : \(iEndIndex!)")
        print()
        print()
    }
    
    func PrintMCU(jpg: JPG){
        iMCUCounts = 0
        for i in 0..<jpg.iMCUY {
            for j in 0..<jpg.iMCUX {
                iMCUCounts! += 1
                if (jpg.dri != nil && jpg.dri!.uiRi! != 0 && (iMCUCounts! % Int(jpg.dri!.uiRi!)) == 0) {
                    print("=============================================DRI")
                }
                print("=============================================MCU \(iMCUCounts!)")
                jpg.mcus![i][j].Print(jpg: jpg)
            }
        }
    }
}


class ScanComponent {
    //  (1byte)  Scan component selector
    var uiCsj: UInt8?
    //  (4bits)  DC entropy coding table destination selector
    var uiTdj: UInt8?
    //  (4bits)  AC entropy coding table destination selector
    var uiTaj: UInt8?
    
    init(){}
    
    init(jpg: JPG) {
        uiCsj = jpg.dtData![jpg.iIndex]
        jpg.iIndex += 1
        
        uiTdj = jpg.dtData![jpg.iIndex] >> 4
        uiTaj = (jpg.dtData![jpg.iIndex] << 4) >> 4
        jpg.iIndex += 1
    }
    
    func Print(){
        print("Scan_Ci        : \(uiCsj!)")
        print("Scan_Hi        : \(uiTdj!)")
        print("Scan_Vi        : \(uiTaj!)")
    }
}


class MCU {
    var blocks: [[[Int]]] = [[[Int]]]()
    var blocksLength: [[Int]] = [[Int]]()
    
    var node: HuffmanTree?
    var uiCategory: UInt8?
    var uiCurrentBit: UInt8 = 0
    var iSample: Int = 0
    
    //  Components types (Y: 0, CbCr: 1)
    var c: Int = 0
    //  i * Hi + j
    var m: Int = 0
    //  8 * 8 index
    var n: Int = 0
    
    init(){}
    
    init(frameComponents: [FrameComponent]){
        for k in 0..<frameComponents.count {
            blocks.append([[Int]](repeating: [Int](repeating: 0, count: 64),
                                       count: Int(frameComponents[k].uiVi! * frameComponents[k].uiHi!)))
        }
    }
    
    init(jpg: JPG, PreMCU: MCU){
        for k in 0..<jpg.frameComponents.count {
            blocks.append([[Int]](repeating: [Int](repeating: 0, count: 64), count: Int(jpg.frameComponents[k].uiVi! * jpg.frameComponents[k].uiHi!)))
            blocksLength.append([Int](repeating: 0, count: Int(jpg.frameComponents[k].uiVi! * jpg.frameComponents[k].uiHi!)))
            c = Int(k == 0 ? 0 : 1)
            m = 0
            for _ in 0..<jpg.frameComponents[k].uiVi! {
                for _ in 0..<jpg.frameComponents[k].uiHi! {
                    // DC
                    blocks[k][m][0] = PreMCU.blocks[k][m][0]
                    
                    node = jpg.huffmans[0][c].huffmanTreeRoot
                    repeat {
                        uiCurrentBit = getNextBit(jpg: jpg)
                        node = (uiCurrentBit == 0 ? node!.zeroChild! : node!.oneChild!)
                    } while (node!.uiCategory == nil)
                    uiCategory = node!.uiCategory
                    
                    if(uiCategory != 0){
                        uiCurrentBit = getNextBit(jpg: jpg)
                        iSample = Int(uiCurrentBit)
                        for _ in 1..<uiCategory! { iSample = (iSample << 1) | Int(getNextBit(jpg: jpg)) }
                        
                        if (uiCurrentBit == 0) { iSample = jpg.iZeroLowerBound[Int(uiCategory!)] + iSample }
                        blocks[k][m][0] += iSample
                    }
                    
                    
                    // AC
                    n = 1
                    while (n <= 63) {
                        node = jpg.huffmans[1][c].huffmanTreeRoot
                        repeat {
                            uiCurrentBit = getNextBit(jpg: jpg)
                            node = (uiCurrentBit == 0 ? node!.zeroChild! : node!.oneChild!)
                        } while (node!.uiCategory == nil)
                        uiCategory = node!.uiCategory
                        
                        if (uiCategory == 0) { break }
                        
                        n += Int(uiCategory! >> 4)
                        let iCodeLength: Int = Int(uiCategory! & 0xF)
                        
                        iSample = 0
                        if (iCodeLength != 0) {
                            uiCurrentBit = getNextBit(jpg: jpg)
                            iSample = Int(uiCurrentBit)
                            
                            for _ in 1..<iCodeLength { iSample = (iSample << 1) | Int(getNextBit(jpg: jpg)) }
                            if (uiCurrentBit == 0) { iSample = jpg.iZeroLowerBound[iCodeLength] + iSample }
                        }
                        
                        if (abs(iSample) > 1) { jpg.uiMAXCapacity += 1 }
                        blocks[k][m][n] = iSample
                        
                        n += 1
                    }
                    
                    blocksLength[k][m] = n
                    
                    // i * jpg.frameComponents[k].uiHi! + j
                    m += 1
                }
            }
        }
    }
    
    func Print(jpg: JPG){
        for k in 0..<jpg.frameComponents.count {
            for i in 0..<jpg.frameComponents[k].uiVi! {
                for j in 0..<jpg.frameComponents[k].uiHi! {
                    let m: Int = Int(i * jpg.frameComponents[k].uiHi! + j)
                    
                    print("____________component: \(k), Vi: \(i), Hi: \(j)____________")
                    for x in 0...7 {
                        for y in 0...7 {
                            print(String(format: " %5d", blocks[k][m][x * 8 + y]), terminator: "")
                        }
                        print()
                    }
                    print()
                }
            }
        }
    }
}


extension SOS {
    func Encode(jpg: JPG) -> Data {
        var dtEncode: Data = Data()
        
        var iMCUSum: Int = 0
        var iRSTCounts: Int = 0

        var iEncodeIndex: Int = 0
        var sEncode: String = ""
        var uiData: UInt8 = 0
        var iBits: Int = 0
        
        var dDCValue: Double = 0.0
        var dACValue: Double = 0.0
        
        dtEncode.append(0xFF)
        dtEncode.append(0xDA)
        
        dtEncode.append(UInt8(uiLength! >> 8))
        dtEncode.append(UInt8(uiLength! & 0xFF))
        
        dtEncode.append(uiNs!)
        
        for i in 0..<Int(uiNs!) {
            dtEncode.append(jpg.scanComponents[i].uiCsj!)
            dtEncode.append((jpg.scanComponents[i].uiTdj! << 4) | jpg.scanComponents[i].uiTaj!)
        }
        
        dtEncode.append(uiSs!)
        
        dtEncode.append(uiSe!)
        
        dtEncode.append((uiAh! << 4) | uiAl!)

        
        // encode MCU
        iBits = 8
        iMCUCounts = 0
        iMCUSum = jpg.iMCUY * jpg.iMCUX
        PreMCU = MCU(frameComponents: jpg.frameComponents)
        for y in 0..<jpg.iMCUY {
            for x in 0..<jpg.iMCUX {
                for k in 0..<jpg.frameComponents.count {
                    c = Int(k == 0 ? 0 : 1)
                    m = 0
                    for _ in 0..<jpg.frameComponents[k].uiVi! {
                        for _ in 0..<jpg.frameComponents[k].uiHi! {
                            // DC
                            // code length = log2(value) + 1
                            dDCValue = Double(jpg.mcus![y][x].blocks[k][m][0] - PreMCU!.blocks[k][m][0])
                            if (dDCValue != 0) { iEncodeIndex = Int(floor(log2(dDCValue < 0 ? -dDCValue : dDCValue))) + 1 }
                            else { iEncodeIndex = 0 }
                            sEncode = jpg.huffmans[0][c].reHuffmanTable[iEncodeIndex]
                            unitEncode(dtEncode: &dtEncode, uiData: &uiData, iBits: &iBits, sEncode: sEncode, iEncodeLen: iEncodeIndex, iEncodeValue: Int(dDCValue))
                            
                            // AC
                            n = 1
                            iZeroCounts = 0
                            while (n < jpg.mcus![y][x].blocksLength[k][m]) {
                                if (jpg.mcus![y][x].blocks[k][m][n] != 0) {
                                    dACValue = Double(jpg.mcus![y][x].blocks[k][m][n])
                                    iEncodeIndex = (iZeroCounts << 4) | (Int(log2(dACValue < 0 ? -dACValue : dACValue)) + 1)
                                    sEncode = jpg.huffmans[1][c].reHuffmanTable[iEncodeIndex]
                                    unitEncode(dtEncode: &dtEncode, uiData: &uiData, iBits: &iBits, sEncode: sEncode, iEncodeLen: (iEncodeIndex & 0x0F), iEncodeValue: Int(dACValue))
                                    iZeroCounts = 0
                                }
                                else {
                                    iZeroCounts += 1
                                    
                                    if (iZeroCounts == 16) {
                                        iEncodeIndex = 0xF0
                                        sEncode = jpg.huffmans[1][c].reHuffmanTable[iEncodeIndex]
                                        unitEncode(dtEncode: &dtEncode, uiData: &uiData, iBits: &iBits, sEncode: sEncode, iEncodeLen: 0, iEncodeValue: 0)
                                        iZeroCounts = 0
                                    }
                                }
                                n += 1
                            }
                            
                            if (n != 64) {
                                sEncode = jpg.huffmans[1][c].reHuffmanTable[0]
                                unitEncode(dtEncode: &dtEncode, uiData: &uiData, iBits: &iBits, sEncode: sEncode, iEncodeLen: 0, iEncodeValue: 0)
                            }
                            
                            m += 1
                        }
                    }
                }
                
                iMCUCounts! += 1
                if (jpg.dri != nil && jpg.dri!.uiRi! != 0 && (iMCUCounts! % Int(jpg.dri!.uiRi!)) == 0) {
                    if (iBits != 8) {
                        for _ in 1...iBits { uiData = (uiData << 1) | 1 }
                        dtEncode.append(uiData)
                        if (uiData == 0xFF) { dtEncode.append(0x00) }
                        
                        uiData = 0
                        iBits = 8
                    }
                    
                    if (iMCUCounts == iMCUSum) { return dtEncode }
                    
                    dtEncode.append(0xFF)
                    dtEncode.append(UInt8(0xD0 | iRSTCounts))
                    
                    iRSTCounts = (iRSTCounts == 7 ? 0 : iRSTCounts + 1)
                    PreMCU = MCU(frameComponents: jpg.frameComponents)
                }
                else { PreMCU = jpg.mcus![y][x] }
            }
        }
        
        if (iBits != 8) {
            for _ in 1...iBits { uiData = (uiData << 1) | 1 }
            dtEncode.append(uiData)
            if (uiData == 0xFF) { dtEncode.append(0x00) }
        }
        
        return dtEncode
    }
}
