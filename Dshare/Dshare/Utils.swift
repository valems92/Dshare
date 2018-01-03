import Foundation
import UIKit

class Utils {
    static let instance = Utils();
    
    func initActivityIndicator(activityIndicator:UIActivityIndicatorView, controller:UIViewController) {
        activityIndicator.center = controller.view.center;
        activityIndicator.hidesWhenStopped = true;
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray;
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
