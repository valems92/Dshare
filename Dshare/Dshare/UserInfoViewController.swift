import UIKit

class UserInfoViewController: UIViewController {

    //let model = UserFirebase()
    @IBOutlet weak var firstName: UITextField!
    
    var user:User?
    var model:UserFirebase?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        /*let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "RegisterPage") as! RegisterViewController
        model = controller.model*/

        /*let registerVC:RegisterViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RegisterViewController") as! RegisterViewController*/
        
        /*model.getUser(id: "1", callback: { user in
            print("\nSuccess. Response received...: " + String(describing: user?.fName))})*/
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
