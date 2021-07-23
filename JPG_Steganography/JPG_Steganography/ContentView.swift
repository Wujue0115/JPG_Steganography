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
    @State private var imageURL: URL?
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @State private var image : UIImage?
    
    @State private var jpg: JPG?
    static let imageURL: UIImagePickerController = UIImagePickerController()
    
    var body: some View {
        NavigationView {
            VStack {
                TabView {
                    EmbedView()
                        .tabItem{
                            VStack{
                                Image(systemName: "dock.arrow.down.rectangle")
                                    .resizable()
                                    .scaledToFit()
                                Text("Embed")
                            }
                        }.tag(1)
                    ExtractView()
                        .tabItem {
                            VStack{
                                Image(systemName: "dock.arrow.up.rectangle")
                                    .resizable()
                                    .scaledToFit()
                                Text("Extract")
                            }
                        }.tag(2)
                }
            }
            .sheet(isPresented : $showImagePicker){
                ImagePicker(image: self.$image, isShown: self.$showImagePicker, imageURL: self.$imageURL, sourceType: self.sourceType)
            }
            .navigationBarItems( trailing:
                                    NavigationLink(destination: SettingView()){
                                            Image(systemName: "gearshape")
                                                .resizable()
                                                .scaledToFit()
                                                .foregroundColor(.black)
                                                .frame(width: 40, height: 40, alignment: .center)
                                    })
            .navigationBarTitle("", displayMode: .inline)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
        }
    }
}
