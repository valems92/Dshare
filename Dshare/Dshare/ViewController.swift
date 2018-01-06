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

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        checkIfUserLoggedIn()
    }
    
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
