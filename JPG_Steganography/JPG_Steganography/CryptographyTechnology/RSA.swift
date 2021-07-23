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
var sPrivateKey: String?
var sPublicKey: String?
let algorithm: SecKeyAlgorithm = .rsaEncryptionOAEPSHA512
var EncryptedData: Data?
var DecryptedData: Data?
var dtPrivateKey: Data?
var dtPublicKey: Data?

func creatRSAprivatekey(){
    privateKey = SecKeyCreateRandomKey(attributes as CFDictionary, &Error)
    if (privateKey != nil) {
        bPrivateKey = true
        if let cfdata = SecKeyCopyExternalRepresentation(privateKey!, nil) {
            dtPrivateKey = cfdata as Data
            sPrivateKey = dtPrivateKey!.base64EncodedString()
        }
        creatpublicKey()
        return
    }
    print("私密金鑰產生失敗")
    bPrivateKey = false
    return
}

func creatpublicKey(){
    publicKey = SecKeyCopyPublicKey(privateKey!)
    print("Key : \(String(describing: publicKey))")
    if (publicKey != nil) {
        bPublicKey = true
        if let cfdata = SecKeyCopyExternalRepresentation(publicKey!, nil) {
            dtPublicKey = cfdata as Data
            sPublicKey = dtPublicKey!.base64EncodedString()
        }
        return
    }
    print("公開金鑰產生失敗")
    bPublicKey = true
    return
}

func Encrypted(dtData: Data) -> Bool {
    EncryptedData = SecKeyCreateEncryptedData(publicKey!, algorithm, dtData as CFData, &Error) as Data?
    if (EncryptedData != nil){ return true }
    print("加密失敗")
    return false
}

func Decrypted(dtData: Data) -> Bool {
    //let str = String(decoding: dtData, as: UTF8.self)
    //print( str )
    DecryptedData = SecKeyCreateDecryptedData(privateKey!, algorithm, dtData as CFData, &Error) as Data?
    if (DecryptedData != nil) { return true }
    print("解密失敗")
    return false
}

func buildKeyFromString_Public(string rsaKey:String) ->SecKey? {
    guard let data = Data(base64Encoded: rsaKey) else {return nil}
    
    let keyDict:[NSObject:NSObject] = [
        kSecAttrType : kSecAttrKeyTypeRSA,
        kSecAttrKeyClass : kSecAttrKeyClassPublic,
        kSecAttrKeySizeInBits: NSNumber(value: 2048),
        kSecReturnPersistentRef: true as NSObject
    ]
    
    return SecKeyCreateWithData(data as CFData, keyDict as CFDictionary, nil)
}

