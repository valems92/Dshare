import Foundation
import UIKit

class Utils {
    static let instance = Utils();
    
    func initActivityIndicator(activityIndicator:UIActivityIndicatorView, controller:UIViewController) {
        activityIndicator.center = controller.view.center;
        activityIndicator.backgroundColor = UIColor(red: 191.0/255.0, green:191.0/255.0, blue:191.0/255.0, alpha:1.0)
        activityIndicator.layer.cornerRadius = 10
        activityIndicator.hidesWhenStopped = true;
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.white;
        controller.view.addSubview(activityIndicator);
    }
    
    func displayAlertMessage(messageToDisplay:String, controller:UIViewController){
        let alertController = UIAlertController(title:"Error", message:messageToDisplay, preferredStyle:.alert);
        let OKAction = UIAlertAction(title:"OK", style:.default) { (action:UIAlertAction!) in
            print("OK tapped");
        }
        alertController.addAction(OKAction);
        controller.present(alertController, animated:true, completion:nil);
    }
}
