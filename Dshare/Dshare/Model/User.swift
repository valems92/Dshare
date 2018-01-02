import Foundation
import FirebaseDatabase

class User {
    var id:String
    var email:String
    var password:String
    var fName:String
    var lName:String
    var phoneNum:String
    var gender:String?
    var imagePath:String?
    var lastUpdate:Date?
    
    init(email:String, password:String, fName:String, lName:String, phoneNum:String,gender:String?,imagePath:String?) {
        self.id = UUID().uuidString
        self.email = email
        self.password = password
        self.fName = fName
        self.lName = lName
        self.phoneNum = phoneNum
        if(gender != nil){
            self.gender = gender
        }
        if(imagePath != nil){
            self.imagePath = imagePath
        }
    }
    
    init(fromJson:Dictionary<String,Any>){
        id = fromJson["id"] as! String
        email = fromJson["email"] as! String
        password = fromJson["password"] as! String
        fName = fromJson["fName"] as! String
        lName = fromJson["lName"] as! String
        phoneNum = fromJson["phoneNum"] as! String
        
        if(fromJson["gender"] != nil) {
            gender = (fromJson["gender"] as! String)
        }
        
        if(fromJson["imagePath"] != nil) {
            imagePath = (fromJson["imagePath"] as! String)
        }
        if let ts = fromJson["lastUpdate"] as? Double {
            self.lastUpdate = Date.fromFirebase(ts)
        }
    }
    
    func toFirebase() -> Dictionary<String,Any> {
        var json = Dictionary<String,Any>()
        
        json["id"] = id
        json["email"] = email
        //json["password"] = password
        json["fName"] = fName
        json["lName"] = lName
        json["phoneNum"] = phoneNum
        
        if(gender != nil) {
            json["gender"] = gender
        }
        if(imagePath != nil) {
            json["imagePath"] = imagePath
        }
        
        json["lastUpdate"] = ServerValue.timestamp()
        
        return json
    }
    
}
