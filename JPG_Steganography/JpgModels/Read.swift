//
//  Read.swift
//  JPEG
//
//  Created by 鄭子輿 on 2020/7/29.
//  Copyright © 2020 MCU. All rights reserved.
//

import Foundation
import UIKit
import ImageIO

class JPEG_HEADER {
    var sMarker: String?
    var iLength: UInt16?
    
    init(data: Data, index: Int) {
        //guard index+2 < data.count else { return }
        sMarker = getMarkerHexString(data: data, index: index)
        guard index+4 < data.count else { iLength = 1; return }
        iLength = getUInt16(data: data, index: index+2)
    }
    
    func getLength() -> Int {
        guard iLength != nil else { return 2 }
        return 2+Int(iLength!)
    }
}

func Read() {
    // Do any additional setup after loading the view.
    // var image: UIImage?
    // "/Users/wujue/Desktop/BlackWhite.jpg"
    let jpgPath = "/Users/wujue/Desktop/專研/JPEG/JpegImage/Rex.jpg"
    var data: Data? = try? Data(contentsOf: URL(fileURLWithPath: jpgPath))
    
    var iIndex: Int = 0
    
    var jpeg_header: JPEG_HEADER
    // var app0: APP0
    var dqt: DQT
    var dht: DHT
    var sos: SOS
    
    /*
    for i in 0..<data!.count {
        print(String(i)+": "+String(format: "%0x", Int(data![i])))
    }
    */
    
    iIndex += 2
    jpeg_header = JPEG_HEADER(data: data!, index: iIndex)
    
    repeat {
        // print(jpeg_header.sMarker!+": "+String(jpeg_header.iLength!))
        switch jpeg_header.sMarker {
        /*
        case "FFE0": // APP0
            print("APP0_StartIndex: \(iIndex)")
            
            app0 = APP0(data: data!, index: iIndex)
            app0.Print()
            // iIndex = app0.getNewIndex()
            iIndex += jpeg_header.getLength()
            
            print("APP0_EndIndex: \(iIndex)")
            print("<------------------------------------>")
        */
        case "xFFDB": // DQT
            print("<------------------------------------>")
            print("DQT_StartIndex: \(iIndex)")
            
            dqt = DQT(data: data!, index: iIndex)
            dqt.Print()
            iIndex += jpeg_header.getLength()
            
            print("DQT_EndIndex: \(iIndex)")
            print("<------------------------------------>")
        
        case "FFC4": // DHT
            print("<------------------------------------>")
            print("DHT_StartIndex: \(iIndex)")
            
            dht = DHT(data: data!, index: iIndex)
            // huffman[Int(dht.iTc!)][Int(dht.iTh!)].Print()
            iIndex += jpeg_header.getLength()
            
            print("DHT_EndIndex: \(iIndex)")
            print("<------------------------------------>")
            
        case "FFDA": // SOS
            print("<------------------------------------>")
            print("SOS_StartIndex: \(iIndex)")
            
            sos = SOS(data: data!, index: iIndex)
            iIndex += jpeg_header.getLength()
            
            print("SOS_EndIndex: \(iIndex)")
            print("<------------------------------------>")
            
            return
        default:
            iIndex += jpeg_header.getLength()
        }
        
        jpeg_header = JPEG_HEADER(data: data!, index: iIndex)
        
    } while (iIndex < data!.count /* && jpeg_header.sMarker != "FFDA" */ ) // "FFD9"
    
    print("End")
}
