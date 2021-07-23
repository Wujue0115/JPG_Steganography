//
//  EmbedView.swift
//  JPG_Steganography
//
//  Created by 翁明緯 on 2020/10/14.
//  Copyright © 2020 MCU. All rights reserved.
//

import SwiftUI

struct EmbedView: View { // 0
    @State var stext: String = ""
    @State var filename: String = ""
    @State var height: CGFloat = 0
    @State var keyboardHeight: CGFloat = 0
    @State var sEmbedKey: String = ""
    @State private var showSheet: Bool = false
    @State private var showImagePicker: Bool = false
    @State private var imageURL: URL?
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @State var Capacity: UInt = 0
    @State private var image : UIImage?
    @State private var iSelectcontact: Int?
    @State var jpg: JPG?
    @State var boolisRSA: Bool?
    static let imageURL: UIImagePickerController = UIImagePickerController()
    
    @State private var isEditing = false
    
    @State private var isShareSheetShowing = false
    
    @State var sMAXCapacity: String = ""
    
    var body: some View { // 1
        //Form{
        VStack{ // 2
            HStack{
                Text("Embed")
                    .bold()
                    .font(.system(size: 30))
                Spacer()
            }
            if(boolisRSA == true){
                HStack{
                    Button(action: {}) {
                        Text("Choose contact")
                            .foregroundColor(.gray)
                            .bold()
                        Image(systemName: "person.2.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                }
            }
            HStack{
                Button(action: {self.showSheet = true}) {
                    Text("Choose cover media")
                        .foregroundColor(.gray)
                        .bold()
                    Image(systemName: "folder.fill.badge.plus")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                        .foregroundColor(.gray)
                }
                .actionSheet(isPresented : $showSheet ){
                    ActionSheet(title: Text("Select Photo"),message: Text("Choose"), buttons: [
                        .default(Text("Photo Library")){
                            //打開相簿
                            self.showImagePicker = true
                            self.sourceType = .photoLibrary
                            self.sMAXCapacity = ""
                        },
                        .cancel()
                    ])
                }
                .frame(width: 300, height: 50 ,alignment: .leading)
                Spacer()
            }
            Image(uiImage: (image ?? UIImage(named: "photo.png"))!)
                .resizable()
                .cornerRadius(15)
                .scaledToFit()
                .frame(width: 240, height: 180)
                // .frame(width: 480, height: 360)
                //.frame(width: 540, height: 405)
                .clipShape(RoundedRectangle( cornerRadius: 5 ))
            HStack {
                HStack {
                    Button(action: {
                        guard imageURL != nil else { return }
                        
                        let defaults = UserDefaults.standard
                        let iE = defaults.integer(forKey: "iEmbedMode")
                        jpg = JPG(urlJpgPath: imageURL!)
                        jpg!.EmbedFormat = EmbedMode[iE]
                        let uiMAXCapacity =
                            jpg!.uiMAXCapacity / UInt(jpg!.EmbedFormat.0) * UInt(jpg!.EmbedFormat.1) / 8 - 4
                        self.sMAXCapacity = String(uiMAXCapacity) + " bytes"
                    }) {
                        Text("Allow embedded capacity")
                            .fontWeight(.bold)
                    }
                    // .fixedSize()
                    .frame(width: 280, height: 45)
                    .background(Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(20)
                    .shadow(radius: 5.0)
                }
                // TextField("Name: \(sMAXCapacity) = ", text: $sMAXCapacity)
                Text("\(sMAXCapacity)")
                    //.bold()
                    .font(.system(size: 22))
            }
            TextField("Enter the embed plaintext", text: $stext, onCommit: {
                UIApplication.shared.endEditing()
            }).textFieldStyle(RoundedBorderTextFieldStyle())
            .overlay(
                HStack {
                    Spacer()
                    if isEditing {
                        Button(action: {
                            self.stext = ""
                            
                        }) {
                            Image(systemName: "multiply.circle.fill")
                                .foregroundColor(.gray)
                                .padding(.trailing, 8)
                        }
                    }
                }
            )
            .onTapGesture {
                self.isEditing = true
                UIApplication.shared.endEditing()
            }
            HStack{
                /*TextField("請輸入4-8碼嵌入金鑰", text: $sEmbedKey).textFieldStyle(RoundedBorderTextFieldStyle())
                 .overlay(
                 HStack {
                 if isEditing {
                 Button(action: {
                 self.stext = ""
                 
                 }) {
                 Image(systemName: "multiply.circle.fill")
                 .foregroundColor(.gray)
                 .padding(.trailing, 8)
                 }
                 }
                 }
                 )
                 .onTapGesture {
                 self.isEditing = true
                 }*/
                Button(action: {
                    //let sJpgPath: String = "/Users/dannymacbookpro/Google 雲端硬碟/專研/JPG_Steganography/JpgImage/Original.jpg"
                    let defaults = UserDefaults.standard
                    let iE = defaults.integer(forKey: "iEmbedMode")
                    //if(read)
                    guard imageURL != nil, stext != "" else { return }
                    // if (jpg!.bExist) {
                    jpg = JPG(urlJpgPath: imageURL!)
                    jpg!.EmbedFormat = EmbedMode[iE]
                    // }
                    // else {
                    if (boolRSAEncryption == true) {
                        if (jpg!.RSAEmbed(sEmbedText: stext) == false){
                            print("RSA Embed Error")
                        }
                    } else {
                        if (jpg!.Embed(sEmbedText: stext) == false){
                            print("Embed Error")
                        }
                    }
                    // }
                }) {
                    VStack{
                        Text("Embed")
                            .fontWeight(.bold)
                            .frame(width: 180, height: 32, alignment: .center)
                    }
                    .frame(width: 180, height: 45)
                    .background(Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(30)
                    .shadow(radius: 5.0)
                }
            }
            HStack{
                TextField("Enter the stego media name", text: $filename, onCommit: {
                    UIApplication.shared.endEditing()
                })
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .overlay(
                    HStack {
                        Spacer()
                        if isEditing {
                            Button(action: {
                                self.filename = ""
                                
                            }) {
                                Image(systemName: "multiply.circle.fill")
                                    .foregroundColor(.gray)
                                    .padding(.trailing, 8)
                            }
                        }
                    }
                )
                .onTapGesture {
                    self.isEditing = true
                    UIApplication.shared.endEditing()
                }
                
                Button(action: {
                    //image2 = UIImage(data: jpg!.GetEncodeData())
                    let imagedata = jpg!.GetEncodeData()
                    image=UIImage(data: imagedata)
                    SteganographyAlbum.shared.saveToLibrary(url: (saveImage(data: imagedata, url: imageURL!, filename: filename)))
                    
                }) {
                    Image(systemName:"square.and.arrow.down")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                    
                }.frame(width: 25, height: 25 ,alignment: .leading)
                /*
                 Button(action: {
                 shareButton(data: jpg!.GetEncodeData())
                 }) {
                 Image(systemName:"square.and.arrow.up")
                 .resizable()
                 .scaledToFit()
                 .frame(width: 40, height: 40)
                 
                 }.frame(width: 25, height: 25 ,alignment: .leading)
                 */
                
                
            }.padding(.leading,30)
            .padding(.trailing,30)
            .onTapGesture {
                UIApplication.shared.endEditing()
            }
            Spacer()
        } // 2
        .onAppear() {
            boolisRSA = LoadRSAEncryption()
            iEmbedMode = LoadEmbedMode()
            if(!bPrivateKey){
                creatRSAprivatekey()
            }
            self.sMAXCapacity = ""
        }
        .padding(30)
        .sheet(isPresented : $showImagePicker){
            ImagePicker(image: self.$image, isShown: self.$showImagePicker, imageURL: self.$imageURL, sourceType: self.sourceType)}
        
        
        //   }
        
    } // 1
    
} // 0

struct EmbedView_Previews: PreviewProvider {
    static var previews: some View {
        EmbedView()
    }
}
/*
 func shareButton(data : Data){
 let objectsToShare = [data]
 let activityController = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
 
 UIApplication.shared.windows.first?.rootViewController?.present(objectsToShare, animated: true, completion: nil)
 }
 */
