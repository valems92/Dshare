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
