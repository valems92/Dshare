import UIKit

class LastSearchesViewCell: UITableViewCell {
//    @IBOutlet weak var destination: UILabel!
//    @IBOutlet weak var startPoint: UILabel!
//    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var destination: UILabel!
    @IBOutlet weak var startPoint: UILabel!
    @IBOutlet weak var icon: UIImageView!
    
    var search:Search?
}

class UserSearchHistoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var user:User?
    
    var searches:[Search]?
    var selectedSearch:Search?
    var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect(x:0, y:100, width:50, height:50))
    var observerId:Any?
    
    let genderOptions = ["Male", "Female"]

    @IBOutlet weak var searchesTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Utils.instance.initActivityIndicator(activityIndicator: activityIndicator, controller: self)
        activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents() //When the activity indicator presents, the user can't interact with the app
        
        Model.instance.getCurrentUser() {(user) in
            self.user = user
            Model.instance.getCorrentUserSearches() {(error, searches) in
                if error == nil {
                    self.searches = searches
                    self.searchesTableView.reloadData()
                    self.stopAnimatingActivityIndicator()
                    if self.searches?.count == 0 {
                        self.searchesTableView.alpha = 0
                        self.alertNoSearches()
                    }
                }
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        observerId = ModelNotification.SearchUpdate.observe(callback: { (suggestionsId, params) in
            Utils.instance.currentUserSearchChanged(suggestionsId: suggestionsId!, searchId: params as! String, controller: self)
        })
        
        Model.instance.startObserveCurrentUserSearches()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if observerId != nil {
            ModelNotification.removeObserver(observer: observerId!)
            observerId = nil
        }
        
        Model.instance.clear()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func alertNoSearches(){
        let alertController = UIAlertController(title:"", message: "Oops! There are no recent searches to show", preferredStyle:.alert)
        let OKAction = UIAlertAction(title:"OK", style:.default) { (action:UIAlertAction!) in
            //print("OK tapped");
            self.navigationController?.popViewController(animated: true)
        }
        alertController.addAction(OKAction)
        self.present(alertController, animated:true, completion:nil)
    }
    
    func stopAnimatingActivityIndicator() {
        activityIndicator.stopAnimating()
        UIApplication.shared.endIgnoringInteractionEvents()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searches != nil {
            return (searches?.count)!
        }
        return 0
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if searches != nil {
            let cell = tableView.dequeueReusableCell(withIdentifier: "specialCell", for: indexPath) as! LastSearchesViewCell
            let search = searches?[indexPath.row]
            
            cell.destination.text = search?.destinationAddress
            cell.startPoint.text = search?.startingPointAddress
            cell.search = search
            
            if search?.foundSuggestion == false {
                cell.icon?.image = UIImage(named: "x")
            } else {
                cell.icon?.image = UIImage(named: "v")
            }
            
            return cell
        }
        
        return UITableViewCell.init()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedSearch = searches?[indexPath.row]
        if self.selectedSearch?.foundSuggestion == false {
            self.performSegue(withIdentifier: "toSuggestionsFromUserSearchHistory", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toSuggestionsFromUserSearchHistory" {
            if let nextViewController = segue.destination as? TableViewController {
                nextViewController.search = self.selectedSearch;
            }
        }
    }
}

