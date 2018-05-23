import UIKit

class UserDetailsViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var fName: UITextField!
    @IBOutlet weak var lName: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var phone: UITextField!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var genderPickerView: UIPickerView!
    
    var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect(x:0, y:100, width:50, height:50))
    let genderOptions = ["Male", "Female"]
    var user:User?
    var userImage:UIImage?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Utils.instance.initActivityIndicator(activityIndicator: activityIndicator, controller: self)
        activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents() //When the activity indicator presents, the user can't interact with the app
        
        genderPickerView.dataSource = self
        genderPickerView.delegate = self
        
        Model.instance.getCurrentUser() {(user) in
            self.user = user
            self.updateAllTextFields(user: user)
            self.genderPickerView.selectRow(Int((self.user?.gender)!)!, inComponent: 0, animated: true)
            self.stopAnimatingActivityIndicator()
        }
    }
    
    func validateTextFieldsInput() -> Bool {
        let isEmailAddressValid = Utils.instance.isValidEmailAddress(emailAddressString: email.text!)
        if !isEmailAddressValid {
            Utils.instance.displayAlertMessage(messageToDisplay:"Email address is not valid", controller:self)
            return false
        }
        let isPhoneNumberValid = Utils.instance.isValidPhoneNumber(phoneNumberString: phone.text!)
        if !isPhoneNumberValid {
            Utils.instance.displayAlertMessage(messageToDisplay:"Phone number is not valid", controller:self)
            return false
        }
        if (fName.text?.isEmpty)! {
            Utils.instance.displayAlertMessage(messageToDisplay:"You have to enter your first name", controller:self)
            return false
        }
        if (lName.text?.isEmpty)! {
            Utils.instance.displayAlertMessage(messageToDisplay:"You have to enter your first name", controller:self)
            return false
        }
        if (phone.text?.isEmpty)! {
            Utils.instance.displayAlertMessage(messageToDisplay:"You have to enter your first name", controller:self)
            return false
        }
        return true
    }
    
    func updateUserInfo(error:Error?){
        if error == nil {
            let username = self.fName.text! + " " + self.lName.text!
            var currentDate:Date?
            currentDate = Date()
            Model.instance.getCurrentUser() {(user) in
                if user != nil{
                    self.user = user
                    self.updateAllTextFields(user: user)
                    Utils.instance.displayMessageToUser(messageToDisplay:"Your changes has been saved", controller:self)
                }
            }
        }
    }
    
    func stopAnimatingActivityIndicator() {
        activityIndicator.stopAnimating()
        UIApplication.shared.endIgnoringInteractionEvents()
    }
    
    func updateAllTextFields(user:User){
        self.fName.text = user.fName
        self.lName.text = user.lName
        self.email.text = user.email
        self.phone.text = user.phoneNum
        if user.imagePath != "https://firebasestorage.googleapis.com/v0/b/dsharefinalproject.appspot.com/o/defaultIcon.png?alt=media&token=0c2f430f-0b38-4ff0-8853-736c96f357db" { // If the user has a photo
            Model.instance.getImage(urlStr: user.imagePath!, callback: { (image) in
                self.image.image = image
            })
        }
    }
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]){
        userImage = info["UIImagePickerControllerOriginalImage"] as! UIImage
        self.image.image = userImage
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func changePhoto(_ sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(.camera) || UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            let controller = UIImagePickerController()
            controller.delegate = self
            present(controller, animated: true, completion: nil)
        }
    }
    
    @IBAction func submitChanges(_ sender: UIButton) {
        if self.validateTextFieldsInput() == true {
            if userImage != nil { // User changed his photo
                Model.instance.saveImage(image: userImage!, name: (user?.id)!){(url) in
                    self.user?.imagePath = url
                    Model.instance.updateUserInfoWithPhoto(fName: self.fName.text!, lName: self.lName.text!, email: self.email.text!, phoneNum: self.phone.text!, gender: self.genderPickerView.selectedRow(inComponent: 0).description, imagePath: url!) { (error) in
                        self.updateUserInfo(error: error)
                    }
                }
            } else { // User didn't change his photo
                Model.instance.updateUserInfo(fName: self.fName.text!, lName: self.lName.text!, email: self.email.text!, phoneNum: self.phone.text!, gender: self.genderPickerView.selectedRow(inComponent: 0).description) { (error) in
                    self.updateUserInfo(error: error)
                }
            }
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return genderOptions.count
    }
    
//    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
//        return genderOptions[row]
//    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let attributedString = NSAttributedString(string: genderOptions[row], attributes: [NSForegroundColorAttributeName : UIColor.white])
        return attributedString
    }
    
}
