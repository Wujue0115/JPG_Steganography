//
//  JPG.swift
//  JPG_Steganography
//
//  Created by 鄭子輿 on 2020/8/14.
//  Copyright © 2020 MCU. All rights reserved.
//

/*
 ------------------------------
 JPG Class Instructions
 ------------------------------
 [Creating a JPG]
 
     init()
        創建一個空JPG物件
 
     init(urlJpgPath: URL)
        創建一個JPG物件，並讀取urlJpgPath的jpg影像資料
        => urlJpgPath: jpg影像於電腦中的絕對路徑
 
     init(sJpgPath: String)
        創建一個JPG物件，並讀取sJpgPath的jpg影像資料
        => sJpgPath: jpg影像於電腦中的絕對路徑字串
 
     init(dtJPGData: Data)
        創建一個JPG物件，並讀取dtJPGData的jpg影像資料
        => dtJPGData: jpg影像資料
 
 ------------------------------
 [Inspecting a JPG]
 
     var bExist: Bool
        JPG是否有影像資料存在

     var bEmbed: Bool
        JPG是否嵌入資料
 
     var bEncode: Bool
        JPG是否重新編碼

     var bExtract: Bool
        JPG是否萃取資料
 
 ------------------------------
 [Setting embed format]
 
     func SetEmbedFormat(UnitBits: Int, EmbedBits: Int)
        設定JPG嵌入格式(F5演算法嵌入格式)
        => UnitBits: 最小嵌入單位(bits)
        => EmbedBits: 每個嵌入單位可以嵌入多少訊息(bits)

 ------------------------------
 [Getting jpg encode]
     
     func GetEncodeData() -> Data
        取得JPG重新編碼資料
 
 ------------------------------
 [Embedding a message in JPG]
 
     func Embed(sEmbedText: String) -> Bool
        將sEmbedText嵌入至JPG中
        => sEmbedText: 使用者想嵌入的訊息資料
 
     func RSAEmbed(sEmbedText: String) -> Bool
        將sEmbedText進行RSA加密後嵌入至JPG中
        => sEmbedText: 使用者想嵌入的訊息資料
 
 ------------------------------
 [Extracting a message from JPG]
   
     func Extract() -> String
       萃取JPG中的機密訊息
 
     func RSAExtract() -> String
       萃取JPG中的機密訊息並進行RSA解密
 
 ------------------------------
 [Encoding JPG]
 
     var dtEncode: Data
        JPG重新編碼後的資料(嵌入後使用)
 
     func Encode()
        將JPG重新編碼
 
     func GetEncodeData() -> Data
        回傳JPG重新編碼後的資料(嵌入後使用)
 
 ------------------------------
 [Showing JPG information]
 
 
*/

import Foundation

class JPG {
    //  影像路徑
    var sJpgPath: String = ""
    //  影像資料
    var dtData: Data?
    //  dtData讀取位置
    var iIndex: Int = 0
    
    //  影像高度
    var iImageY: Int = 0
    //  影像寬度
    var iImageX: Int = 0
    
    //  影像垂直最大取樣
    var iVMax: Int = 0
    //  影像水平最大取樣
    var iHMax: Int = 0
    
    //  MCU垂直數量
    var iMCUY: Int = 0
    //  MCU水平數量
    var iMCUX: Int = 0
    
    var uiData: UInt8 = 0
    var iBits: Int = 0
    
    let iZeroLowerBound: [Int] = [0, -1, -3, -7, -15, -31, -63, -127, -255, -511, -1023, -2047, -4095]
    
