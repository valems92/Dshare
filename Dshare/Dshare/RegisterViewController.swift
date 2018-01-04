import UIKit

class RegisterViewController: UIViewController,UIPickerViewDataSource, UIPickerViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var pickerDataSource = ["Male", "Female"]
    var userImage:UIImage?
    var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    
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
        
        //Dismiss keyboard when touching anywhere outside text field
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tap(gesture:)))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    func tap(gesture: UITapGestureRecognizer) {
        email.resignFirstResponder()
        password.resignFirstResponder()
        rePassword.resignFirstResponder()
        firstName.resignFirstResponder()
        lastName.resignFirstResponder()
        phoneNumber.resignFirstResponder()
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
        //Set activity indicator
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents() //When the activity indicator presents, the user can't interact with the app
        
        //Create user
        if validateUserInput(){
            addUserToFirebase()
        }
    }
    
    func addUserToFirebase() {
        let user = User(email:email.text!, password:password.text!, fName:firstName.text!, lName:lastName.text!, phoneNum:phoneNumber.text!, gender:gender.selectedRow(inComponent: 0).description, imagePath:image.description)
        
        if userImage != nil {
            Model.instance.saveImage(image: userImage!, name: user.id){(url) in
                user.imagePath = url
                self.addNewUser(user: user)
            }
        }
    }
    
    func addNewUser(user:User){
        Model.instance.addNewUser(user: user) {(newUserID, error) in
            if error != nil {
                self.activityIndicator.stopAnimating()
                UIApplication.shared.endIgnoringInteractionEvents()
                self.displayAlertMessage(messageToDisplay:(error?.localizedDescription)!)
            }
            else {
                self.activityIndicator.stopAnimating()
                UIApplication.shared.endIgnoringInteractionEvents()
                user.id = newUserID!
                self.performSegue(withIdentifier: "toSearchFromRegister", sender: self)
            }
            //st.addStudentToLocalDb(database: self.modelSql?.database)
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
        
        let isPhoneNumberValid = isValidPhoneNumber(phoneNumberString: phoneNumber.text!)
        
        if !isPhoneNumberValid {
            displayAlertMessage(messageToDisplay:"Phone number is not valid")
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
    
    func isValidPhoneNumber(phoneNumberString:String) -> Bool {
        var returnValue = true
        let phoneRegEx = "^[0-9]{10}$"
        
        do {
            let regex = try NSRegularExpression(pattern: phoneRegEx)
            let nsString = phoneNumberString as NSString
            let results = regex.matches(in: phoneNumberString, range: NSRange(location: 0, length: nsString.length))
            
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
