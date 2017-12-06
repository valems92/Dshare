import UIKit

class LoadingViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let when = DispatchTime.now() + 2;
        DispatchQueue.main.asyncAfter(deadline: when) {
            let storyBoard = UIStoryboard(name: "Main", bundle: nil);
            let viewController = storyBoard.instantiateViewController(withIdentifier: "SuggestionsPage");
            
            self.present(viewController, animated: true, completion: nil);
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
