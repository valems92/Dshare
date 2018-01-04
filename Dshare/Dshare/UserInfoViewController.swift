import UIKit

class UserInfoViewController: UIViewController {

    var user:User?
    
    @IBOutlet weak var fName: UITextField!
    @IBOutlet weak var lName: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var gender: UITextField!
    @IBOutlet weak var phoneNum: UITextField!
    @IBOutlet weak var editFName: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        Model.instance.getCurrentUser() {(user) in
            if user != nil{
                self.user = user
                self.fName.text = user.fName
                self.lName.text = user.lName
                self.email.text = user.email
                self.gender.text = user.gender
                self.phoneNum.text = user.phoneNum
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func editFName(_ sender: Any) {
        /*Model.instance.updateUser(user:user!) {(user) in
            if user != nil{
                self.user = user
                self.fName.text = user?.fName
                self.lName.text = user?.lName
                self.email.text = user?.email
                self.gender.text = user?.gender
                self.phoneNum.text = user?.phoneNum
            }
        }*/
        
        Model.instance.updateUserFirstName(fName: self.fName.text!)
        Model.instance.getCurrentUser() {(user) in
            if user != nil{
                self.user = user
                self.fName.text = user.fName
                self.lName.text = user.lName
                self.email.text = user.email
                self.gender.text = user.gender
                self.phoneNum.text = user.phoneNum
            }
        }
    }
}
