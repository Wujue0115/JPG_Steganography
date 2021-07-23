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
    
    @State private var isEditing = false
    
    var searchbar : some View{
        HStack{
            VStack{
                TextField("Enter a Name ", text:self.$sUserName, onCommit: {
                    UIApplication.shared.endEditing()
                }).overlay(
                    HStack {
                        Spacer()
                        if isEditing {
                            Button(action: {
                                self.sUserName = ""
                                
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
                TextField("Enter a Public Key ", text:self.$sNewKey, onCommit: {
                    UIApplication.shared.endEditing()
                }).overlay(
                    HStack {
                        Spacer()
                        if isEditing {
                            Button(action: {
                                self.sNewKey = ""
                                
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
                /*TextField("Enter a Embed Key ", text:self.$sNewEmbedKey)
                 .overlay(
                 HStack {
                 if isEditing {
                 Button(action: {
                 self.sNewKey = ""
                 
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
            }
            Button(action: self.addNewPublicKey , label:{
                Text("Add New Contact")
            })
        }
    }
    
    
    func addNewPublicKey(){
        /*
        contentstore.Keycontents.append(Keycontent( id: String( contentstore.Keycontents.count + 1),sName : sUserName, sPublicKey : sNewKey, sEmbedKey : sNewEmbedKey))
        */
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let contact: ContactsCoreData = ContactsCoreData(context: context)
        contact.Insert(insertContact: Contact(sName: sUserName,sPublicKey: sNewKey))
        
        self.sUserName = ""
        self.sNewKey = ""
        self.sNewEmbedKey = ""
    }
    
    // @State var contacts: [Contact] = []
    
    var body: some View {
        VStack(alignment: .leading ){
            searchbar.padding()
            List (/*self.contacts*/self.contentstore.Keycontents){ Keycontent in
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
                            //Text( "Embed Key: \(Keycontent.sEmbedKey)").font(.subheadline)
                        }
                    }
                })
            }
        }
        .navigationBarTitle("Contact Key Manager")
        .onAppear(){
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let contact: ContactsCoreData = ContactsCoreData(context: context)
            contact.Read()
            
            self.contentstore.Keycontents = []
            for i in 0..<contact.data.count {
                self.contentstore.Keycontents.append(Contact(id: i, sName: contact.data[i].sName, sPublicKey: contact.data[i].sPublicKey))
            }
            
            //self.contentstore.Keycontents = contact.data
        }
    }
}

struct RSAManagerView_Previews: PreviewProvider {
    static var previews: some View {
        RSAManagerView()
    }
}
