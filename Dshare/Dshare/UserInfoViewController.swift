import UIKit

class UserInfoViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
   
    var user:User?
    var searches:[Search]?
    var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    
    @IBOutlet weak var fName: UITextField!
    @IBOutlet weak var lName: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var gender: UITextField!
    @IBOutlet weak var phoneNum: UITextField!
    @IBOutlet weak var newPassword: UITextField!
    @IBOutlet weak var searchesTableView: UITableView!
    
   
    override func viewDidLoad() {
        super.viewDidLoad()
        newPassword.isSecureTextEntry = true
        Model.instance.getCurrentUser() {(user) in
            if user != nil{
                self.user = user
                self.updateAllTextFields(user: user)
            }
        }
        Model.instance.getCorrentUserSearches() {(error, searches) in
            self.searches = searches
            self.searchesTableView.reloadData()
        }
        Utils.instance.initActivityIndicator(activityIndicator: activityIndicator, controller: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func submitNewInfo(_ sender: Any) {
        Model.instance.updateUserInfo(fName: self.fName.text!, lName: self.lName.text!, email: self.email.text!, phoneNum: self.phoneNum.text!, gender: self.gender.text!)
        Model.instance.getCurrentUser() {(user) in
            if user != nil{
                self.user = user
                self.updateAllTextFields(user: user)
            }
        }
    }
    
    @IBAction func submitNewPassword(_ sender: Any) {
          Model.instance.updatePassword(newPassword: self.newPassword.text!)
    }
    
    @IBAction func logOutUser(_ sender: UIButton) {
        //Set activity indicator
        activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents() //When the activity indicator presents, the user can't interact with the app
        Model.instance.signOutUser() { (error) in
            if error != nil {
                self.stopAnimatingActivityIndicator()
                Utils.instance.displayAlertMessage(messageToDisplay:(error?.localizedDescription)!, controller:self)
            }
            else {
                self.stopAnimatingActivityIndicator()
                // User logged out succesfully, move to login page
                //self.performSegue(withIdentifier: "toHomeFromUserInfo", sender: self)
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
        self.gender.text = user.gender
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

}
