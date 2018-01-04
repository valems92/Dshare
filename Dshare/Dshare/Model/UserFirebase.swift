import Foundation
import Firebase
import FirebaseStorage
import FirebaseAuth

class UserFirebase {
    //let ref:DatabaseReference?
    
    init(){
        FirebaseApp.configure()
    }
    
    //The function adds a new User to the firebase database
    func addNewUser(user:User, completionBlock:@escaping (String?, Error?)->Void){
        Auth.auth().createUser(withEmail: user.email, password: user.password) { (newUser, error) in
            let newUserID:String? = (newUser?.uid)!
            if newUser == nil {
                completionBlock(newUserID, error)
            }
            else {
                let ref = Database.database().reference().child("users").child(newUserID!)
                ref.setValue(user.toFirebase()){(error, dbref) in
                    //completionBlock(error)
                }
                completionBlock(newUserID, nil)
            }
        }
    }
    
    func addNewSearch(search: Search, completionBlock:@escaping (Error?)->Void){
        let searchesRef = Database.database().reference().child("searches");
        let userSearchesRef = searchesRef.child(search.userId);
        let searchRef = userSearchesRef.child(search.id)
        
        searchRef.setValue(search.toJson()) {(error, dbref) in
            if(error != nil) {
                completionBlock(error)
            } else {
                completionBlock(nil)
            }
        }
    }
    
    func signInUser(email:String, password:String, completionBlock:@escaping (Error?)->Void){
        Auth.auth().signIn(withEmail: email, password: password) { (newUser, error) in
            if newUser == nil {
                completionBlock(error)
            }
            else {
                completionBlock(nil)
            }
        }
    }
    
    func getCurrentUserUid() -> String? {
        let user = Auth.auth().currentUser
        if user != nil {
            return user?.uid
        } else {
           return nil
        }
    }
    
    //id is correct but need to fix methods
    func getCurrentUser(callback:@escaping (User?)->Void) {
        let id:String? = getCurrentUserUid()
        if id != nil {
            Database.database().reference().child("users").child(id!).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            let fName = value?["fName"] as? String ?? ""
            //let user = User(username: username)
            // ...
        })}
      callback(nil)
    }
    
    func getUser(id:String, callback:@escaping (User?)->Void) {
        let myRef = Database.database().reference().child("users").child(id)
        myRef.observeSingleEvent(of: .value, with: {(snapshot) in
            let json = snapshot.value as? Dictionary<String,String>
            let user = User(fromJson: json!)
            callback(user)
        });
    }
    
    func getSearchesByUserId(id:String, callback:@escaping (Error?, [Search])->Void) {
        let myRef = Database.database().reference().child("searches").child(id);
        myRef.queryOrdered(byChild:"createdOn").observeSingleEvent(of: .value) {(snapshot:DataSnapshot) in
            var searches = [Search]();
            for child in snapshot.children.allObjects {
                if let childData = child as? DataSnapshot {
                    if let json = childData.value as? Dictionary<String,Any> {
                        searches.append(Search(fromJson: json));
                    }
                }
            }
        }
    }
    
    func getAllUsers(_ lastUpdateDate:Date? , callback:@escaping ([User])->Void){
        let handler = {(snapshot:DataSnapshot) in
            var users = [User]()
            for child in snapshot.children.allObjects{
                if let childData = child as? DataSnapshot{
                    if let json = childData.value as? Dictionary<String,Any>{
                        let user = User(fromJson: json)
                        users.append(user)
                    }
                }
            }
            callback(users)
        }
        
        let ref = Database.database().reference().child("users")
        if (lastUpdateDate != nil){
            print("q starting at:\(lastUpdateDate!) \(lastUpdateDate!.toFirebase())")
            let fbQuery = ref.queryOrdered(byChild:"lastUpdate").queryStarting(atValue:lastUpdateDate!.toFirebase())
            fbQuery.observeSingleEvent(of: .value, with: handler)
        }else{
            ref.observeSingleEvent(of: .value, with: handler)
        }
    }
    
    func getAllUsersAndObserve(_ lastUpdateDate:Date?, callback:@escaping ([User])->Void){
        let handler = {(snapshot:DataSnapshot) in
            var users = [User]()
            for child in snapshot.children.allObjects{
                if let childData = child as? DataSnapshot{
                    if let json = childData.value as? Dictionary<String,Any>{
                        let user = User(fromJson: json)
                        users.append(user)
                    }
                }
            }
            callback(users)
        }
        
        let ref = Database.database().reference().child("users")
        if (lastUpdateDate != nil){
            print("q starting at:\(lastUpdateDate!) \(lastUpdateDate!.toFirebase())")
            let fbQuery = ref.queryOrdered(byChild:"lastUpdate").queryStarting(atValue:lastUpdateDate!.toFirebase())
            fbQuery.observe(DataEventType.value, with: handler)
        }else{
            ref.observe(DataEventType.value, with: handler)
        }
    }
    
    lazy var storageRef = Storage.storage().reference(forURL:
        "gs://dshare-ac2cb.appspot.com")
    
    func saveImageToFirebase(image:UIImage, name:(String), callback:@escaping (String?)->Void){
        let filesRef = storageRef.child(name)
        if let data = UIImageJPEGRepresentation(image, 0.8) {
            filesRef.putData(data, metadata: nil) { metadata, error in
                if (error != nil) {
                    callback(nil)
                } else {
                    let downloadURL = metadata!.downloadURL()
                    callback(downloadURL?.absoluteString)
                }
            }
        }
    }
    
    func getImageFromFirebase(url:String, callback:@escaping (UIImage?)->Void){
        let ref = Storage.storage().reference(forURL: url)
        ref.getData(maxSize: 10000000, completion: {(data, error) in
            if (error == nil && data != nil){
                let image = UIImage(data: data!)
                callback(image)
            }else{
                callback(nil)
            }
        })
    }
}
