//
//  RSA.swift
//  JPG_Steganography
//
//  Created by 翁明緯 on 2020/9/1.
//  Copyright © 2020 MCU. All rights reserved.
//

import Foundation

var Error: Unmanaged<CFError>?
var tag: String = "RSA private key"
let attributes: [String : Any] = [kSecAttrKeyType as String: kSecAttrKeyTypeRSA, kSecAttrKeySizeInBits as String: 2048, kSecPrivateKeyAttrs as String: [kSecAttrIsPermanent as String: false, kSecAttrLabel as String: tag]]
var privateKey: SecKey?
var publicKey: SecKey?
let algorithm: SecKeyAlgorithm = .rsaEncryptionOAEPSHA512
var EncryptedData: Data?
var DecryptedData: Data?

func creatRSAprivatekey() -> Bool{
    privateKey=SecKeyCreateRandomKey(attributes as CFDictionary, &Error)
    if (privateKey != nil) { return true }
    print("私密金鑰產生失敗")
    return false
}

func creatpublicKey() -> Bool{
    publicKey = SecKeyCopyPublicKey(privateKey!)
    if (publicKey != nil) { return true }
    print("公開金鑰產生失敗")
    return false
}

func Encrypted(dtData: Data) -> Bool {
    EncryptedData = SecKeyCreateEncryptedData(publicKey!, algorithm, dtData as CFData, &Error) as Data?
    if (EncryptedData != nil){ return true }
    print("加密失敗")
    return false
}

func Decrypted(dtData: Data) -> Bool {
    DecryptedData = SecKeyCreateDecryptedData( privateKey!, algorithm, dtData as CFData, &Error) as Data?
    if (DecryptedData != nil) { return true }
    print("解密失敗")
    return false
}
