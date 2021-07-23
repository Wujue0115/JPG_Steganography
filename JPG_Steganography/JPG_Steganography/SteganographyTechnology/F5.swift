//
//  F5.swift
//  JPG_Steganography
//
//  Created by 鄭子輿 on 2020/8/25.
//  Copyright © 2020 MCU. All rights reserved.
//

import Foundation

//  (MCUY, MCUX, ComponentID, Vi * Hi + Hi, n(1...63))
typealias typeLocation = (y: Int, x: Int, k: Int, m: Int, n: Int )

func F5Embed(StegoMedia jpg: JPG, sEmbedText: String, TotalBits TB: Int, ParityBitCoverage PBC: Int) -> Bool {
    //  嵌入訊息
    var dtEmbedText: Data = Data()
    //  總嵌入長度 (unit: byte)
    var uiEmbedLength: UInt = 1
    
    var codeIndex: Int = 0
    var codeDatas: [typeLocation] = [typeLocation](repeating: typeLocation(0, 0, 0, 0, 0), count: 1 + TB)
    var parityBits: [Int] = [Int](repeating: 0, count: PBC)
    
    var iIndex: Int = 0
    var uiData: UInt8 = 0
    var iBits: Int = 0
    var iGetBit: Int = 0
    
    var iTemp: Int = 0

    jpg.uiMAXCapacity = jpg.uiMAXCapacity / UInt(TB) * UInt(PBC) / 8
    
    if (jpg.uiMAXCapacity <= 4) {
        print("這張影像太小無法遷入訊息!")
        return false
    }
    
    //  總嵌入長度 = 存取嵌入訊息長度(4 bytes) + 嵌入訊息長度
    uiEmbedLength = 4 + UInt(sEmbedText.utf8.count)
    
    if (uiEmbedLength > jpg.uiMAXCapacity) {
        print("嵌入訊息長度大於最大可遷入容量!")
        print("最大可嵌入訊息容量: \(jpg.uiMAXCapacity - 4) bytes")
        print("嵌入訊息長度: \(uiEmbedLength - 4) bytes")
        return false
    }
    
    print("最大可嵌入訊息容量: \(jpg.uiMAXCapacity - 4) bytes")
    print("總嵌入訊息長度: \(uiEmbedLength) bytes")
    print("嵌入訊息: \(sEmbedText)")
    
    //  將嵌入訊息字串存進dtEmbedText中
    for i in stride(from: 3, through: 0, by: -1) {
        dtEmbedText.append(UInt8(uiEmbedLength >> Int(i << 3) & 0xFF))
    }
    dtEmbedText.append(Data(sEmbedText.utf8))
    
    jpg.quantizationTables[0].SortPriorityAC()
    jpg.quantizationTables[1].SortPriorityAC()
    for py in 0...62 {
        //  [亮度AC優先位置, 彩度AC優先位置]
        let n: [Int] = [jpg.quantizationTables[0].PriorityTable[py].iIndex, jpg.quantizationTables[1].PriorityTable[py].iIndex]
        for y in 0..<jpg.iMCUY {
            for x in 0..<jpg.iMCUX {
                for k in 0..<jpg.frameComponents.count {
                    let c: Int = Int(k == 0 ? 0 : 1)
                    for i in 0..<jpg.frameComponents[k].uiVi! {
                        for j in 0..<jpg.frameComponents[k].uiHi! {
                            let m: Int = Int(i * jpg.frameComponents[k].uiHi! + j)
                            
                            if (abs(jpg.mcus![y][x].blocks[k][m][n[c]]) <= 1) { continue }
                            
                            codeIndex += 1
                            codeDatas[codeIndex] = (y, x, k, m, n[c])
                            iTemp = jpg.mcus![y][x].blocks[k][m][n[c]]
                            for p in 0..<PBC {
                                if (((codeIndex >> p) & 1) == 1) {
                                    parityBits[p] ^= ((iTemp < 0 ? iTemp ^ 1 : iTemp) & 1)
                                }
                            }
                            
                            
                            if (codeIndex == TB) {
                                codeIndex = 0
                                for p in 0..<PBC {
                                    iGetBit = getNextBit(dtData: dtEmbedText, iIndex: &iIndex, uiData: &uiData, iBits: &iBits)
                                    
                                    if (iGetBit == -1) {
                                        if (p != 0) {
                                            let cd = codeDatas[codeIndex]
                                            iTemp = jpg.mcus![cd.y][cd.x].blocks[cd.k][cd.m][cd.n]
                                            if (iTemp > 0) { jpg.mcus![cd.y][cd.x].blocks[cd.k][cd.m][cd.n] ^= 1 }
                                            else { jpg.mcus![cd.y][cd.x].blocks[cd.k][cd.m][cd.n] += ((iTemp & 1) == 1 ? 1 : -1) }
                                        }
                                        
                                        print("End of embedding!")
                                        print("=============================================")
                                        return true
                                    }
                                    
                                    if ((parityBits[p] ^ iGetBit) == 1) { codeIndex += (1 << p) }
                                    parityBits[p] = 0
                                }
                                
                                if (codeIndex != 0){
                                    let cd = codeDatas[codeIndex]
                                    iTemp = jpg.mcus![cd.y][cd.x].blocks[cd.k][cd.m][cd.n]
                                    if (iTemp > 0) { jpg.mcus![cd.y][cd.x].blocks[cd.k][cd.m][cd.n] ^= 1 }
                                    else { jpg.mcus![cd.y][cd.x].blocks[cd.k][cd.m][cd.n] += ((iTemp & 1) == 1 ? 1 : -1) }
                                }
                                
                                codeIndex = 0
                            }
                        }
                    }
                }
            }
        }
    }
    
    return false
}



