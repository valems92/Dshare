import UIKit

class LastSearchesViewCell: UITableViewCell {
    @IBOutlet weak var destination: UILabel!
    @IBOutlet weak var startPoint: UILabel!
    @IBOutlet weak var icon: UIImageView!
    
    var search:Search?
}

class UserInfoViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource {
    var user:User?
    
    var searches:[Search]?
    var selectedSearch:Search?
    var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect(x:0, y:100, width:50, height:50))
    var observerId:Any?
    
    let genderOptions = ["Male", "Female"]
    
    @IBOutlet weak var fName: UITextField!
    @IBOutlet weak var lName: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var phoneNum: UITextField!
    @IBOutlet weak var newPassword: UITextField!
    @IBOutlet weak var searchesTableView: UITableView!
    @IBOutlet weak var genderPickerView: UIPickerView!
    
    @IBOutlet weak var lastUpdatedlabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Utils.instance.initActivityIndicator(activityIndicator: activityIndicator, controller: self)
        activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents() //When the activity indicator presents, the user can't interact with the app
        
        genderPickerView.dataSource = self
        genderPickerView.delegate = self
        
        newPassword.isSecureTextEntry = true
        
        Model.instance.getCurrentUser() {(user) in
            self.user = user
            self.updateAllTextFields(user: user)
            self.genderPickerView.selectRow(Int((self.user?.gender)!)!, inComponent: 0, animated: true)
            let lastUpdate = Model.instance.getLastUpdateFromLocalDB(username: user.fName + " " + user.lName)
            self.lastUpdatedlabel.text = "last updated at: " + lastUpdate.stringValue
            Model.instance.getCorrentUserSearches() {(error, searches) in
                if error == nil {
                    self.searches = searches
                    self.searchesTableView.reloadData()
                    self.stopAnimatingActivityIndicator()
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        observerId = ModelNotification.SearchUpdate.observe(callback: { (suggestionsId, params) in
            Utils.instance.currentUserSearchChanged(suggestionsId: suggestionsId!, searchId: params as! String, controller: self)
        })
        
        Model.instance.startObserveCurrentUserSearches()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if observerId != nil {
            ModelNotification.removeObserver(observer: observerId!)
            observerId = nil
        }
        
        Model.instance.clear()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func validateTextFieldsInput() -> Bool {
        let isEmailAddressValid = Utils.instance.isValidEmailAddress(emailAddressString: email.text!)
        if !isEmailAddressValid {
            Utils.instance.displayAlertMessage(messageToDisplay:"Email address is not valid", controller:self)
            return false
        }
        let isPhoneNumberValid = Utils.instance.isValidPhoneNumber(phoneNumberString: phoneNum.text!)
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
        if (phoneNum.text?.isEmpty)! {
            Utils.instance.displayAlertMessage(messageToDisplay:"You have to enter your first name", controller:self)
            return false
        }
        return true
    }
    
    @IBAction func submitNewInfo(_ sender: Any) {
        if self.validateTextFieldsInput() == true {
            Model.instance.updateUserInfo(fName: self.fName.text!, lName: self.lName.text!, email: self.email.text!, phoneNum: self.phoneNum.text!, gender: genderPickerView.selectedRow(inComponent: 0).description) { (error) in
                if error == nil {
                    let username = self.fName.text! + " " + self.lName.text!
                    var currentDate:Date?
                    currentDate = Date()
                    Model.instance.setLastUpdateToLocalDB(username: username, lastUpdate: currentDate!)
                    
                    print(Model.instance.getLastUpdateFromLocalDB(username: username))
                    
                    Model.instance.getCurrentUser() {(user) in
                        if user != nil{
                            self.user = user
                            self.updateAllTextFields(user: user)
                            let lastUpdate = Model.instance.getLastUpdateFromLocalDB(username: user.fName + " " + user.lName)
                            self.lastUpdatedlabel.text = "last updated at: " + lastUpdate.stringValue
                            Utils.instance.displayMessageToUser(messageToDisplay:"Your changes has been saved", controller:self)
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func submitNewPassword(_ sender: Any) {
        let isPasswordValid = Utils.instance.isValidPassword(passwordString: newPassword.text!)
        if !isPasswordValid {
            Utils.instance.displayAlertMessage(messageToDisplay:"Password must contains at least 6 characters", controller:self)
        }
        else {
            Model.instance.updatePassword(newPassword: self.newPassword.text!) { (error) in
                if error == nil {
                    let username = (self.user?.fName)! + " " + (self.user?.lName)!
                    var currentDate:Date?
                    currentDate = Date()
                    Model.instance.setLastUpdateToLocalDB(username: username, lastUpdate: currentDate!)
                    print(Model.instance.getLastUpdateFromLocalDB(username: username))
                    let lastUpdate = Model.instance.getLastUpdateFromLocalDB(username: (self.user?.fName)! + " " + (self.user?.lName)!)
                    self.lastUpdatedlabel.text = "last updated at: " + lastUpdate.stringValue
                    Utils.instance.displayMessageToUser(messageToDisplay:"Your changes has been saved", controller:self)
                }
                else {
                    if error?.localizedDescription == "This operation is sensitive and requires recent authentication. Log in again before retrying this request." {
                        self.displaySignInAlertMessage(title:"You have to sign in again first")
                    }
                }
            }
        }
    }
    
    func displaySignInAlertMessage(title:String) {
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (_) in
            let email = alert.textFields?[0].text
            let password = alert.textFields?[1].text
            
            Model.instance.signOutUser(){ (error) in
                Model.instance.signInUser(email: email!, password: password!) { (error) in
                    if error != nil {
                        self.displaySignInAlertMessage(title:"Error! please try to sign in again")
                    }
                }
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) { (_) in
            //Do nothing
        }
        
        alert.addTextField() { (textField) in
            textField.placeholder = "e-mail"
        }
        
        alert.addTextField() { (textField) in
            textField.placeholder = "password"
            textField.isSecureTextEntry = true
        }
        
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
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
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if searches != nil {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! LastSearchesViewCell
            let search = searches?[indexPath.row]
        
            cell.destination.text = search?.destinationAddress
            cell.startPoint.text = search?.startingPointAddress
            cell.search = search
            
            if search?.foundSuggestion == false {
                cell.icon?.image = UIImage(named: "x")
            } else {
                cell.icon?.image = UIImage(named: "v")
            }
            
            return cell
        }
        
        return UITableViewCell.init()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedSearch = searches?[indexPath.row]
        if self.selectedSearch?.foundSuggestion == false {
            self.performSegue(withIdentifier: "toSuggestionsFromUserInfo", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toSuggestionsFromUserInfo" {
            if let nextViewController = segue.destination as? TableViewController {
                nextViewController.search = self.selectedSearch;
            }
        }
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
}
