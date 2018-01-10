import Foundation
import Firebase
import FirebaseStorage
import FirebaseAuth

class UserFirebase {
    //let ref:DatabaseReference?
    
    init(){
        FirebaseApp.configure()
    }
    
    //The function checks if the user signed in before
    func checkIfUserLoggedIn(completionBlock:@escaping (Bool?)->Void){
        if Auth.auth().currentUser == nil {
            completionBlock(false)
        }
        else {
            completionBlock(true)
        }
    }
    
    //The function adds a new User to the firebase database
    func addNewUser(user:User, completionBlock:@escaping (String?, Error?)->Void){
        Auth.auth().createUser(withEmail: user.email, password: user.password) { (newUser, error) in
            user.id = (newUser?.uid)!
            if newUser == nil {
                completionBlock(user.id, error)
            }
            else {
                let ref = Database.database().reference().child("users").child(user.id)
                ref.setValue(user.toFirebase()){(error, dbref) in
                    //completionBlock(error)
                }
                completionBlock(user.id, nil)
            }
        }
    }
    
    func addNewSearch(search: Search, completionBlock:@escaping (Error?)->Void){
        let searchesRef = Database.database().reference().child("searches");
        let searchRef = searchesRef.child(search.id)
        
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
    
    func signOutUser(completionBlock:@escaping (Error?)->Void) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            completionBlock(nil)
        } catch let signOutError as NSError {
            completionBlock(signOutError)
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
    
    func getUserById(id:String, callback:@escaping (User?)->Void) {
        Database.database().reference().child("users").child(id).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let fName = value?["fName"] as? String ?? ""
            let lName = value?["lName"] as? String ?? ""
            let email = value?["email"] as? String ?? ""
            let gender = value?["gender"] as? String ?? ""
            let imagePath = value?["imagePath"] as? String ?? ""
            let phoneNum = value?["phoneNum"] as? String ?? ""
            let user = User(email:email, fName:fName, lName:lName, phoneNum:phoneNum, gender:gender, imagePath:imagePath)
            callback(user)
        })
    }
    
    func updateUserInfo(fName:String, lName:String, email:String, phoneNum:String, gender:String){
        let id:String? = getCurrentUserUid()
        let db = Database.database().reference().child("users").child(id!)
        db.updateChildValues(["fName":fName])
        db.updateChildValues(["lName":lName])
        db.updateChildValues(["email":email])
        db.updateChildValues(["phoneNum":phoneNum])
        db.updateChildValues(["gender":gender])
    }
    
    func updatePassword(newPassword:String){
        Auth.auth().currentUser?.updatePassword(to: newPassword) { (error) in
            // ...
        }
    }
    
    func getSearchesByUserId(id:String, callback:@escaping (Error?, [Search])->Void) {
        let myRef = Database.database().reference().child("searches")
        myRef.queryOrdered(byChild: "userId").queryEqual(toValue: id).observeSingleEvent(of: .value) {(snapshot:DataSnapshot) in
            var searches = [Search]()
            for search in snapshot.children.allObjects {
                if let searchData = search as? DataSnapshot {
                    if let json = searchData.value as? Dictionary<String,Any> {
                        searches.append(Search(fromJson: json))
                    }
                }
            }
            
            callback(nil, searches)
        }
    }
    
    func getAllSearches(callback:@escaping ([Search])->Void) {
        let ref = Database.database().reference().child("searches");
        ref.observeSingleEvent(of: .value) {(snapshot: DataSnapshot) in
            var searches = [Search]();
            for search in snapshot.children.allObjects {
                if let searchData = search as? DataSnapshot {
                    if let json = searchData.value as? Dictionary<String,Any> {
                        searches.append(Search(fromJson: json))
                    }
                }
            }
            callback(searches)
        }
    }
    
    func startObserveSearches(callback:@escaping(Search?,String)->Void) {
        let ref = Database.database().reference()
        
        ref.child("searches").observe(.childChanged, with: { (snapshot) in
            print("childChanged \(snapshot)")
            //callback(Search(fromJson: (snapshot.value as? [String : Any])!), "Changed")
        })
    }
    
    func stopObserveSearches() {
        let ref = Database.database().reference()
        ref.child("searches").removeAllObservers()
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
