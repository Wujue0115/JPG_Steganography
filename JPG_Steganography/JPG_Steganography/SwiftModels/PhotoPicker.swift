//
//  Photo.swift
//  JPG_Steganography
//
//  Created by 翁明緯 on 2020/10/15.
//  Copyright © 2020 MCU. All rights reserved.
//

import Foundation
import Photos
import ImageIO

class SteganographyAlbum: NSObject {
  static let albumName = "Steganography Album"
  static let shared = SteganographyAlbum()

  private var assetCollection: PHAssetCollection!

  private override init() {
    super.init()

    if let assetCollection = fetchAssetCollectionForAlbum() {
      self.assetCollection = assetCollection
      return
    }
  }

  private func checkAuthorizationWithHandler(completion: @escaping ((_ success: Bool) -> Void)) {
    if PHPhotoLibrary.authorizationStatus() == .notDetermined {
      PHPhotoLibrary.requestAuthorization({ (status) in
        self.checkAuthorizationWithHandler(completion: completion)
      })
    }
    else if PHPhotoLibrary.authorizationStatus() == .authorized {
      self.createAlbumIfNeeded { (success) in
        if success {
          completion(true)
        } else {
          completion(false)
        }

      }

    }
    else {
      completion(false)
    }
  }

  private func createAlbumIfNeeded(completion: @escaping ((_ success: Bool) -> Void)) {
    if let assetCollection = fetchAssetCollectionForAlbum() {
      // Album already exists
      self.assetCollection = assetCollection
      completion(true)
    } else {
      PHPhotoLibrary.shared().performChanges({
        PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: SteganographyAlbum.albumName)   // create an asset collection with the album name
      }) { success, error in
        if success {
          self.assetCollection = self.fetchAssetCollectionForAlbum()
          completion(true)
        } else {
          // Unable to create album
          completion(false)
        }
      }
    }
  }

  private func fetchAssetCollectionForAlbum() -> PHAssetCollection? {
    let fetchOptions = PHFetchOptions()
    fetchOptions.predicate = NSPredicate(format: "title = %@", SteganographyAlbum.albumName)
    let collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)

    if let _: AnyObject = collection.firstObject {
      return collection.firstObject
    }
    return nil
  }
/*
  func save(image:  UIImage) {
    self.checkAuthorizationWithHandler { (success) in
      if success, self.assetCollection != nil {
        PHPhotoLibrary.shared().performChanges({
          let assetChangeRequest = PHAssetChangeRequest.creationRequestForAsset(from: <#T##UIImage#>)
          let assetPlaceHolder = assetChangeRequest.placeholderForCreatedAsset
          if let albumChangeRequest = PHAssetCollectionChangeRequest(for: self.assetCollection) {
            let enumeration: NSArray = [assetPlaceHolder!]
            albumChangeRequest.addAssets(enumeration)
          }

        }, completionHandler: { (success, error) in
          if success {
            print("Successfully saved image to Camera Roll.")
          } else {
            print("Error writing to image library: \(error!.localizedDescription)")
          }
        })

      }
    }
  }
*/
  func saveToLibrary(url: URL) {

    self.checkAuthorizationWithHandler { (success) in
      if success, self.assetCollection != nil {

        PHPhotoLibrary.shared().performChanges({
          if let assetChangeRequest = PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: url) {
            let assetPlaceHolder = assetChangeRequest.placeholderForCreatedAsset
            if let albumChangeRequest = PHAssetCollectionChangeRequest(for: self.assetCollection) {
              let enumeration: NSArray = [assetPlaceHolder!]
              albumChangeRequest.addAssets(enumeration)
            }

          }

        }, completionHandler:  { (success, error) in
          if success {
            print("Successfully saved to Camera Roll.")
          } else {
            print("Error writing to library: \(error!.localizedDescription)")
          }
        })


      }
    }

  }
}
