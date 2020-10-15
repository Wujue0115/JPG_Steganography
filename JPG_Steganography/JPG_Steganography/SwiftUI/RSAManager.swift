//
//  RSAManager.swift
//  JPG_Steganography
//
//  Created by 翁明緯 on 2020/9/27.
//  Copyright © 2020 MCU. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

struct Keycontent: Identifiable {
    var id = String()
    var sImageName = String()
    var sName = String()
    var sPublicKey = String()
    var sEmbedKey = String()
}

class ContentStore : ObservableObject{
    @Published var Keycontents = [Keycontent]()
}
