//
//  ModelFirebase.swift
//  Dshare
//
//  Created by admin on 19/12/2017.
//  Copyright © 2017 Munoz, Valentina. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase

class UserFirebase {
    let ref:DatabaseReference?
    
    init(){
        FirebaseApp.configure()
        ref = Database.database().reference()
        
        ref?.child("users")
    }
    
    //The function adds a new User to the firebase database
    func addNewUser(user:User){
        let myRef = ref?.child("users").child(user.email)
        myRef?.setValue(user.toJson())
    }
    
    func getUser(byEmail:String, callback:@escaping (User?)->Void){
        let myRef = ref?.child("users").child(byEmail)
        myRef?.observeSingleEvent(of: .value, with: {(snapshot) in
            if let val = snapshot.value as? [String:Any]{
                let user = User(fromJson: val)
                callback(user)
            }
            else {
                callback(nil)
            }
        })
    }
}
