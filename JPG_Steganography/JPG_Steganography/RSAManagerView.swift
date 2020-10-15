//
//  RSAManagerView.swift
//  JPG_Steganography
//
//  Created by 翁明緯 on 2020/10/4.
//  Copyright © 2020 MCU. All rights reserved.
//

import SwiftUI

struct RSAManagerView: View {
    @ObservedObject var contentstore = ContentStore()
    @State var sUserName: String = ""
    @State var sNewKey : String = ""
    @State var sNewEmbedKey : String = ""
    
    
    
    var searchbar : some View{
        HStack{
            VStack{
                TextField("Enter a Name ", text:self.$sUserName)
                TextField("Enter a Public Key ", text:self.$sNewKey)
                TextField("Enter a Embed Key ", text:self.$sNewEmbedKey)
            }
            Button(action: self.addNewPublicKey , label:{
                Text("Add New Contact")
            })
        }
    }
    
    func addNewPublicKey(){
        contentstore.Keycontents.append(Keycontent( id: String( contentstore.Keycontents.count + 1),sName : sUserName, sPublicKey : sNewKey, sEmbedKey : sNewEmbedKey))
        self.sUserName = ""
        self.sNewKey = ""
        self.sNewEmbedKey = ""
    }
    
    var body: some View {
        
            VStack(alignment: .leading ){
                searchbar.padding()
                List (self.contentstore.Keycontents){ Keycontent in
                    Button(action:{print("Choose\(Keycontent.sName)")},label:{
                        HStack{
                            Image("User")
                                .resizable()
                                .clipShape(Circle())
                                .frame(width: 40,height: 40)
                                .clipped()
                            VStack(alignment: .leading){
                                Text( "Name: \(Keycontent.sName) ").font(.headline)
                                Text( "RSA Key: \(Keycontent.sPublicKey)").font(.subheadline)
                                Text( "Embed Key: \(Keycontent.sEmbedKey)").font(.subheadline)
                            }
                        }
                    })
                }

            }.navigationBarTitle("Contact Key Manager")
        
    }
}

struct RSAManagerView_Previews: PreviewProvider {
    static var previews: some View {
        RSAManagerView()
    }
}