    //  iOS Line 壓縮量化表
    var DQTOfiOSLine: [[[UInt16]]] = [
        [
            [ 2,  2,  2,  2,  2,  2,  4,  2],
            [ 2,  4,  6,  4,  4,  4,  6,  8],
            [ 6,  6,  6,  6,  8, 10,  8,  8],
            [ 8,  8,  8, 10, 12, 10, 10, 10],
            [10, 10, 10, 12, 12, 12, 12, 12],
            [12, 12, 12, 14, 14, 14, 14, 14],
            [14, 16, 16, 16, 16, 16, 18, 18],
            [18, 18, 18, 18, 18, 18, 18, 18]
        ],
        [
            [ 3,  3,  3,  5,  4,  5,  8,  4],
            [ 4,  8, 19, 13, 11, 13, 19, 19],
            [19, 19, 19, 19, 19, 19, 19, 19],
            [19, 19, 19, 19, 19, 19, 19, 19],
            [19, 19, 19, 19, 19, 19, 19, 19],
            [19, 19, 19, 19, 19, 19, 19, 19],
            [19, 19, 19, 19, 19, 19, 19, 19],
            [19, 19, 19, 19, 19, 19, 19, 19]
        ]
    ]
    
    
    var frameComponents: [FrameComponent] = [FrameComponent]()
    var scanComponents: [ScanComponent] = [ScanComponent]()
    var quantizationTables: [QuantizationTable] = [QuantizationTable](repeating: QuantizationTable(), count: 2)
    var huffmans: [[Huffman]] = [[Huffman]](repeating: [Huffman](repeating: Huffman(), count: 2), count: 2)
    var mcus: [[MCU]]?
    
    var jpg_header: JPG_HEADER?
    var dqt: DQT?
    var dht: DHT?
    var dri: DRI?
    var sof0: SOF0?
    var sos: SOS?
    
    /*
    var sPlaintext: String = ""
    var sCiphertext: String = ""
    */
    
    //  最大可嵌入容量 (unit: byte)
    var uiMAXCapacity: UInt = 0
    
    
    //  jpg影像是否存在
    var bExist: Bool = false
    //  jpg影像是否已嵌入資料
    var bEmbed: Bool = false
    //  jpg影像是否已編碼
    var bEncode: Bool = false
    //  jpg影像是否已萃取資料
    var bExtract: Bool = false

    
    
    var EmbedFormat: (TotalBits: Int, ParityBitCoverage: Int) = (7, 3)
    //  (StegoMedia, sEmbedText, TotalBits, ParityBitCoverage)
    let funcF5Embed: (JPG, String, Int, Int) -> Bool = F5Embed
    //  (StegoMedia, dtRSAEmbedText, TotalBits, ParityBitCoverage)
    let funcF5RSAEmbed: (JPG, Data, Int, Int) -> Bool = F5RSAEmbed
    //  (StegoMedia, TotalBits, ParityBitCoverage)
    let funcF5Extract: (JPG, Int, Int) -> typeExtract = F5Extract
    
    //  jpg影像編碼資料
    var dtEncode: Data = Data()
    
    init(){}
    
    init(urlJpgPath: URL){
        dtData = try? Data(contentsOf: urlJpgPath)
        if (dtData == nil) {
            print("dtData is nil!")
            return
        }
        
        jpg_header = JPG_HEADER(dtData: dtData!, iIndex: iIndex)
        
        if (jpg_header?.sMarker != "FFD8") {
            print("It is not a JPG Image!")
            return
        }
        
        iIndex += 2
        jpg_header = JPG_HEADER(dtData: dtData!, iIndex: iIndex)
        while (iIndex < dtData!.count) {
            switch jpg_header!.sMarker {
                case "FFC1", "FFC2", "FFC3", "FFC5", "FFC6", "FFC7", "FFC8",
                     "FFC9", "FFCA", "FFCB", "FFCC", "FFCD", "FFCE", "FFCF":
                    print("Sorry we don't support this kind of JPG!")
                    return
                case "FFDB": dqt  = DQT(jpg: self)
                case "FFC4": dht  = DHT(jpg: self)
                case "FFDD": dri  = DRI(jpg: self)
                case "FFC0": sof0 = SOF0(jpg: self)
                case "FFDA": sos  = SOS(jpg: self)
                default: iIndex += jpg_header!.getLength()
            }
            jpg_header = JPG_HEADER(dtData: dtData!, iIndex: iIndex)
        }
        
        // dqt!.Print(jpg: self)
        // dht!.Print(jpg: self)
        // dri!.Print()
        // sof0!.Print(jpg: self)
        // sos!.Print(jpg: self)
        // sos!.PrintMCU(jpg: self)
        
        bExist = true
        
        print("End of reading JPG Image!")
        print("=============================================")
    }
    
