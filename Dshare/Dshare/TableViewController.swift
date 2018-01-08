import UIKit
import CoreLocation
import SwiftyJSON
import Alamofire

struct UserData {
    var user:User?
    var image:UIImage?
}

struct SuggestionData {
    var userId:String
    var search:Search
    var distance:Double
    var userData:UserData?
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
    
    var usersData = [String : UserData]()
    var suggestions: [SuggestionData] = []
    var search:Search!
    
    var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    
    let MAX_KM_DISTANCE_DESTINATION:Double = 10000
    let MAX_KM_DISTANCE_STARTING_POINT:Double = 100
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        Model.instance.getAllSearches() {(searches) in
            
            let group = DispatchGroup()
            for suggestion in searches {
                if suggestion.userId == self.search.userId ||  suggestion.foundSuggestion { continue }
        
                let destDistance = self.calcDestinationDistance(suggestion:suggestion)
                let stDistance = self.calcStartingPointDistance(suggestion:suggestion)
                if (destDistance > self.MAX_KM_DISTANCE_DESTINATION || stDistance > self.MAX_KM_DISTANCE_STARTING_POINT) { continue }
                
                group.enter()
                self.suggestions.append(SuggestionData(userId: suggestion.userId, search: suggestion, distance: destDistance, userData: nil))
        
                if self.usersData[suggestion.userId] == nil {
                    self.usersData[suggestion.userId] = UserData()
                    Model.instance.getUserById(id: suggestion.userId) {(user) in
                        Model.instance.getImage(urlStr: user.imagePath!, callback: { (image) in
                            self.usersData[suggestion.userId]?.user = user
                            self.usersData[suggestion.userId]?.image = image
                            group.leave()
                        })
                    }
                } else {
                    group.leave()
                }
            }
            
            group.notify(queue: .main) {
                self.setSuggestionsUserData()
                self.table.reloadData()
            }
        }
    }
    
    private func setSuggestionsUserData() {
        for i in 0...suggestions.count - 1 {
            suggestions[i].userData = usersData[suggestions[i].userId]
        }
    }
    
    func calcDestinationDistance(suggestion:Search)->Double {
        let searchLocation = CLLocation(latitude: self.search.destinationCoordinate.latitude, longitude: self.search.destinationCoordinate.longitude)
        let suggestionLocation = CLLocation(latitude: suggestion.destinationCoordinate.latitude, longitude: suggestion.destinationCoordinate.longitude)
        
        //distance in km
        return (searchLocation.distance(from: suggestionLocation) / 1000)
    }
    
    func calcStartingPointDistance(suggestion:Search)->Double {
        let searchLocation = CLLocation(latitude: self.search.startingPointCoordinate.latitude, longitude: self.search.startingPointCoordinate.longitude)
        let suggestionLocation = CLLocation(latitude: suggestion.startingPointCoordinate.latitude, longitude: suggestion.startingPointCoordinate.longitude)
        
        //distance in km
        return (searchLocation.distance(from: suggestionLocation) / 1000)
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return suggestions.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! SuggestionTableViewCell
        
        let suggestion = suggestions[indexPath.row]
        
        cell.name.text = suggestion.userData!.user!.fName + " " + suggestion.userData!.user!.lName
        cell.suggestionImage?.image = suggestion.userData?.image
        cell.data.text = "Distance: " + String(format: "%.2f", suggestion.distance) + " km, Passangers: " + String(suggestion.search.passengers) + ", Baggage: " + String(suggestion.search.baggage)
        cell.user = suggestion.userData?.user
        
        return cell
    }
}
