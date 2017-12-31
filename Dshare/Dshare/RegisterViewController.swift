import UIKit

class RegisterViewController: UIViewController,UIPickerViewDataSource, UIPickerViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    //let model = UserFirebase()
    var pickerDataSource = ["Male", "Female"]
    var userImage:UIImage?
    
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var rePassword: UITextField!
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var phoneNumber: UITextField!
    @IBOutlet weak var gender: UIPickerView!
    @IBOutlet weak var image: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.gender.dataSource = self
        self.gender.delegate = self
    }
    
    @IBAction func addPhoto(_ sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(.camera) || UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            let controller = UIImagePickerController()
            controller.delegate = self
            present(controller, animated: true, completion: nil)
        }
        
    }
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]){
        userImage = info["UIImagePickerControllerOriginalImage"] as! UIImage
        self.image.image = userImage
        dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
   
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerDataSource.count;
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerDataSource[row]
    }
    
    @IBAction func createUser(_ sender: UIButton) {
        if !validateUserInput() {
            return
        }
        
        let user = User(email:email.text!, password:password.text!, fName:firstName.text!, lName:lastName.text!, phoneNum:phoneNumber.text!, gender:gender.selectedRow(inComponent: 0).description, imagePath:image.description)
        
        if userImage != nil {
            Model.instance.saveImage(image: userImage!, name: user.id){(url) in
                //image was saved
                
            }
        }
        
        Model.instance.addNewUser(user: user)
        
        /*let userInfoVC = storyboard?.instantiateViewController(withIdentifier: "UserInfoViewController") as! UserInfoViewController
        userInfoVC.model = model
        navigationController?.pushViewController(userInfoVC, animated: true)*/
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
        if (rePassword.text?.isEmpty)! {
            displayAlertMessage(messageToDisplay:"You have to re-enter your password")
            returnValue = false
        }
        else {
            if !rePassword.text!.contains(password.text!) {
                displayAlertMessage(messageToDisplay:"Password and re-Password are not equal")
                returnValue = false
            }
        }
        if (firstName.text?.isEmpty)! {
            displayAlertMessage(messageToDisplay:"You have to enter your first name")
            returnValue = false
        }
        if (lastName.text?.isEmpty)! {
            displayAlertMessage(messageToDisplay:"You have to enter your last name")
            returnValue = false
        }
        if (phoneNumber.text?.isEmpty)! {
            displayAlertMessage(messageToDisplay:"You have to enter your phone number")
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
        let alertController = UIAlertController(title:"Alert", message:messageToDisplay, preferredStyle:.alert)
        let OKAction = UIAlertAction(title:"OK", style:.default) { (action:UIAlertAction!) in
            print("OK tapped")
        }
        
        alertController.addAction(OKAction)
        
        self.present(alertController, animated:true, completion:nil)
    }
    
    
    /*@IBAction func onCancel(_ sender: UIButton) {
     changeView(_storyboardName: "Main", _viewName: "WelcomePage");
     }
     
     @IBAction func onCreate(_ sender: UIButton) {
     changeView(_storyboardName: "Main", _viewName: "SearchPage");
     }
     
     private func changeView(_storyboardName: String, _viewName: String) {
     let storyBoard = UIStoryboard(name: _storyboardName, bundle: nil);
     let viewController = storyBoard.instantiateViewController(withIdentifier: _viewName);
     
     self.present(viewController, animated: true, completion: nil);
     }*/
}