    init(sJpgPath: String){
        dtData = try? Data(contentsOf: URL(fileURLWithPath: sJpgPath))
        
        if (dtData == nil) {
            print("dtData is nil!")
            return
        }
        
        jpg_header = JPG_HEADER(dtData: dtData!, iIndex: iIndex)
        
        if (jpg_header?.sMarker != "FFD8") {
            print("It is not a JPG Image!")
            return
        }
        
        iIndex += 2
        jpg_header = JPG_HEADER(dtData: dtData!, iIndex: iIndex)
        while (iIndex < dtData!.count) {
            switch jpg_header!.sMarker {
                case "FFC1", "FFC2", "FFC3", "FFC5", "FFC6", "FFC7", "FFC8",
                     "FFC9", "FFCA", "FFCB", "FFCC", "FFCD", "FFCE", "FFCF":
                    print("Sorry we don't support this kind of JPG!")
                    return
                case "FFDB": dqt  = DQT(jpg: self)
                case "FFC4": dht  = DHT(jpg: self)
                case "FFDD": dri  = DRI(jpg: self)
                case "FFC0": sof0 = SOF0(jpg: self)
                case "FFDA": sos  = SOS(jpg: self)
                default: iIndex += jpg_header!.getLength()
            }
            jpg_header = JPG_HEADER(dtData: dtData!, iIndex: iIndex)
        }
        
        // dqt!.Print(jpg: self)
        // dht!.Print(jpg: self)
        // dri!.Print()
        // sof0!.Print(jpg: self)
        // sos!.Print(jpg: self)
        // sos!.PrintMCU(jpg: self)
        
        bExist = true
        
        print("End of reading JPG Image!")
        print("=============================================")
    }
    
    init(dtJPGData: Data){
        dtData = dtJPGData
        if (dtData == nil) {
            print("dtData is nil!")
            return
        }
        
        jpg_header = JPG_HEADER(dtData: dtData!, iIndex: iIndex)
        
        if (jpg_header?.sMarker != "FFD8") {
            print("It is not a JPG Image!")
            return
        }
        
        iIndex += 2
        jpg_header = JPG_HEADER(dtData: dtData!, iIndex: iIndex)
        while (iIndex < dtData!.count) {
            switch jpg_header!.sMarker {
                case "FFC1", "FFC2", "FFC3", "FFC5", "FFC6", "FFC7", "FFC8",
                     "FFC9", "FFCA", "FFCB", "FFCC", "FFCD", "FFCE", "FFCF":
                    print("Sorry we don't support this kind of JPG!")
                    return
                case "FFDB": dqt  = DQT(jpg: self)
                case "FFC4": dht  = DHT(jpg: self)
                case "FFDD": dri  = DRI(jpg: self)
                case "FFC0": sof0 = SOF0(jpg: self)
                case "FFDA": sos  = SOS(jpg: self)
                default: iIndex += jpg_header!.getLength()
            }
            jpg_header = JPG_HEADER(dtData: dtData!, iIndex: iIndex)
        }
        
         //dqt!.Print(jpg: self)
         //dht!.Print(jpg: self)
         //dri!.Print()
         //sof0!.Print(jpg: self)
         //sos!.Print(jpg: self)
         //sos!.PrintMCU(jpg: self)
        
        bExist = true
        
        print("End of reading JPG Image!")
        print("=============================================")
    }
    
    
    func SetEmbedFormat(UnitBits: Int, EmbedBits: Int) {
        EmbedFormat = (UnitBits, EmbedBits)
    }
    
    func GetEncodeData() -> Data {
        if (bEncode == false) { self.Encode() }
        return dtEncode
    }
    
    func Embed(sEmbedText: String) -> Bool {
        if (bExist == false) { return false }
        
        bEmbed = funcF5Embed(self, sEmbedText, EmbedFormat.0, EmbedFormat.1)
        return bEmbed
    }
    
    func Extract() -> String {
        let tExtract: typeExtract = funcF5Extract(self, EmbedFormat.0, EmbedFormat.1)
        bExtract = tExtract.bool
        return tExtract.string
    }
    
