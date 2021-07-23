//
//  SettingView.swift
//  JPG_Steganography
//
//  Created by 翁明緯 on 2020/9/27.
//  Copyright © 2020 MCU. All rights reserved.
//

import SwiftUI
import Combine

// var userRSAPrivateKey: SecKey?
var bPrivateKey: Bool = false
// var userRSAPublicKey: SecKey?
var bPublicKey: Bool = false
// var userEmbedKey: String = ""
var boolRSAEncryption: Bool?

var iEmbedMode: Int = 0

var EmbedMode: [(Int, Int)] = [
    (15,4),
    (7,3),
    (3,2),
    (1,1)
]

struct SettingView: View {
    
    @State private var bisRSAEncryption = LoadRSAEncryption() //State(initialValue:LoadRSAEncryption())
    @State private var iSelectMode = LoadEmbedMode()
    var EmbedModeOptins = ["F5 Hight","F5 Medium","F5 Low","LSB Low"]
    
    var body: some View {
        Form{
            /*
            Button(action:{print(LoadEmbedMode())
                print(LoadRSAEncryption())
            }){
                Text("aa")
            }
            
            Text(String("in:\(boolRSAEncryption)"))
            Text(String(bisRSAEncryption))
            */
            Section{
                NavigationLink(destination: UserView()){
                    HStack{
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        VStack(){
                            Text("User Key")
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
                /*
                Picker( selection: Binding(get: { iSelectMode },set: { iSelectMode = $0 }), label:Text("Embed Mode")){
                    Section{
                        ForEach(0..<EmbedModeOptins.count){ index in
                            Text("\(self.EmbedModeOptins[index])")
                        }
                    }
                }
                */
                
                Picker( selection: self.$iSelectMode.onChange(ModeChange), label:Text("Embed & Extract Mode")){
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
                Toggle( isOn : $bisRSAEncryption.onChange(EncryptionChange), label: {
                    Text("RSA Encryption")
                })
            }
        }
        .navigationBarTitle("Setting")
        .onAppear() {
            iSelectMode = LoadEmbedMode()
            bisRSAEncryption = LoadRSAEncryption()
            if(!bPrivateKey){
                creatRSAprivatekey()
            }
        }
        .onDisappear(){
            Save()
            iEmbedMode = LoadEmbedMode()
            boolRSAEncryption = LoadRSAEncryption()
            iSelectMode = LoadEmbedMode()
            bisRSAEncryption = LoadRSAEncryption()
            print("RSA: \(boolRSAEncryption)")
        }
    }
}

func ModeChange(_ tag: Int) {
    iEmbedMode = tag
    Save()
}

func EncryptionChange(_ tag: Bool) {
    boolRSAEncryption = tag
    Save()
}


func Save(){
    let defaults = UserDefaults.standard
    defaults.set(bPrivateKey, forKey: "bPrivateKey")
    defaults.set(bPublicKey, forKey: "bPublicKey")
    defaults.set(boolRSAEncryption, forKey: "boolRSAEncryption")
    defaults.setValue(iEmbedMode, forKey: "iEmbedMode")
    
    // defaults.integer(forKey: "iEmbedMode")
}

func LoadEmbedMode() -> Int{
    let defaults = UserDefaults.standard
    return defaults.integer(forKey: "iEmbedMode")
}

func LoadRSAEncryption() -> Bool{
    let defaults = UserDefaults.standard
    return defaults.bool(forKey: "boolRSAEncryption")}

struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        SettingView()
    }
}
extension Binding {
    func onChange(_ handler: @escaping (Value) -> Void) -> Binding<Value> {
        return Binding(
            get: { self.wrappedValue },
            set: { selection in
                self.wrappedValue = selection
                handler(selection)
            })
    }
}
