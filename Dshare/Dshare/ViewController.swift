import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    var locationManager: CLLocationManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        checkIfUserLoggedIn()
    }
    
    @IBAction func unwindSegue(_ sender:UIStoryboardSegue){
        
    }
    
    /*override func viewDidAppear(_ animated: Bool) {
        
        if let alreadySignedIn = FIRAuth.auth()?.currentUser {
            // segue to main view controller
        } else {
            // sign in
        }
    }*/
    
    func checkIfUserLoggedIn() {
        Model.instance.checkIfUserLoggedIn() {(isUserLoggedIn) in
            if isUserLoggedIn! {
                self.performSegue(withIdentifier: "toSearchFromHome", sender: self)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
