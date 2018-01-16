import Foundation
import Firebase

protocol MessageReceivedDelegate: class {
    func messageRecieved(senderID:String, senderName:String, recieversIds:[String], text:String, exitMessage:Bool)
}

class MessageFirebase {
    //let ref:DatabaseReference?
    var newMessageRefHandle: DatabaseHandle?
    let messagesRef = Database.database().reference().child("messages")
    
    weak var delegate:MessageReceivedDelegate?
    
    //CHAT function
    /*func addNewMessage(message: Message, completionBlock:@escaping (Error?)->Void){
        let messageRef = messagesRef.child(message.id)
        // let messageRef = messagesRef.child(message.id)
        messageRef.setValue(message.toJson()) {(error, dbref) in
            if(error != nil) {
                completionBlock(error)
            } else {
                completionBlock(nil)
            }
        }
    }
    
    func observeMessages(callback:@escaping (Message?)->Void) {
        //let messageQuery = messagesRef.queryLimited(toLast:25)
        
        let messageQuery = messagesRef.childByAutoId()
        
        newMessageRefHandle = messageQuery.observe(.childAdded, with: { (snapshot) -> Void in
            let messageData = snapshot.value as! Dictionary<String, String>
            if let id = messageData["id"] as String!, let name = messageData["userName"] as String!, let text = messageData["textMessage"] as String!, text.characters.count > 0 {
                let message = Message(userId: id, userName: name, textMessage: text)
                callback(message)
            } else {
                callback(nil)
            }
        })
    }*/
    
    func sendMessage(senderID:String, senderName:String, recieversIds:[String], text:String, exitMessage:Bool) {
        let data:Dictionary<String,Any> = ["senderID":senderID, "senderName": senderName, "recieversIds": recieversIds, "text": text, "exitMessage":exitMessage]
        
        messagesRef.childByAutoId().setValue(data)
    }
    
    func observeMessages() {
        newMessageRefHandle = messagesRef.observe(.childAdded, with: { (snapshot) in
            let messageData = snapshot.value as! Dictionary<String, Any>
            
            if let senderID = messageData["senderID"] as! String!, let senderName = messageData["senderName"] as! String!, let recieversIds = messageData["recieversIds"] as! [String]!, let text = messageData["text"] as! String!, let exitMessage = messageData["exitMessage"] as! Bool! {
                self.delegate?.messageRecieved(senderID: senderID, senderName:senderName, recieversIds:recieversIds, text: text, exitMessage: exitMessage)
            }
        })
    }
    
    func removeObserver(){
        messagesRef.removeObserver(withHandle: newMessageRefHandle!)
    }
}