func F5RSAEmbed(StegoMedia jpg: JPG, dtRSAEmbedText: Data, TotalBits TB: Int, ParityBitCoverage PBC: Int) -> Bool {
    //  嵌入訊息
    var dtEmbedText: Data = Data()
    //  總嵌入長度 (unit: byte)
    var uiEmbedLength: UInt = 1
    
    var codeIndex: Int = 0
    var codeDatas: [typeLocation] = [typeLocation](repeating: typeLocation(0, 0, 0, 0, 0), count: 1 + TB)
    var parityBits: [Int] = [Int](repeating: 0, count: PBC)
    
    var iIndex: Int = 0
    var uiData: UInt8 = 0
    var iBits: Int = 0
    var iGetBit: Int = 0
    
    var iTemp: Int = 0

    jpg.uiMAXCapacity = jpg.uiMAXCapacity / UInt(TB) * UInt(PBC) / 8
    
    if (jpg.uiMAXCapacity <= 4) {
        print("這張影像太小無法遷入訊息!")
        return false
    }
    
    //  總嵌入長度 = 存取嵌入訊息長度(4 bytes) + 嵌入訊息長度
    uiEmbedLength = UInt(4 + dtRSAEmbedText.count)
    if (uiEmbedLength > jpg.uiMAXCapacity) {
        print("嵌入訊息長度大於最大可遷入容量!")
        print("最大可嵌入訊息容量: \(jpg.uiMAXCapacity - 4) bytes")
        print("嵌入訊息長度: \(uiEmbedLength - 4) bytes")
        return false
    }
    
    print("最大可嵌入訊息容量: \(jpg.uiMAXCapacity - 4) bytes")
    print("總嵌入訊息長度: \(uiEmbedLength) bytes")
    print("嵌入訊息: \(dtRSAEmbedText)")
    
    //  將嵌入訊息字串存進dtEmbedText中
    for i in stride(from: 3, through: 0, by: -1) {
        dtEmbedText.append(UInt8(uiEmbedLength >> Int(i << 3) & 0xFF))
    }
    dtEmbedText.append(dtRSAEmbedText)
    
    jpg.quantizationTables[0].SortPriorityAC()
    jpg.quantizationTables[1].SortPriorityAC()
    for py in 0...62 {
        //  [亮度AC優先位置, 彩度AC優先位置]
        let n: [Int] = [jpg.quantizationTables[0].PriorityTable[py].iIndex, jpg.quantizationTables[1].PriorityTable[py].iIndex]
        for y in 0..<jpg.iMCUY {
            for x in 0..<jpg.iMCUX {
                for k in 0..<jpg.frameComponents.count {
                    let c: Int = Int(k == 0 ? 0 : 1)
                    for i in 0..<jpg.frameComponents[k].uiVi! {
                        for j in 0..<jpg.frameComponents[k].uiHi! {
                            let m: Int = Int(i * jpg.frameComponents[k].uiHi! + j)
                            
                            if (abs(jpg.mcus![y][x].blocks[k][m][n[c]]) <= 1) { continue }
                            
                            codeIndex += 1
                            codeDatas[codeIndex] = (y, x, k, m, n[c])
                            iTemp = jpg.mcus![y][x].blocks[k][m][n[c]]
                            for p in 0..<PBC {
                                if (((codeIndex >> p) & 1) == 1) {
                                    parityBits[p] ^= ((iTemp < 0 ? iTemp ^ 1 : iTemp) & 1)
                                }
                            }
                            
                            
                            if (codeIndex == TB) {
                                codeIndex = 0
                                for p in 0..<PBC {
                                    iGetBit = getNextBit(dtData: dtEmbedText, iIndex: &iIndex, uiData: &uiData, iBits: &iBits)
                                    
                                    if (iGetBit == -1) {
                                        if (p != 0) {
                                            let cd = codeDatas[codeIndex]
                                            iTemp = jpg.mcus![cd.y][cd.x].blocks[cd.k][cd.m][cd.n]
                                            if (iTemp > 0) { jpg.mcus![cd.y][cd.x].blocks[cd.k][cd.m][cd.n] ^= 1 }
                                            else { jpg.mcus![cd.y][cd.x].blocks[cd.k][cd.m][cd.n] += ((iTemp & 1) == 1 ? 1 : -1) }
                                        }
                                        
                                        print("End of embedding!")
                                        print("=============================================")
                                        return true
                                    }
                                    
                                    if ((parityBits[p] ^ iGetBit) == 1) { codeIndex += (1 << p) }
                                    parityBits[p] = 0
                                }
                                
                                if (codeIndex != 0){
                                    let cd = codeDatas[codeIndex]
                                    iTemp = jpg.mcus![cd.y][cd.x].blocks[cd.k][cd.m][cd.n]
                                    if (iTemp > 0) { jpg.mcus![cd.y][cd.x].blocks[cd.k][cd.m][cd.n] ^= 1 }
                                    else { jpg.mcus![cd.y][cd.x].blocks[cd.k][cd.m][cd.n] += ((iTemp & 1) == 1 ? 1 : -1) }
                                }
                                    
                                codeIndex = 0
                            }
                        }
                    }
                }
            }
        }
    }
    
    return false
}



