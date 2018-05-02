import UIKit

class UserAccountViewController: UIViewController {
    
    var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect(x:0, y:100, width:50, height:50))
    var user: User?
    @IBOutlet weak var userName: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Model.instance.getCurrentUser() {(user) in
            self.user = user
            self.updateUserName(user: user)
        }
    }
    
    @IBAction func logOut(_ sender: Any) {
        //Set activity indicator
        activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents() //When the activity indicator presents, the user can't interact with the app
        Model.instance.signOutUser() { (error) in
            self.stopAnimatingActivityIndicator()
            if error != nil {
                Utils.instance.displayAlertMessage(messageToDisplay:(error?.localizedDescription)!, controller:self)
            }
            else{
                self.navigationController?.popToRootViewController(animated: true)
            }
        }
    }
    
    func stopAnimatingActivityIndicator() {
        activityIndicator.stopAnimating()
        UIApplication.shared.endIgnoringInteractionEvents()
    }
    
    func updateUserName(user: User) {
        //Update user name label
        self.userName.text = "\(user.fName) \(user.lName)"
    }
}
