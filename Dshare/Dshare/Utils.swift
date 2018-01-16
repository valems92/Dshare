import Foundation
import UIKit

class Utils {
    static let instance = Utils();
    public let defaultIconUrl = "https://firebasestorage.googleapis.com/v0/b/dshare-ac2cb.appspot.com/o/defaultIcon.png?alt=media&token=c72d96c9-f431-4fe6-968e-54df749475cf"
    
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
    
    func displayMessageToUser(messageToDisplay:String, controller:UIViewController){
        let alertController = UIAlertController(title:"", message:messageToDisplay, preferredStyle:.alert);
        let OKAction = UIAlertAction(title:"OK", style:.default) { (action:UIAlertAction!) in
            print("OK tapped");
        }
        alertController.addAction(OKAction);
        controller.present(alertController, animated:true, completion:nil);
    }
    
    func currentUserSearchChanged(suggestionsId:[String], controller:UIViewController) {
        let alertController = UIAlertController(title:"Message", message:"A match was found for one of your searches!", preferredStyle:.alert);
        let OKAction = UIAlertAction(title:"Open Chat", style:.default) { (action:UIAlertAction!) in
            let storyBoard = UIStoryboard(name: "Main", bundle: nil);
            let viewController = storyBoard.instantiateViewController(withIdentifier: "ChatPage") as! ChatViewController;
            
            viewController.users = suggestionsId
            viewController.senderId = Model.instance.getCurrentUserUid()
            
            controller.navigationController!.pushViewController(viewController, animated: true)
            //controller.present(viewController, animated: true, completion: nil);
        }
        alertController.addAction(OKAction)
        controller.present(alertController, animated:true, completion:nil)
    }
    
    func isValidEmailAddress(emailAddressString:String) -> Bool {
        var returnValue = true
        let emailRegEx = "[A-Z0-9a-z.-_]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,3}"
        
        do {
            let regex = try NSRegularExpression(pattern: emailRegEx)
            let nsString = emailAddressString as NSString
            let results = regex.matches(in: emailAddressString, range: NSRange(location: 0, length: nsString.length))
            
            if results.count == 0 {
                returnValue = false
            }
        } catch let error as NSError {
            print("invalud regex: \(error.localizedDescription)")
            returnValue = false
        }
        
        return returnValue
    }
    
    func isValidPhoneNumber(phoneNumberString:String) -> Bool {
        var returnValue = true
        let phoneRegEx = "^[0-9]{10}$"
        
        do {
            let regex = try NSRegularExpression(pattern: phoneRegEx)
            let nsString = phoneNumberString as NSString
            let results = regex.matches(in: phoneNumberString, range: NSRange(location: 0, length: nsString.length))
            
            if results.count == 0 {
                returnValue = false
            }
        } catch let error as NSError {
            print("invalud regex: \(error.localizedDescription)")
            returnValue = false
        }
        
        return returnValue
    }
    
    func isValidPassword(passwordString:String) -> Bool {
        var returnValue = true
        let passwordRegEx = "^.{6,}$"
        
        do {
            let regex = try NSRegularExpression(pattern: passwordRegEx)
            let nsString = passwordString as NSString
            let results = regex.matches(in: passwordString, range: NSRange(location: 0, length: nsString.length))
            
            if results.count == 0 {
                returnValue = false
            }
        } catch let error as NSError {
            print("invalud regex: \(error.localizedDescription)")
            returnValue = false
        }
        
        return returnValue
    }
}
