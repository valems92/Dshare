import UIKit

class TableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let suggestions = [
        [
            "name": "Dana",
            "distance": "1.5",
            "passangers": "2"
        ],
        [
            "name": "Dan",
            "distance": "1.9",
            "passangers": "1"
        ],
        [
            "name": "Ron",
            "distance": "2",
            "passangers": "0"
        ],
        [
            "name": "Hen",
            "distance": "2",
            "passangers": "2"
        ],
        [
            "name": "Roy",
            "distance": "2.5",
            "passangers": "0"
        ],
        [
            "name": "Avi",
            "distance": "4",
            "passangers": "3"
        ]
    ];
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return suggestions.count;
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "cell");
        
        let suggestion = suggestions[indexPath.row];
        cell.textLabel?.text = suggestion["name"] as String!;
        cell.detailTextLabel?.text = (suggestion["distance"] as String!) + " m , " + (suggestion["passangers"] as String!) + " passangers";
        cell.imageView?.image = UIImage(named: "defaultIcon")
        
        return cell;
    }
    
    /*@IBAction func onCancel(_ sender: UIButton) {
     changeView(_storyboardName: "Main", _viewName: "SearchPage");
     }
     
     @IBAction func onStartChat(_ sender: UIButton) {
     changeView(_storyboardName: "Main", _viewName: "ChatPage");
     }
     
     private func changeView(_storyboardName: String, _viewName: String) {
     let storyBoard = UIStoryboard(name: _storyboardName, bundle: nil);
     let viewController = storyBoard.instantiateViewController(withIdentifier: _viewName);
     
     self.present(viewController, animated: true, completion: nil);
     }*/
}
