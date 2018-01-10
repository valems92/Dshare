import UIKit
import CoreLocation

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
    var suggestions = [String : SuggestionData]()
    var search:Search!

    var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    
    let MAX_KM_DISTANCE_DESTINATION:Double = 10000000
    let MAX_KM_DISTANCE_STARTING_POINT:Double = 1000000
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        enabledChatBtn(false)
        getAllSuggestions()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        Model.instance.stopObserveSearches()
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
        enabledChatBtn(true)
    }
    
    public func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if tableView.indexPathsForSelectedRows == nil {
            enabledChatBtn(false)
        }
    }
    
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.contentView.backgroundColor = (indexPath.row % 2 == 0) ? UIColor(red: 1, green: 0.9608, blue: 0.9569, alpha: 1.0) : UIColor.white
    }
    
    private func enabledChatBtn(_ isEnabled:Bool) {
        chat.isEnabled = isEnabled
        chat.alpha = (isEnabled) ? 1 : 0.5
    }
    
    public func searchesChanged(search:Search?, status:String) {
        if search != nil {
            switch (status) {
            case "Added":
                if suggestions[search!.id] == nil {
                    self.addSuggestionOnListening(search!)
                }
                break;
            case "Removed":
                if self.suggestions[search!.id] != nil {
                    self.suggestions.removeValue(forKey: search!.id)
                    self.table.reloadData()
                }
                break;
            default:
                if suggestions[search!.id] != nil && search!.foundSuggestion {
                    self.suggestions.removeValue(forKey: search!.id)
                    self.table.reloadData()
                } else if suggestions[search!.id] == nil && search!.foundSuggestion == false {
                    self.addSuggestionOnListening(search!)
                }
                break;
            }
        }
    }
    
    private func addSuggestionOnListening(_ search:Search) {
        self.addSuggestion(search, nil)
        suggestions[search.id]?.userData = usersData[search.userId]
        self.table.reloadData()
    }
    
    private func getAllSuggestions() {
        Model.instance.getAllSearches() {(searches) in
            let group = DispatchGroup()
            for suggestion in searches {
                self.addSuggestion(suggestion, group)
            }
            
            group.notify(queue: .main) {
                self.setSuggestionsUserData()
                self.table.reloadData()
                
                Model.instance.startObserveSearches(callback: self.searchesChanged)
            }
        }
    }
    
    private func setSuggestionsUserData() {
        for (suggestionId, suggestionData) in suggestions {
            suggestions[suggestionId]?.userData = usersData[suggestionData.userId]
        }
    }
    
    private func addSuggestion(_ suggestion:Search, _ group:DispatchGroup?)->Void {
        if suggestion.userId == self.search.userId ||  suggestion.foundSuggestion { return }
        
        let destDistance = self.calcDistance(suggestion.destinationCoordinate)
        let stDistance = self.calcDistance(suggestion.startingPointCoordinate)
        
        if (destDistance > self.MAX_KM_DISTANCE_DESTINATION || stDistance > self.MAX_KM_DISTANCE_STARTING_POINT) { return }
        
        group?.enter()
        self.suggestions[suggestion.id] = SuggestionData(userId: suggestion.userId, search: suggestion, distance: destDistance, userData: nil)
        
        if self.usersData[suggestion.userId] == nil {
            self.usersData[suggestion.userId] = UserData()
            Model.instance.getUserById(id: suggestion.userId) {(user) in
                Model.instance.getImage(urlStr: user.imagePath!, callback: { (image) in
                    self.usersData[suggestion.userId]?.user = user
                    self.usersData[suggestion.userId]?.image = image
                    
                    group?.leave()
                })
            }
        } else {
            group?.leave()
        }
    }
    
    private func calcDistance(_ coordinate:CLLocationCoordinate2D)->Double {
        let searchLocation = CLLocation(latitude: search.destinationCoordinate.latitude, longitude: search.destinationCoordinate.longitude)
        let suggestionLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        return (searchLocation.distance(from: suggestionLocation) / 1000)
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return suggestions.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! SuggestionTableViewCell
        
        let suggestion = suggestions[Array(suggestions.keys)[indexPath.row]]!
        
        cell.name.text = suggestion.userData!.user!.fName + " " + suggestion.userData!.user!.lName
        cell.suggestionImage?.image = suggestion.userData?.image
        cell.data.text = "Distance: " + String(format: "%.2f", suggestion.distance) + " km, Passangers: " + String(suggestion.search.passengers) + ", Baggage: " + String(suggestion.search.baggage)
        cell.user = suggestion.userData?.user
        
        return cell
    }
}
