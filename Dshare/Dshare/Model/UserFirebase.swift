import Foundation
import Firebase
import FirebaseStorage
import FirebaseAuth

class UserFirebase {
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
            user.id = (newUser?.user.uid)!
            if newUser == nil {
                completionBlock(user.id, error)
            }
            else {
                let ref = Database.database().reference().child("users").child(user.id)
                ref.setValue(user.toFirebase()){(error, dbref) in
                    
                }
                completionBlock(user.id, nil)
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
            let user = User(id:id, email:email, fName:fName, lName:lName, phoneNum:phoneNum, gender:gender, imagePath:imagePath)
            callback(user)
        })
    }
    
    func updateUserInfo(fName:String, lName:String, email:String, phoneNum:String, gender:String, completionBlock:@escaping (Error?)->Void){
        let id:String? = getCurrentUserUid()
        let db = Database.database().reference().child("users").child(id!)
        db.updateChildValues(["fName":fName])
        db.updateChildValues(["lName":lName])
        db.updateChildValues(["email":email])
        db.updateChildValues(["phoneNum":phoneNum])
        db.updateChildValues(["gender":gender])
        Auth.auth().currentUser?.updateEmail(to: email) { (error) in
            completionBlock(error)
        }
    }
    
    func updateUserInfoWithPhoto(fName:String, lName:String, email:String, phoneNum:String, gender:String, imagePath:String, completionBlock:@escaping (Error?)->Void){
        let id:String? = getCurrentUserUid()
        let db = Database.database().reference().child("users").child(id!)
        db.updateChildValues(["fName":fName])
        db.updateChildValues(["lName":lName])
        db.updateChildValues(["email":email])
        db.updateChildValues(["phoneNum":phoneNum])
        db.updateChildValues(["gender":gender])
        db.updateChildValues(["imagePath":imagePath])
        Auth.auth().currentUser?.updateEmail(to: email) { (error) in
            completionBlock(error)
        }
    }
    
    func updatePassword(newPassword:String, completionBlock:@escaping (Error?)->Void){
        Auth.auth().currentUser?.updatePassword(to: newPassword) { (error) in
            completionBlock(error)
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
        "gs://dsharefinalproject.appspot.com")
    
    func saveImageToFirebase(image:UIImage, name:(String), callback:@escaping (String?)->Void){
        let filesRef = storageRef.child(name)
        if let data = UIImageJPEGRepresentation(image, 0.8) {
            filesRef.putData(data, metadata: nil) { metadata, error in
                if (error != nil) {
                    callback(nil)
                } else {
                    filesRef.downloadURL(completion: { (url, error) in
                        if error == nil && url != nil {
                            callback(url!.absoluteString)
                        } else {
                            callback(nil)
                        }
                    })
                    
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
    
    func reauthenticateUser(withEmail: String, password: String, completion: @escaping (Error?)->Void) {
        let credential = EmailAuthProvider.credential(withEmail: withEmail, password: password)
        Auth.auth().currentUser?.reauthenticate(with: credential) { (error) in
            completion(error)
        }
    }
}
