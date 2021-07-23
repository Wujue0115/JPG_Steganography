//
//  Embedder.swift
//  JPG_Steganography
//
//  Created by 鄭子輿 on 2020/7/29.
//  Copyright © 2020 MCU. All rights reserved.
//

import Foundation
import UIKit
import ImageIO

func Read() {
    // Do any additional setup after loading the view.
    
    // "/Users/wujue/Desktop/JpgImages/BlackWhite.jpg"
    //let sJpgPath: String = "/Users/wujue/Desktop/JpgImages/06.jpg"
    let sJpgPath: String = "/Users/dannymacbookpro/Desktop/NextJpeg2.jpg"
    print("Hi")
    //let jpg: JPG = JPG(sJpgPath: sJpgPath)
    
    // 000000000000000000000000000000000000000000000
    // 0123456789
    // abcdefghijklmnopqrstuvwxyz
    // ABCDEFGHIJKLMNOPQRSTUVWXYZ
    // ㄅㄆㄇㄈㄉㄊㄋㄌㄍㄎㄏㄐㄑㄒㄓㄔㄕㄖㄗㄘㄙㄧㄨㄩㄚㄛㄜㄝㄞㄟㄠㄡㄢㄣㄤㄥㄦ
    // 零壹貳參肆伍陸柒捌玖拾
    // 但願人長久，千里共蟬娟。
    // 禍兮福之所倚，福兮禍之所伏。
    // 💙 💚 💛 💜 💝
    // 🌍 🌎 🌏
    // 🌒 🌓 🌔 🌕 🌖 🌗 🌘 🌑
    // ♈ ♉ ♊ ♋ ♌ ♍ ♎ ♏ ♐ ♑ ♒ ♓
    // 🇹🇼 🇯🇵 🇰🇷 🇬🇧 🇺🇸
    // let _ = jpg.Encode()
    
    /*
    let sEmbedText: String = "禍兮福之所倚，福兮禍之所伏。"
    // (TotalBits, ParityBitCoverage)
    jpg.EmbedFormat = (15, 4)
    if (jpg.RSAEmbed(sEmbedText: sEmbedText) == true) {
        let sExtractText: String = jpg.RSAExtract()
        if (jpg.bExtract) {
            print("萃取訊息: "+sExtractText)
        }
        else {
            print("萃取失敗: "+sExtractText)
        }
    }
    else {
        print("嵌入失敗!")
    }*/
}