    func RSAEmbed(sEmbedText: String) -> Bool {
        
        if (bExist == false) { return false }
        
        let iBlockLen: Int = 126
        let dtEmbedText: Data = sEmbedText.data(using:.utf8)!
        var dtEmbedTextBlock: Data = Data()
        var dtRSAEmbedText: Data = Data()
        
        for i in stride(from: 0, to: dtEmbedText.count, by: iBlockLen) {
            // print("i: \(i)")
            if i + iBlockLen - 1 < dtEmbedText.count {
                dtEmbedTextBlock = dtEmbedText[i...(i+iBlockLen-1)]
            } else {
                dtEmbedTextBlock = dtEmbedText[i..<dtEmbedText.count]
            }
            
            if (bPrivateKey && bPublicKey) {
                guard Encrypted(dtData : dtEmbedTextBlock) else { return false }
                dtRSAEmbedText.append(EncryptedData!)
            }
        }
        
        bEmbed = funcF5RSAEmbed(self, dtRSAEmbedText, EmbedFormat.0, EmbedFormat.1)
        return bEmbed
        
        /*
        if (bExist == false) { return false }
        
        let dtEmbedText: Data = sEmbedText.data(using:.utf8)!
        print("Embed Text Length: \(dtEmbedText.count)")
        if (bPrivateKey) {
            if (bPublicKey) {
                guard Encrypted(dtData : dtEmbedText) else { return false }
            }
        }
        bEmbed = funcF5RSAEmbed(self, EncryptedData!, EmbedFormat.0, EmbedFormat.1)
        return bEmbed
        */
    }
    
    func RSAExtract() -> String {
        let tExtract: typeExtract = funcF5Extract(self, EmbedFormat.0, EmbedFormat.1)
        bExtract = tExtract.bool
        
        guard bExtract == true else { return "" }
        
        let iBlockLen: Int = 256
        let dtRSAExtractText: Data = tExtract.data
        var dtRSAExtractTextBlock: Data = Data()
        var sExtractText: String = String()
        
        for i in stride(from: 0, to: dtRSAExtractText.count, by: iBlockLen) {
            // print("i: \(i)")
            if i + iBlockLen - 1 < dtRSAExtractText.count {
                dtRSAExtractTextBlock = dtRSAExtractText[i...(i+iBlockLen-1)]
            } else {
                dtRSAExtractTextBlock = dtRSAExtractText[i..<dtRSAExtractText.count]
            }
            
            if (bPrivateKey && bPublicKey) {
                guard Decrypted(dtData: dtRSAExtractTextBlock) else { return "" }
                sExtractText.append(String(data: DecryptedData!, encoding: .utf8)!)
            }
        }
        
        return sExtractText
        
        /*
        let tExtract: typeExtract = funcF5Extract(self, EmbedFormat.0, EmbedFormat.1)
        guard Decrypted(dtData: tExtract.data) else { return "" }
        bExtract = tExtract.bool
        return (bExtract ? String(data: DecryptedData!, encoding: .utf8)! : tExtract.string)
        */
    }
    
    func Encode() {
        dtEncode = Data()
        var jpg_header: JPG_HEADER = JPG_HEADER()
        
        var iEndIndex: Int = 0
        
        iIndex = 0
        jpg_header = JPG_HEADER(dtData: dtData!, iIndex: iIndex)
        dtEncode.append(0xFF)
        dtEncode.append(0xD8)
        iIndex += 2
        repeat {
            jpg_header = JPG_HEADER(dtData: dtData!, iIndex: iIndex)
            iEndIndex = iIndex + jpg_header.getLength()
            switch jpg_header.sMarker {
                case "FFDA":
                    dtEncode.append(sos!.Encode(jpg: self))
                    dtEncode.append(0xFF)
                    dtEncode.append(0xD9)
                    
                    bEncode = true
                    return
                default:
                    dtEncode.append(dtData![iIndex..<iEndIndex])
                    iIndex += jpg_header.getLength()
            }
        } while ( true )
    }
}
