import UIKit

class LoginViewController: UIViewController {
    var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents() //When the activity indicator presents, the user can't interact with the app
        
        //Login user
        if validateUserInput(){
            Model.instance.signInUser(email: email.text!, password: password.text!) {(error) in
                if error != nil { //If an error occured
                    self.activityIndicator.stopAnimating()
                    UIApplication.shared.endIgnoringInteractionEvents()
                    self.displayAlertMessage(messageToDisplay:(error?.localizedDescription)!)
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
            displayAlertMessage(messageToDisplay:"You have to enter your email")
            returnValue = false
        }
        if (password.text?.isEmpty)! {
            displayAlertMessage(messageToDisplay:"You have to enter a password")
            returnValue = false
        }
        
        let isEmailAddressValid = isValidEmailAddress(emailAddressString: email.text!)
        
        if !isEmailAddressValid {
            displayAlertMessage(messageToDisplay:"Email address is not valid")
            returnValue = false
        }
        
        return returnValue
    }
    
    func isValidEmailAddress(emailAddressString:String) -> Bool {
        var returnValue = true
        let emailRegEx = "[A-Z0-9a-z.-_]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,3}"
        
        do {
            let regex = try NSRegularExpression(pattern: emailRegEx)
            let nsString = emailAddressString as NSString
            let results = regex.matches(in: emailAddressString, range: NSRange(location: 0, length: nsString.length))
            
            if results.count == 0 {
                returnValue = false
            }
        } catch let error as NSError {
            print("invalud regex: \(error.localizedDescription)")
            returnValue = false
        }
        
        return returnValue
    }
    
    func displayAlertMessage(messageToDisplay:String){
        let alertController = UIAlertController(title:"Error", message:messageToDisplay, preferredStyle:.alert)
        let OKAction = UIAlertAction(title:"OK", style:.default) { (action:UIAlertAction!) in
            print("OK tapped")
        }
        
        alertController.addAction(OKAction)
        
        self.present(alertController, animated:true, completion:nil)
    }
}
