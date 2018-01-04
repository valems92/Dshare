import UIKit

class TableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var table: UITableView!
    
    var suggestions: [Search] = [];
    var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView();
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        Utils.instance.initActivityIndicator(activityIndicator: activityIndicator, controller: self);
        activityIndicator.startAnimating();
        UIApplication.shared.beginIgnoringInteractionEvents();
        
        getAllSearches();
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private func getAllSearches() {
        Model.instance.getAllSearches() {(searches) in
            self.activityIndicator.stopAnimating();
            UIApplication.shared.endIgnoringInteractionEvents();
            
            self.suggestions = searches;
            self.refreshSearches();
        }
    }
    
    func refreshSearches() {
        table.reloadData();
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return suggestions.count;
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "cell");
        
        let suggestion = suggestions[indexPath.row];
        let userId = suggestion.userId;
        
        var distance = 0;
        cell.textLabel?.text = "user name";
        cell.detailTextLabel?.text = "Distance: " + String(distance) + ", Passangers: " + String(suggestion.passengers) + ", Baggage: " + String(suggestion.baggage);
        cell.imageView?.image = UIImage(named: "defaultIcon")
        
        return cell;
    }
}
