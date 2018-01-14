import UIKit
import JSQMessagesViewController

class ChatViewController: JSQMessagesViewController, MessageReceivedDelegate {
    //lazy var outgoingBubbleImageView: JSQMessagesBubbleImage = self.setupOutgoingBubble()
    //lazy var incomingBubbleImageView: JSQMessagesBubbleImage = self.setupIncomingBubble()
    
    var messages = [JSQMessage]()
    var users:[String]? // An array of the recievers ids
    var userAvatarImg:JSQMessagesAvatarImage?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.senderDisplayName = ""
        
        
        //Get user image for the chat
        Model.instance.getCurrentUser(){ (user) in
            self.senderDisplayName = user.fName + " " + user.lName
            Model.instance.getImage(urlStr: user.imagePath!) { (image) in
                self.userAvatarImg = JSQMessagesAvatarImageFactory.avatarImage(with: image, diameter: 30)
                
            }
        }
        
        Model.instance.messageFirebase?.delegate = self
        
        Model.instance.messageFirebase?.observeMessages()
        
        /*
        collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSize(width: 5, height: 5)
        collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSize(width: 5, height: 5)
        
        self.observeMessages()*/
    }
    
    
    //set the message text color
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        /*let message = messages[indexPath.item]
        
        if message.senderId == senderId {
            cell.textView?.textColor = UIColor.white
        } else {
            cell.textView?.textColor = UIColor.black
        }*/
        return cell
    }
    
    //Setting Up the Data Source and Delegate
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let bubbleFactory = JSQMessagesBubbleImageFactory()
        return bubbleFactory?.outgoingMessagesBubbleImage(with: UIColor.blue)
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        
        return userAvatarImg
    }
    
    
    
    //override the following method to make the “Send” button save a message to the Firebase database.
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        Model.instance.sendMessage(senderID: senderId, senderName: senderDisplayName, recieversIds: users!, text: text)
        collectionView.reloadData()
        //Remove the text from the text field
        finishSendingMessage()
    }
    
    
    //Delegation function
    
    func messageRecieved(senderID: String, senderName:String, recieversIds:[String], text: String) {
        if senderID == Model.instance.getCurrentUserUid() { // If the sender is the current user
            for recieverId in recieversIds {
                for user in users! {
                    if recieverId == user {
                        messages.append(JSQMessage(senderId: senderID, displayName: senderName, text: text))
                        collectionView.reloadData()
                        break
                    }
                }
            }
        }
        else { // If the sender is not the current user
            for recieverId in recieversIds {
                if recieverId == Model.instance.getCurrentUserUid() { // If the reciever is the current user
                    for userID in users! {
                        if senderID == userID { // If someone of the users sent the message
                            messages.append(JSQMessage(senderId: senderID, displayName: senderName, text: text))
                            collectionView.reloadData()
                            break
                        }
                    }
                }
            }
        }
        
    }
    
    
    
    /*@IBAction func onBack(_ sender: UIButton) {
     let storyBoard = UIStoryboard(name: "Main", bundle: nil);
     let viewController = storyBoard.instantiateViewController(withIdentifier: "SuggestionsPage");
     
     self.present(viewController, animated: true, completion: nil);
     }*/
    
    
    
    
    
    
/*lazy var outgoingBubbleImageView: JSQMessagesBubbleImage = self.setupOutgoingBubble()
 lazy var incomingBubbleImageView: JSQMessagesBubbleImage = self.setupIncomingBubble()
 
 var messages = [JSQMessage]()
 var users:[User]?
 
 override func viewDidLoad() {
 super.viewDidLoad()
 
 Model.instance.getCurrentUser() {(user) in
 if user != nil{
 self.senderId = user.id
 self.senderDisplayName = user.fName
 }
 }
 
 self.senderId="1234"
 self.senderDisplayName="kseniya"
 
 collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSize(width: 5, height: 5)
 collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSize(width: 5, height: 5)
 
 self.observeMessages()
 }
 
 
 override func viewDidAppear(_ animated: Bool) {
 super.viewDidAppear(animated)
 // messages from someone else
 //addMessage(withId: "user1", name: "Hi user1", text: "How are you?")
 // messages sent from local sender
 //addMessage(withId: senderId, name: "user2", text: "I'm fine")
 // animates the receiving of a new message on the view
 finishReceivingMessage()
 }
 
 override func didReceiveMemoryWarning() {
 super.didReceiveMemoryWarning()
 }
 
 private func addMessage(withId id: String, name: String, text: String) {
 let uid:String
 
 uid = Model.instance.getCurrentUserUid()
 
 Model.instance.getUserById(id: uid) {(user) in
 if user != nil {
 let uName:String
 uName = user.fName + " " + user.lName
 let messageToDB = Message(userId: uid, userName: uName, textMessage: text)
 Model.instance.addNewMessage(message: messageToDB) { (error) in
 if error == nil {
 if let message = JSQMessage(senderId: id, displayName: name, text: text) {
 self.messages.append(message)
 self.collectionView.reloadData()
 }
 }
 }
 }
 }
 }
 
 private func observeMessages() {
 Model.instance.observeMessages() {(message) in
 if message != nil {
 self.addMessage(withId: (message?.id)!, name: (message?.userName)!, text: (message?.textMessage)!)
 
 self.finishReceivingMessage()
 }
 else {
 Utils.instance.displayAlertMessage(messageToDisplay: "Error! Could not decode message data", controller: self)
 }
 }
 }
 
 //set the message text color
 override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
 let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
 let message = messages[indexPath.item]
 
 if message.senderId == senderId {
 cell.textView?.textColor = UIColor.white
 } else {
 cell.textView?.textColor = UIColor.black
 }
 return cell
 }
 
 //Setting Up the Data Source and Delegate
 override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
 return messages[indexPath.item]
 }
 
 override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
 return messages.count
 }
 
 override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
 return nil
 }
 
 override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
 let message = messages[indexPath.item] // 1
 if message.senderId == senderId { // 2
 return outgoingBubbleImageView
 } else { // 3
 return incomingBubbleImageView
 }
 }
 
 // MARK: UI and User Interaction
 private func setupOutgoingBubble() -> JSQMessagesBubbleImage {
 let bubbleImageFactory = JSQMessagesBubbleImageFactory()
 return bubbleImageFactory!.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
 }
 
 private func setupIncomingBubble() -> JSQMessagesBubbleImage {
 let bubbleImageFactory = JSQMessagesBubbleImageFactory()
 return bubbleImageFactory!.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
 }
 
 //override the following method to make the “Send” button save a message to the Firebase database.
 override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
 //User ID and Sender ID are not equals!!!!
 addMessage(withId: senderId, name: senderDisplayName, text: text)
 
 //JSQSystemSoundPlayer.jsq_playMessageSentSound()
 
 finishSendingMessage()
 }
 
 @IBAction func onBack(_ sender: UIButton) {
 let storyBoard = UIStoryboard(name: "Main", bundle: nil);
 let viewController = storyBoard.instantiateViewController(withIdentifier: "SuggestionsPage");
 
 self.present(viewController, animated: true, completion: nil);
 }*/
}

