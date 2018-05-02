import UIKit

class UserPasswordChangeViewController: UIViewController {
    @IBOutlet weak var currentPassword: UITextField!
    @IBOutlet weak var newPassword: UITextField!
    @IBOutlet weak var reNewPassword: UITextField!
    
    var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect(x:0, y:100, width:50, height:50))
    var email: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
        Model.instance.getCurrentUser() {(user) in
            self.email = user.email
            self.stopAnimatingActivityIndicator()
        }
    }
    
    @IBAction func submitNewPassword(_ sender: UIButton) {
        activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
        if newPassword.text! == reNewPassword.text! {
            self.changePassword()
        } else {
            self.stopAnimatingActivityIndicator()
            Utils.instance.displayAlertMessage(messageToDisplay: "Passwords do not match", controller: self)
        }
    }
    
    func changePassword() {
        Model.instance.reauthenticateUser(withEmail: self.email!, password: self.currentPassword.text!) { (error) in
            if error != nil {
                self.stopAnimatingActivityIndicator()
                Utils.instance.displayAlertMessage(messageToDisplay: (error?.localizedDescription)!, controller: self)
            } else {
                Model.instance.updatePassword(newPassword: self.newPassword.text!) { (error) in
                    self.stopAnimatingActivityIndicator()
                    if error != nil {
                        Utils.instance.displayAlertMessage(messageToDisplay: (error?.localizedDescription)!, controller: self)
                    } else {
                        Utils.instance.displayMessageToUser(messageToDisplay: "Password changed successfully", controller: self)
                        
                    }
                }
            }
        }
    }
    
    func stopAnimatingActivityIndicator() {
        activityIndicator.stopAnimating()
        UIApplication.shared.endIgnoringInteractionEvents()
    }
}
