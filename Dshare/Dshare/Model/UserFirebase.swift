import Foundation
import Firebase
import FirebaseDatabase

class UserFirebase {
    let ref:DatabaseReference?;
    
    init(){
        FirebaseApp.configure();
        ref = Database.database().reference();
    }
    
    //The function adds a new User to the firebase database
    func addNewUser(user:User) {
        let myRef = ref?.child("users").child(user.id);
        myRef?.setValue(user.toJson());
    }
    
    func getUser(id:String, callback:@escaping (User?)->Void) {
        let myRef = ref?.child("users").child(id);
        myRef?.observeSingleEvent(of: .value, with: {(snapshot) in
            if let val = snapshot.value as? [String:Any] {
                let user = User(fromJson: val);
                callback(user);
            }
            else {
                callback(nil);
            }
        });
    }
}