typealias typeExtract = (bool: Bool, string: String, data: Data)

func F5Extract(StegoMedia jpg: JPG, TotalBits TB: Int, ParityBitCoverage PBC: Int) -> typeExtract {
    //  萃取訊息
    var dtExtractText: Data = Data()
    //  總萃取訊息長度 (unit: byte)
    var uiExtractLength: UInt = 0
    var iExtractLengthBits: Int = 1
    
    var codeIndex: Int = 0
    var codeDatas: [typeLocation] = [typeLocation](repeating: typeLocation(0, 0, 0, 0, 0), count: 1 + TB)
    var parityBits: [Int] = [Int](repeating: 0, count: PBC)
    
    var uiData: UInt8 = 0
    var iBits: Int = 8
    
    var iTemp: Int = 0
    
    //*
    jpg.quantizationTables[0].SortPriorityAC()
    jpg.quantizationTables[1].SortPriorityAC()
    //*/
   
    for py in 0...62 {
        //  [亮度AC優先位置, 彩度AC優先位置]
        let n: [Int] = [jpg.quantizationTables[0].PriorityTable[py].iIndex, jpg.quantizationTables[1].PriorityTable[py].iIndex]
        for y in 0..<jpg.iMCUY {
            for x in 0..<jpg.iMCUX {
                for k in 0..<jpg.frameComponents.count {
                    for i in 0..<jpg.frameComponents[k].uiVi! {
                        for j in 0..<jpg.frameComponents[k].uiHi! {
                            let c: Int = Int(k == 0 ? 0 : 1)
                            let m: Int = Int(i * jpg.frameComponents[k].uiHi! + j)
                            
                            if (abs(jpg.mcus![y][x].blocks[k][m][n[c]]) <= 1) { continue }
                            
                            codeIndex += 1
                            codeDatas[codeIndex] = (y, x, k, m, n[c])
                            iTemp = jpg.mcus![y][x].blocks[k][m][n[c]]
                            for p in 0..<PBC {
                                if (((codeIndex >> p) & 1) == 1) {
                                    parityBits[p] ^= ((iTemp < 0 ? iTemp ^ 1 : iTemp) & 1)
                                }
                            }
                            
                            
                            if (codeIndex == TB) {
                                var p: Int = 0
                                while (iExtractLengthBits <= 32 && p < PBC) {
                                    uiExtractLength = (uiExtractLength << 1) | UInt(parityBits[p])
                                    iExtractLengthBits += 1
                                    
                                    if (iExtractLengthBits > 32) {
                                        print("總萃取訊息長度: \(uiExtractLength) bytes")
                                        if (iExtractLengthBits > jpg.uiMAXCapacity) { return (false, "萃取內容長度編碼有問題!", Data()) }
                                    }
                                    
                                    p += 1
                                }
                                
                                while (p < PBC) {
                                    if (iBits == 0) {
                                        dtExtractText.append(uiData)
                                        if (4 + dtExtractText.count == uiExtractLength) {
                                            print("End of extracting!")
                                            return (true, String(decoding: dtExtractText, as: UTF8.self), dtExtractText)
                                        }
                                        uiData = 0
                                        iBits = 8
                                    }
                                    
                                    uiData = (uiData << 1) | UInt8(parityBits[p])
                                    iBits -= 1
                                    p += 1
                                }
                                
                                codeIndex = 0
                                parityBits = [Int](repeating: 0, count: PBC)
                            }
                        }
                    }
                }
            }
        }
    }
    
    return (false, "Error!", Data())
}
