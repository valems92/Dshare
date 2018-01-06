import UIKit
import JSQMessagesViewController

class ChatViewController: JSQMessagesViewController {
   // self.senderId = 7777
    // MARK: Properties
    lazy var outgoingBubbleImageView: JSQMessagesBubbleImage = self.setupOutgoingBubble()
    lazy var incomingBubbleImageView: JSQMessagesBubbleImage = self.setupIncomingBubble()
    
    var messages = [JSQMessage]()
    var users:[User]?
    
    // var channelRef: DatabaseReference?
    /*  var channel: Channel? {
     
     didSet {
        title = channel?.name
     
     }
     }*/
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.senderId = Auth.auth().currentUser?.uid
        self.senderId="1234"
        self.senderDisplayName="kseniya"
        collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSize(width: 5, height: 5)
        collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSize(width: 5, height: 5)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // messages from someone else
        addMessage(withId: "user1", name: "Hi user1", text: "How are you?")
        // messages sent from local sender
        addMessage(withId: senderId, name: "user2", text: "I'm fine")
        // animates the receiving of a new message on the view
        finishReceivingMessage()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private func addMessage(withId id: String, name: String, text: String) {
        if let message = JSQMessage(senderId: id, displayName: name, text: text) {
            messages.append(message)
        }
    }
    
    // MARK: Collection view data source (and related) methods
    
    /*override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.item] // 1
       // if message.senderId == senderId { // 2
            return outgoingBubbleImageView
      /*  } else { // 3
            return incomingBubbleImageView
        }*/
    }*/
    
    
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
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
    
    

    /*@IBAction func onBack(_ sender: UIButton) {
     let storyBoard = UIStoryboard(name: "Main", bundle: nil);
     let viewController = storyBoard.instantiateViewController(withIdentifier: "SuggestionsPage");
     
     self.present(viewController, animated: true, completion: nil);
     }*/
}
