//
//  UserView.swift
//  JPG_Steganography
//
//  Created by 翁明緯 on 2020/10/4.
//  Copyright © 2020 MCU. All rights reserved.
//

import SwiftUI

struct UserView: View {
    var body: some View {
        Form{
            Section{
                VStack{
                        Button(action:{creatRSAprivatekey()}){
                        Text("Creat New Private Key").font(.title)
                    }
                }
            }
            Section{
                VStack{
                    HStack{
                        Text("Public Key").font(.title)
                        Button(action: {
                        UIPasteboard.general.string = sPublicKey!
                    }) {
                            Image(systemName: "doc.on.doc.fill").frame(width: 50, height: 50)
                    }
                    }
                    Text(sPublicKey!)
                        .font(.system(size: 15, weight: .regular, design: .rounded))
            }
            }
        }.onAppear(){
            if(!bPrivateKey){
                creatRSAprivatekey()
            }
        }
        .navigationBarTitle("User Profile")
        
    }
}

struct UserView_Previews: PreviewProvider {
    static var previews: some View {
        UserView()
    }
}
