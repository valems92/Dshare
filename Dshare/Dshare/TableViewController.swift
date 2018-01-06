import UIKit
import SwiftyJSON
import Alamofire

struct SuggestionData {
    let user:User
    let name:String
    let passangers:Int
    let baggage:Int
    let distance:String
    let image:UIImage?
}

struct UserData {
    let user:User
    let image:UIImage?
}

class SuggestionTableViewCell: UITableViewCell {
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var data: UILabel!
    @IBOutlet weak var suggestionImage: UIImageView!
    
    var user:User?
}

class TableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var chat: UIButton!
    @IBOutlet weak var table: UITableView!
    
    var suggestions: [SuggestionData] = []
    var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    var search:Search!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Utils.instance.initActivityIndicator(activityIndicator: activityIndicator, controller: self)
        chat.isEnabled = false
        chat.alpha = 0.5
        
        getAllMatches()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toSuggestionsFromSearch" {
            var users:[User] = []
            if let nextViewController = segue.destination as? ChatViewController {
                if table.indexPathsForSelectedRows != nil {
                    for rowIndex in table.indexPathsForSelectedRows! {
                        let cell = table.cellForRow(at: rowIndex) as! SuggestionTableViewCell
                        users.append(cell.user!)
                    }
                }
                
                nextViewController.users = users;
            }
        }
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        chat.isEnabled = true
         chat.alpha = 1
    }
    
    public func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if tableView.indexPathsForSelectedRows == nil {
            chat.isEnabled = false
             chat.alpha = 0.5
        }
    }
    
    private func getAllMatches() {
        //activityIndicator.startAnimating()
        //UIApplication.shared.beginIgnoringInteractionEvents()
        
        Model.instance.getAllSearches() {(searches) in
            let allSearchesGroup = DispatchGroup()
            var users = [String : UserData]()

            for suggestion in searches {
                if suggestion.userId == self.search.userId {
                    continue
                }
                
                allSearchesGroup.enter()
                
                let suggestionGroup = DispatchGroup()
                
                var currentUser = users[suggestion.id]
                var distance = "0"
                
                if currentUser == nil {
                    suggestionGroup.enter()
                    Model.instance.getUserById(id: suggestion.userId) {(user) in
                        Model.instance.getImage(urlStr: user.imagePath!, callback: { (image) in
                            users[suggestion.id] = UserData(user: user, image: image)
                            currentUser = users[suggestion.id]
                            
                            suggestionGroup.leave()
                        })
                    }
                }
                
                suggestionGroup.enter()
                self.calcDistance(suggestion:suggestion) {(dis) in
                    distance = dis
                    suggestionGroup.leave()
                }
                
                suggestionGroup.notify(queue: .main) {
                    let data = SuggestionData(user:(currentUser?.user)! ,name: (currentUser?.user.fName)! + " " + (currentUser?.user.lName)!, passangers: suggestion.passengers, baggage: suggestion.baggage, distance: distance, image: currentUser?.image)
                    self.suggestions.append(data)
                    
                    allSearchesGroup.leave()
                }
            }
            
            allSearchesGroup.notify(queue: .main) {
                self.refreshSearches()
            }
        }
    }
    
    func calcDistance(suggestion:Search, callback:@escaping((_ distance:String)->Void))->Void {
        let request = "https://maps.googleapis.com/maps/api/distancematrix/json?origins=place_id:\(self.search.destination)&destinations=place_id:\(suggestion.destination)&key=AIzaSyAdIPtxBw-PUnBZWvjDnCHm_uabxKQVl_s"
        
        Alamofire.request(request).responseJSON { response in
            var distance:String = "0 m"
            if let result = response.result.value {
                let json = JSON(result)
                if json["status"].string == "OK" && json["rows"][0]["elements"][0]["status"].string == "OK" {
                    var element = json["rows"][0]["elements"][0];
                    if element["status"].string == "OK" {
                        distance = element["distance"]["text"].string!
                    }
                }
            }
            callback(distance)
        }
    }
    
    func refreshSearches() {
        table.reloadData()
        //self.activityIndicator.startAnimating()
        //UIApplication.shared.beginIgnoringInteractionEvents()
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return suggestions.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! SuggestionTableViewCell
        
        let suggestion = suggestions[indexPath.row]
        
        cell.name.text = suggestion.name
        cell.suggestionImage?.image = suggestion.image
        cell.data.text = "Distance: " + String(suggestion.distance) + ", Passangers: " + String(suggestion.passangers) + ", Baggage: " + String(suggestion.baggage)
        
        cell.user = suggestion.user
        
        return cell
    }
}
