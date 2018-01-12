import Foundation

class Message {
    var id:String
    var userId:String
    var userName:String
    var textMessage:String
    
    init(userId:String, userName:String, textMessage:String) {
        self.id = UUID().uuidString
        self.userId = userId
        self.userName = userName
        self.textMessage = textMessage
    }
    
    init(fromJson:[String:Any]){
        id = fromJson["id"] as! String
        userId = fromJson["userId"] as! String
        userName = fromJson["userName"] as! String
        textMessage = fromJson["textMessage"] as! String
    }
    
    func toJson()->[String:Any] {
        var json = [String:Any]()
        json["id"] = id
        json["userId"] = userId
        json["userName"] = userName
        json["textMessage"] = textMessage
        return json
    }
}
