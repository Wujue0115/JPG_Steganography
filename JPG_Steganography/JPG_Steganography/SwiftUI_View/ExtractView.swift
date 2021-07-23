//
//  ExtractView.swift
//  JPG_Steganography
//
//  Created by 翁明緯 on 2020/10/14.
//  Copyright © 2020 MCU. All rights reserved.
//

import SwiftUI

struct ExtractView: View { //0
    @State var stext: String = ""
    @State var sExtractText: String = ""
    @State var sEmbedKey: String = ""
    @State private var showSheet: Bool = false
    @State private var showImagePicker: Bool = false
    @State private var imageURL: URL?
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    
    @State private var image : UIImage?
    
    @State private var jpg: JPG?
    static let imageURL: UIImagePickerController = UIImagePickerController()
    
    @State private var isEditing = false
    
    var body: some View { //1
        // NavigationView { //2
        VStack{ //3
            HStack{
                Text("Extract")
                    .bold()
                    .font(.system(size: 30))
                Spacer()
            }
            HStack{
                Button(action: {self.showSheet = true}) {
                    Text("Choose stego media")
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
            
            HStack{
                /*TextField("請輸入嵌入金鑰", text: $sEmbedKey).textFieldStyle(RoundedBorderTextFieldStyle())
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
                }*/
                Button(action: {
                    guard imageURL != nil else { return }
                    
                    jpg = JPG(urlJpgPath: imageURL!)
                    print(imageURL!)
                    let defaults = UserDefaults.standard
                    let iE = defaults.integer(forKey: "iEmbedMode")
                    jpg!.EmbedFormat = EmbedMode[iE]
                    // print("\(EmbedMode[iE].0), \(EmbedMode[iE].1)")
                    //jpg!.SetEmbedFormat(UnitBits: 7, EmbedBits: 3)
                    if(boolRSAEncryption == true){
                        sExtractText = jpg!.RSAExtract()

                    }else{
                        sExtractText = jpg!.Extract()
                    }
                                        
                    if (jpg!.bExtract) {
                        print("萃取訊息: "+sExtractText)
                    }
                    else {
                        print("萃取失敗: "+sExtractText)
                    }
                    
                }) {
                    VStack{
                        Text("Extract")
                            .fontWeight(.bold)
                            .frame(width: 180, height: 32, alignment: .center)

                    }
                    .frame(width: 100, height: 45)
                    
                    .background(Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(30)
                    .shadow(radius: 5.0)
                }
                
            }
            if(sExtractText != ""){
                ScrollView{
                    Text("Ciphertext : \(sExtractText)")
                        .bold()
                        .font(.system(size:25))
                        .fixedSize(horizontal: false, vertical: true)
                }

            }
            Spacer()
        } //3
        .onAppear() {
            boolRSAEncryption = LoadRSAEncryption()
            iEmbedMode = LoadEmbedMode()
            if(!bPrivateKey){
                creatRSAprivatekey()
            }
        }
        .padding(30)
        .sheet(isPresented : $showImagePicker){
            ImagePicker(image: self.$image, isShown: self.$showImagePicker, imageURL: self.$imageURL, sourceType: self.sourceType)}
        //   }//2
    }//1
}//0

struct ExtractView_Previews: PreviewProvider {
    static var previews: some View {
        ExtractView()
    }
}
