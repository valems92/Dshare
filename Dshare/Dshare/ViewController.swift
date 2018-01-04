import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    var locationManager: CLLocationManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
    }
    
    /*override func viewDidAppear(_ animated: Bool) {
        
        if let alreadySignedIn = FIRAuth.auth()?.currentUser {
            // segue to main view controller
        } else {
            // sign in
        }
    }*/

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
