import UIKit

class SearchViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.setHidesBackButton(true, animated: false);
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    /*@IBAction func onSearch(_ sender: UIButton) {
     let storyBoard = UIStoryboard(name: "Main", bundle: nil);
     let viewController = storyBoard.instantiateViewController(withIdentifier: "LoadingPage");
     
     self.present(viewController, animated: true, completion: nil);
     }*/
}
