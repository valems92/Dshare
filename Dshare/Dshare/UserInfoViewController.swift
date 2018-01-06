import UIKit

class UserInfoViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource {
    var user:User?
    var searches:[Search]?
    var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    
    let genderOptions = ["Male", "Female"]
    
    @IBOutlet weak var fName: UITextField!
    @IBOutlet weak var lName: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var phoneNum: UITextField!
    @IBOutlet weak var newPassword: UITextField!
    @IBOutlet weak var searchesTableView: UITableView!
    @IBOutlet weak var genderPickerView: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        genderPickerView.dataSource = self
        genderPickerView.delegate = self
        
        newPassword.isSecureTextEntry = true
        Model.instance.getCurrentUser() {(user) in
            if user != nil{
                self.user = user
                self.updateAllTextFields(user: user)
            }
        }
        Model.instance.getCorrentUserSearches() {(error, searches) in
            if error != nil {
                self.searches = searches
                self.searchesTableView.reloadData()
            }
        }
        Utils.instance.initActivityIndicator(activityIndicator: activityIndicator, controller: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func submitNewInfo(_ sender: Any) {
        let isEmailAddressValid = isValidEmailAddress(emailAddressString: email.text!)
        if !isEmailAddressValid {
            Utils.instance.displayAlertMessage(messageToDisplay:"Email address is not valid", controller:self)
        }
        let isPhoneNumberValid = isValidPhoneNumber(phoneNumberString: phoneNum.text!)
        if !isPhoneNumberValid {
            Utils.instance.displayAlertMessage(messageToDisplay:"Phone number is not valid", controller:self)
        }
        
        Model.instance.updateUserInfo(fName: self.fName.text!, lName: self.lName.text!, email: self.email.text!, phoneNum: self.phoneNum.text!, gender: genderPickerView.selectedRow(inComponent: 0).description)
        Model.instance.getCurrentUser() {(user) in
            if user != nil{
                self.user = user
                self.updateAllTextFields(user: user)
            }
        }
    }
    
    @IBAction func submitNewPassword(_ sender: Any) {
        let isPasswordValid = isValidPassword(passwordString: newPassword.text!)
        if !isPasswordValid {
            Utils.instance.displayAlertMessage(messageToDisplay:"Password must contains at least 6 characters", controller:self)
        }
        else {
          Model.instance.updatePassword(newPassword: self.newPassword.text!)
        }
    }
    
    @IBAction func logOutUser(_ sender: UIButton) {
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
    
    func updateAllTextFields(user:User){
        self.fName.text = user.fName
        self.lName.text = user.lName
        self.email.text = user.email
        self.phoneNum.text = user.phoneNum
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searches != nil {
            return (searches?.count)!
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if searches != nil {
            let cell = UITableViewCell(style:UITableViewCellStyle.default, reuseIdentifier:"cell")
            cell.textLabel?.text = searches?[indexPath.row].destination
            return cell
        }
        return UITableViewCell.init()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return genderOptions.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return genderOptions[row]
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
    
    func isValidPassword(passwordString:String) -> Bool {
        var returnValue = true
        let passwordRegEx = "^.{6,}$"
        
        do {
            let regex = try NSRegularExpression(pattern: passwordRegEx)
            let nsString = passwordString as NSString
            let results = regex.matches(in: passwordString, range: NSRange(location: 0, length: nsString.length))
            
            if results.count == 0 {
                returnValue = false
            }
        } catch let error as NSError {
            print("invalud regex: \(error.localizedDescription)")
            returnValue = false
        }
        
        return returnValue
    }

}
