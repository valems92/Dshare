import UIKit

class UserInfoViewController: UIViewController {

    var user:User?
    
    @IBOutlet weak var fName: UITextField!
    @IBOutlet weak var lName: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var gender: UITextField!
    @IBOutlet weak var phoneNum: UITextField!
    @IBOutlet weak var newPassword: UITextField!
   
   
    override func viewDidLoad() {
        super.viewDidLoad()
        newPassword.isSecureTextEntry = true
        Model.instance.getCurrentUser() {(user) in
            if user != nil{
                self.user = user
                self.updateAllTextFields(user: user)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func submitNewInfo(_ sender: Any) {
        Model.instance.updateUserInfo(fName: self.fName.text!, lName: self.lName.text!, email: self.email.text!, phoneNum: self.phoneNum.text!, gender: self.gender.text!)
        Model.instance.getCurrentUser() {(user) in
            if user != nil{
                self.user = user
                self.updateAllTextFields(user: user)
            }
        }
    }
    
    @IBAction func submitNewPassword(_ sender: Any) {
          Model.instance.updatePassword(newPassword: self.newPassword.text!)
    }
    
    func updateAllTextFields(user:User){
        self.fName.text = user.fName
        self.lName.text = user.lName
        self.email.text = user.email
        self.gender.text = user.gender
        self.phoneNum.text = user.phoneNum
    }

}
