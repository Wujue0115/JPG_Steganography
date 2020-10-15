//
//  SettingView.swift
//  JPG_Steganography
//
//  Created by 翁明緯 on 2020/9/27.
//  Copyright © 2020 MCU. All rights reserved.
//

import SwiftUI
import Combine

struct SettingView: View {
    
    @State var sUsername : String = ""
    @State private var bEncryption : Bool = true
    @State var bEmbedMode = 0
    var EmbedModeOptins = ["F5 高品質","F5 標準品質","F5 低品質","LSB 低品質"]
    
    var body: some View {
        Form{
            Section{
                NavigationLink(destination: UserView()){
                    HStack{
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        VStack(){
                            
                        }
                    }
                }
            }
            NavigationLink(destination: RSAManagerView()){
                Section{
                    HStack{
                        Image(systemName: "key.fill")
                            .frame(width: 30, height: 30)
                            .foregroundColor(.white)
                            .background(Color.gray)
                            .clipShape(RoundedRectangle( cornerRadius: 5 ))
                        Text("Contact Key")
                    }
                }
            }
            HStack{
                Image(systemName: "photo.fill")
                    .frame(width: 30, height: 30)
                    .foregroundColor(.white)
                    .background(Color.gray)
                    .clipShape(RoundedRectangle( cornerRadius: 5 ))
                Picker( selection: $bEmbedMode, label:Text("Embed Mode")){
                    Section{
                        ForEach(0..<EmbedModeOptins.count){ index in
                            Text("\(self.EmbedModeOptins[index])")
                        }
                        
                    }
                    
                }
                
            }
            
            HStack{
                Image(systemName: "lock.fill")
                    .frame(width: 30, height: 30)
                    .foregroundColor(.white)
                    .background(Color.gray)
                    .clipShape(RoundedRectangle( cornerRadius: 5 ))
                Toggle( isOn : $bEncryption, label: {
                    Text("Encryption")
                })
                
            }
            
            
        }
        .navigationBarTitle("Setting")
    }
}

struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        SettingView()
    }
}
