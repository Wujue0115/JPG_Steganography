//
//  Attention+CoreData.swift
//  JPG_Steganography
//
//  Created by 鄭子輿 on 2020/10/21.
//  Copyright © 2020 MCU. All rights reserved.
//

import Foundation
import CoreData

struct Contact: Identifiable {
    var id = Int()
    var sName: String = String()
    var sPublicKey: String = String()
    
    init(){}
    
    init(sName: String, sPublicKey: String){
        self.sName = sName
        self.sPublicKey = sPublicKey
    }
    
    init(id: Int
         , sName: String, sPublicKey: String){
        self.id = id
        self.sName = sName
        self.sPublicKey = sPublicKey
    }
}


class ContactsCoreData {
    var context: NSManagedObjectContext! = nil
    var data: [Contact] = []
    
    init(context: NSManagedObjectContext){
        self.context = context
    }
    
    func Read(){
        do {
            let contextFetch = try context.fetch(Contacts.fetchRequest())
            
            if (contextFetch.count > 0) {
                print("Read Data:")
                for contact in contextFetch as! [Contacts] {
                    data.append(Contact(sName: contact.sName!, sPublicKey: contact.sPublicKey!))
                    print("    => (\(contact.sName!), \(contact.sPublicKey!))")
                }
            } else {
                print("It isn't any ontact in CoreData!")
            }
        } catch {
            fatalError("Read Error!")
        }
    }
    
    func Insert(insertContact: Contact){
        let contact = Contacts(context: context)
        contact.sName = insertContact.sName
        contact.sPublicKey = insertContact.sPublicKey
        
        do {
            try context.save()
            
            print("==============================")
            print("Save successful!")
            print("Save Data is (\(insertContact.sName), \(insertContact.sPublicKey))")
        } catch {
            fatalError("Insert Error!")
        }
    }
    
    func Update(oldContact: Contact, newContact: Contact){
        do {
            let contextFetch = try context.fetch(Contacts.fetchRequest())
            for contact in contextFetch as! [Contacts] {
                if (contact.sName == oldContact.sName
                 && contact.sPublicKey == oldContact.sPublicKey)
                {
                    contact.sName = newContact.sName
                    contact.sPublicKey = newContact.sPublicKey
                }
            }
            
            print("==============================")
            print("Update successful!")
            print("Update Data (\(oldContact.sName), \(oldContact.sPublicKey)) to (\(newContact.sName), \(newContact.sPublicKey))")
        } catch {
            fatalError("Update Error!")
        }
    }
    
    func Delete(deleteContact: Contact){
        do {
            let contextFetch = try context.fetch(Contacts.fetchRequest())
            for contact in contextFetch as! [Contacts] {
                if (contact.sName == deleteContact.sName
                        && contact.sPublicKey == deleteContact.sPublicKey )
                {
                    context.delete(contact)
                }
            }
            
            print("==============================")
            print("Delete successful!")
            print("Delete Data is (\(deleteContact.sName), \(deleteContact.sPublicKey))")
        } catch {
            fatalError("Delete Error!")
        }
    }
    
    func Clear(){
        do {
            let contextFetch = try context.fetch(Contacts.fetchRequest())
            for contact in contextFetch as! [Contacts] {
                context.delete(contact)
            }
            
            print("==============================")
            print("Clear successful!")
        } catch {
            fatalError("Clear Error!")
        }
    }
}
