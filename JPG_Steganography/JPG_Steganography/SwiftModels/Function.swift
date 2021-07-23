//
//  Read.swift
//  JPG_Steganography
//
//  Created by 鄭子輿 on 2020/7/29.
//  Copyright © 2020 MCU. All rights reserved.
//

import Foundation
import UIKit
import ImageIO

// extension


extension Int {
    init(val: UInt16){ self = Int(Int16(bitPattern: val)) }
}

extension UInt8 {
    func getHexString() -> String {
        return String(format: "%0X", self)
    }
    
    func ToInt() -> Int {
        return Int(self)
    }
}

extension String {
    var length: Int { return count }
    
    subscript (i: Int) -> String { return self[i..<i+1] }
    
    subscript (r: Range<Int>) -> String {
        let range = Range(uncheckedBounds: (lower: max(0, min(length, r.lowerBound)),
                                            upper: min(length, max(0, r.upperBound))))
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(start, offsetBy: range.upperBound - range.lowerBound)
        return String(self[start..<end])
    }
    
    func appendZero() -> String { return self + "0" }
    
    func addOne() -> String {
        var s = "", i = self.count - 1
        while (i >= 0 && self[i] == "1") {
            i -= 1
            s += "0"
        }
        return self[0..<i] + "1" + s
    }
    
    func setw(iSpace: Int, sFormat: String, cFill: Character) -> String {
        if (self.count > iSpace) { return self }
        if (sFormat == "left") { return self + String(repeating: cFill, count: iSpace - self.count) }
        if (sFormat == "right") { return String(repeating: cFill, count: iSpace - self.count) + self }
        
        return self
    }
}

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// function

func getMarker(dtData: Data, iIndex: Int) -> String {
    guard iIndex + 1 <= dtData.count else { return "" }
    return String(dtData[iIndex].getHexString() + dtData[iIndex+1].getHexString())
}

func getMarkerLength(dtData: Data, iIndex: Int) -> UInt16 {
    return (UInt16(dtData[iIndex]) << 8) | UInt16(dtData[iIndex+1])
}

func getUInt8Array(dtData: Data, iIndex: Int, counts: Int) -> [UInt8] {
    var UInt8Array: [UInt8] = []
    for i in stride(from: iIndex, to: iIndex+counts, by: 1){
        UInt8Array.append(dtData[i])
    }
    return UInt8Array
}

func getUInt16Array(dtData: Data, iIndex: Int, counts: Int) -> [UInt16] {
    var UInt16Array: [UInt16] = []
    for i in stride(from: iIndex, to: iIndex+counts*2, by: 2){
        UInt16Array.append(getMarkerLength(dtData: dtData,iIndex: i))
    }
    return UInt16Array
}

func getNextBit(jpg: JPG) -> UInt8 {
    if(jpg.iBits == 0){
        jpg.uiData = jpg.dtData![jpg.iIndex]
        jpg.iIndex += (jpg.uiData == 0xFF ? 2 : 1)
        jpg.iBits = 8
    }
    jpg.iBits -= 1
    return (jpg.uiData >> jpg.iBits) & 1
}

func getNextBit(dtData: Data, iIndex: inout Int, uiData: inout UInt8, iBits: inout Int) -> Int {
    if(iBits == 0){
        if (iIndex == dtData.count) { return -1 }
        uiData = dtData[iIndex]
        iIndex += 1
        iBits = 8
    }
    iBits -= 1
    return Int((uiData >> iBits) & 1)
}

func unitEncode(dtEncode: inout Data, uiData: inout UInt8, iBits: inout Int, sEncode: String, iEncodeLen: Int, iEncodeValue: Int){
    for i in sEncode {
        uiData = (uiData << 1) | (i == "0" ? 0 : 1)
        iBits -= 1
        if (iBits == 0) {
            dtEncode.append(uiData)
            if (uiData == 0xFF) { dtEncode.append(0x00) }
            uiData = 0
            iBits = 8
        }
    }
    
    if (iEncodeLen == 0) { return }
    
    let iValue: Int = (iEncodeValue < 0 ? -iEncodeValue : iEncodeValue)
    for bit in stride(from: iEncodeLen - 1, through: 0, by: -1) {
        uiData = (uiData << 1) | UInt8((iEncodeValue < 0 ? ((iValue >> bit) & 1) ^ 1 : (iValue >> bit) & 1))
        iBits -= 1
        if (iBits == 0) {
            dtEncode.append(uiData)
            if (uiData == 0xFF) { dtEncode.append(0x00) }
            uiData = 0
            iBits = 8
        }
    }
}
func saveImageError(data : Data){
    let compresedImage = UIImage(data : data)
    UIImageWriteToSavedPhotosAlbum(compresedImage!, nil, nil, nil)
    print("Save successful")
    return
}
func saveImage(data : Data, url : URL, filename : String)->URL{
    var fileurl: URL
    do {
        if(filename != ""){
            fileurl = url.deletingPathExtension()
            fileurl = fileurl.deletingLastPathComponent()
            print(fileurl)
            fileurl = URL(string: (fileurl.absoluteString+filename))!
            print(fileurl)
            fileurl = fileurl.appendingPathExtension("jpg")
        }else{
            fileurl = url.deletingPathExtension()
            print(fileurl)
            let addfilename = Int.random(in: 0...10000)
            fileurl = URL(string: (fileurl.absoluteString+String(addfilename)))!
            print(fileurl)
            fileurl = fileurl.appendingPathExtension("jpg")
        }
            try data.write(to: fileurl)
            print(fileurl)
            print("Save successful")
            return fileurl
        } catch {
            print("Save Unsuccessful")
            return fileurl
        }
}

/*
var userRSAPrivateKey: SecKey?
var bPrivateKey: Bool = false
var userRSAPublicKey: SecKey?
var bPublicKey: Bool = false
var userEmbedKey: String = ""
var boolRSAEncryption : Bool = true

var EmbedMode: [[Int]] = [
    [15,4],
    [7,3],
    [3,2],
    [1,1]
]
*/

