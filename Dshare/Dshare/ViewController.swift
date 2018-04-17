import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    var locationManager: CLLocationManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
//        let navBar = self.navigationController?.navigationBar
//        navBar?.backgroundColor = UIColor(red: 255.0/255.0, green:245.0/255.0, blue:238.0/255.0, alpha:1.0)
//        navBar?.tintColor = UIColor.black
        
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        checkIfUserLoggedIn()
        
        // Hide the navigation bar on the this view controller
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    func checkIfUserLoggedIn() {
        Model.instance.checkIfUserLoggedIn() {(isUserLoggedIn) in
            if isUserLoggedIn! {
                self.performSegue(withIdentifier: "toSearchFromHome", sender: self)
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Show the navigation bar on other view controllers
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
