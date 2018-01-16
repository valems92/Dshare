import UIKit

class LoginViewController: UIViewController {
    var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect(x:0, y:100, width:50, height:50))
    
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Utils.instance.initActivityIndicator(activityIndicator: activityIndicator, controller: self)
        
        //Dismiss keyboard when touching anywhere outside text field
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tap(gesture:)))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    func tap(gesture: UITapGestureRecognizer) {
        email.resignFirstResponder()
        password.resignFirstResponder()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func onLogin(_ sender: UIButton) {
        //Set activity indicator
        activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents() //When the activity indicator presents, the user can't interact with the app
        
        //Login user
        if validateUserInput(){
            Model.instance.signInUser(email: email.text!, password: password.text!) {(error) in
                if error != nil { //If an error occured
                    self.activityIndicator.stopAnimating()
                    UIApplication.shared.endIgnoringInteractionEvents()
                    Utils.instance.displayAlertMessage(messageToDisplay:(error?.localizedDescription)!, controller:self)
                }
                else { //The user logged in successfully, go to search screen
                    self.activityIndicator.stopAnimating()
                    UIApplication.shared.endIgnoringInteractionEvents()
                    self.performSegue(withIdentifier: "toSearchFromLogin", sender: self)
                }
            }
        }
    }
    
    func validateUserInput() -> Bool {
        var returnValue = true
        if (email.text?.isEmpty)! {
            Utils.instance.displayAlertMessage(messageToDisplay:"You have to enter your email", controller:self)
            returnValue = false
        }
        if (password.text?.isEmpty)! {
            Utils.instance.displayAlertMessage(messageToDisplay:"You have to enter a password", controller:self)
            returnValue = false
        }
        
        let isEmailAddressValid = Utils.instance.isValidEmailAddress(emailAddressString: email.text!)
        
        if !isEmailAddressValid {
            Utils.instance.displayAlertMessage(messageToDisplay:"Email address is not valid", controller:self)
            returnValue = false
        }
        
        if !returnValue {
            stopAnimatingActivityIndicator()
        }
        
        return returnValue
    }
    
    func stopAnimatingActivityIndicator() {
        activityIndicator.stopAnimating()
        UIApplication.shared.endIgnoringInteractionEvents()
    }
}
