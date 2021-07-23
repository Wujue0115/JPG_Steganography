//
//  Read.swift
//  JPG_Steganography
//
//  Created by 鄭子輿 on 2020/7/29.
//  Copyright © 2020 MCU. All rights reserved.
//

import Foundation

class DHT {
    //  (2bytes) Define Huffman table marker (DHT開頭編號) (FFC4)
    var sMarker: String?
    //  (2bytes) Huffman table definition length (不包含sMarker的DHT長度)
    var uiLength: UInt16?
    //  (4bits)  Table class (霍夫曼表類型) (0: DC直流, 1: AC交流)
    //  0 = DC table or lossless table, 1 = AC table
    var uiTc: UInt8?
    //  (4bits)  Huffman table destination identifier (霍夫曼表ID)
    var uiTh: UInt8?
    
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
            // 取得前4bits
            uiTc = jpg.dtData![jpg.iIndex]>>4
            // 取得後4bits
            uiTh = (jpg.dtData![jpg.iIndex]<<4)>>4
            jpg.iIndex += 1
            
            jpg.huffmans[Int(uiTc!)][Int(uiTh!)] = Huffman(jpg: jpg)
        }
    }
    
    func Print(jpg: JPG){
        print("=============================================DHT")
        print("DHT_StartIndex : \(iStartIndex!)")
        print("DHT_Marker     : \(sMarker!)")
        print("DHT_Length     : \(uiLength!)")
        
        for tc in 0...1 {
            for th in 0...1 {
                print("----------------DHT----------------")
                print("DHT_Tc         : \(tc)")
                print("DHT_Th         : \(th)")
                jpg.huffmans[tc][th].Print()
            }
        }
        
        print()
        print("DHT_EndIndex    : \(iEndIndex!)")
        print()
        print()
    }
}


class Huffman {
    //  (16bytes) Number of Huffman codes of length i (不同深度的節點數量)
    var Li: [UInt8] = [UInt8](repeating: UInt8(), count: 17)
    //  (不同深度節點數量總和 * 1byte) Value associated with each Huffman code (霍夫曼編碼內容)
    var Vij: [UInt8] = [UInt8]()
    //  霍夫曼樹根節點
    var huffmanTreeRoot: HuffmanTree = HuffmanTree()
    
    //  霍夫曼表
    var huffmanTable: [(String, UInt8)] = [(String, UInt8)]()
    var reHuffmanTable: [String] = [String](repeating: "", count: 256)
    
    init(){}
    
    init(jpg: JPG){
        var iLeafCounts = 0
        for i in 1...16 {
            Li[i] = jpg.dtData![jpg.iIndex]
            iLeafCounts += Int(jpg.dtData![jpg.iIndex])
            jpg.iIndex += 1
        }
        
        for _ in 0..<iLeafCounts {
            Vij.append(jpg.dtData![jpg.iIndex])
            jpg.iIndex += 1
        }
        
        var sNode = "", iLeafIndex = 0
        for i in 1...16 {
            sNode = sNode.appendZero()
            if (Li[i] != 0) {
                for _ in 0..<Li[i] {
                    huffmanTreeRoot.AddNode(sPath: sNode, uiVal: Vij[iLeafIndex])
                    
                    huffmanTable.append((sNode, Vij[iLeafIndex]))
                    reHuffmanTable[Int(Vij[iLeafIndex])] = sNode
                    
                    // print(Int(Vij[iLeafIndex]),terminator: "")
                    // print(": "+sNode)
                    
                    sNode = sNode.addOne()
                    iLeafIndex += 1
                }
            }
        }
    }
    
    func Print() {
        /*
        for i in 1...16 {
            print(String(format: " %3d", Li[i]), terminator:"")
        }
        */
        huffmanTable.sort(by: { $0.0 < $1.0 })
        
        print("----------------------")
        for (bit, val) in huffmanTable {
            print(bit.setw(iSpace: 16, sFormat: "right", cFill: " ")+String(format: ": 0x%02X", val))
        }
    }
}


class HuffmanTree {
    var uiCategory: UInt8?
    var zeroChild: HuffmanTree?
    var oneChild: HuffmanTree?
    
    init(uiCategory: UInt8? = nil, zeroChild: HuffmanTree? = nil, oneChild: HuffmanTree? = nil){
        self.uiCategory = uiCategory
        self.zeroChild = zeroChild
        self.oneChild = oneChild
    }
    
    func AddNode(sPath: String, uiVal: UInt8){
        var node: HuffmanTree = self
        for s in sPath {
            if (s == "0") {
                if (node.zeroChild == nil) { node.zeroChild = HuffmanTree() }
                node = node.zeroChild!
            }
            else {
                if (node.oneChild == nil) { node.oneChild = HuffmanTree() }
                node = node.oneChild!
            }
        }
        
        node.uiCategory = uiVal
    }
}
