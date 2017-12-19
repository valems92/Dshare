//
//  User.swift
//  Dshare
//
//  Created by admin on 13/12/2017.
//  Copyright © 2017 Munoz, Valentina. All rights reserved.
//

import Foundation

enum Gender {
    case male, female
}

class User {
    var email:String = ""
    var password:String = ""
    var fName:String = ""
    var lName:String = ""
    var phoneNum:String = ""
    var gender:Gender?
    var imagePath:String?
    
    init(email:String, password:String, fName:String, lName:String, phoneNum:String){
        self.email = email
        self.password = password
        self.fName = fName
        self.lName = lName
        self.phoneNum = phoneNum
    }
    
    init(fromJson:[String:Any]){
        email = fromJson["email"] as! String
        password = fromJson["password"] as! String
        fName = fromJson["fName"] as! String
        lName = fromJson["lName"] as! String
        phoneNum = fromJson["phoneNum"] as! String
        
        if(fromJson["gender"] != nil){
            gender = fromJson["gender"] as! Gender
        }
        
        if(fromJson["imagePath"] != nil){
            imagePath = fromJson["imagePath"] as! String
        }
    }
    
    func toJson()->[String:Any]{
        var json = [String:Any]()
        
        json["email"] = email
        json["password"] = password
        json["fName"] = fName
        json["lName"] = lName
        json["phoneNum"] = phoneNum
        
        if(gender != nil){
            json["gender"] = gender
        }
        if(imagePath != nil){
            json["imagePath"] = imagePath
        }
        
        return json
    }

}

