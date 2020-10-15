//
//  ContentView.swift
//  JPG
//
//  Created by 鄭子輿 on 2020/7/29.
//  Copyright © 2020 MCU. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State var stext: String = ""
    @State var sEmbedKey: String = ""
    @State private var showSheet: Bool = false
    @State private var showImagePicker: Bool = false
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary

    @State private var image : UIImage?

    var body: some View {
        NavigationView {
            ZStack{
                VStack {
                    Text("")
                        .navigationBarItems( trailing:
                                                NavigationLink(destination: SettingView()){
                                                    Image(systemName: "gearshape")
                                                        .resizable()
                                                        .scaledToFit()
                                                        .foregroundColor(.black)
                                                        .frame(width: 40, height: 40, alignment: .center)
                                                })
                    VStack{
                        HStack{
                            Text("嵌入")
                                .bold()
                                .font(.system(size: 30))
                            Spacer()
                        }
                        HStack{
                            Button(action: {self.showSheet = true}) {
                                Text("請選擇嵌入圖片")
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
                        TextField("請輸入嵌入密文", text: $stext).textFieldStyle(RoundedBorderTextFieldStyle())
                        HStack{
                            TextField("請輸入4-8碼嵌入金鑰", text: $sEmbedKey).textFieldStyle(RoundedBorderTextFieldStyle())
                            Button(action: {/*Image(uiImage: UIImage(data : getData())!).resizable()*/}) {
                                Text("嵌入")
                                    .frame(width: 50, height: 32, alignment: .center)
                                    .background(Color.gray)
                                    .foregroundColor(.white)
                                    .cornerRadius(5)
                            }
                        }
                        HStack{
                            Image(uiImage: (image ?? UIImage(named: "Original.jpg"))!)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 240, height: 180)
                                .clipShape(RoundedRectangle( cornerRadius: 5 ))
                            
                            Button(action: {/*saveImage(data: getData())*/}) {
                                Image(systemName:"square.and.arrow.down")
                                    .resizable()
                                    .scaledToFit()
                                    
                            }.frame(width: 25, height: 25 ,alignment: .leading)

                        }
                    }
                    Spacer()
                    VStack{
                        HStack{
                            Text("萃取")
                                .bold()
                                .font(.system(size: 30))
                            Spacer()
                        }
                        HStack{
                            Button(action: {self.showSheet = true}) {
                                Text("請選擇萃取圖片")
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
                        HStack{
                            TextField("請輸入嵌入金鑰", text: $sEmbedKey).textFieldStyle(RoundedBorderTextFieldStyle())
                            Spacer()
                            Button(action: {}) {
                                Text("萃取")
                                    .frame(width: 50, height: 32, alignment: .center)
                                    .background(Color.gray)
                                    .foregroundColor(.white)
                                    .cornerRadius(5)
                            }
                        }
                    }
                    
                    
                    //Button(action: {saveImage(data: Read( sEmbedText : &self.text ))}) {
                    //Text("Open Image")
                    //}
                    Spacer()
                        .frame( height:UIScreen.main.bounds.size.height / 3)
                    
                }.padding(.leading,30)
                .padding(.trailing,30)
                //.frame( height: UIScreen.main.bounds.size.height )
            }.sheet(isPresented : $showImagePicker){
                ImagePicker(image: self.$image, isShown: self.$showImagePicker, sourceType: self.sourceType)
            }
        }
    }
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
        }
    }
}
