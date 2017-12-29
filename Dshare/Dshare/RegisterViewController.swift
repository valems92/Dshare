import UIKit

class RegisterViewController: UIViewController,UIPickerViewDataSource, UIPickerViewDelegate {
    let model = UserFirebase()
    var pickerDataSource = ["Male", "Female"]
    
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
        let user = User(email:email.text!, password:password.text!, fName:firstName.text!, lName:lastName.text!, phoneNum:phoneNumber.text!, gender:gender.selectedRow(inComponent: 0).description, imagePath:image.description)
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
