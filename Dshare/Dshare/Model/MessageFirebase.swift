import Foundation
import Firebase


class MessageFirebase {
    //let ref:DatabaseReference?
    var newMessageRefHandle: DatabaseHandle?
    let messagesRef = Database.database().reference().child("messages")
    
    //CHAT function
    func addNewMessage(message: Message, completionBlock:@escaping (Error?)->Void){
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
    }
    
}
