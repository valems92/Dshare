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
}

class SuggestionTableViewCell: UITableViewCell {
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var data: UILabel!
    @IBOutlet weak var suggestionImage: UIImageView!
    
    var user:User?
    var search:Search?
}

class TableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var chat: UIButton!
    @IBOutlet weak var table: UITableView!
    
    var usersData = [String : UserData]()
    var suggestions = [String : SuggestionData]()
    var sortedSuggestions:[SuggestionData]?
    var search:Search!

    var suggestionUpdateObserverId:Any?
    var searchUpdateObserverId:Any?
    var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    
    let MAX_KM_DISTANCE_DESTINATION:Double = 10
    let MAX_KM_DISTANCE_STARTING_POINT:Double = 5
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.hidesBackButton = false
        
        Utils.instance.initActivityIndicator(activityIndicator: activityIndicator, controller: self)
        activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        enabledChatBtn(false)
        getAllSuggestions()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        suggestionUpdateObserverId = ModelNotification.SuggestionsUpdate.observe(callback: self.searchesChanged)
        
        searchUpdateObserverId = ModelNotification.SearchUpdate.observe(callback: { (suggestionsId, params) in
            Utils.instance.currentUserSearchChanged(suggestionsId: suggestionsId!, searchId: params as! String, controller: self)
        })
        
        Model.instance.startObserveCurrentUserSearches()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        clear()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func clear() {
        if suggestionUpdateObserverId != nil {
            ModelNotification.removeObserver(observer: suggestionUpdateObserverId!)
            suggestionUpdateObserverId = nil
        }
        
        if searchUpdateObserverId != nil {
            ModelNotification.removeObserver(observer: searchUpdateObserverId!)
            searchUpdateObserverId = nil
        }
        
        Model.instance.clear()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toSuggestionsFromSearch" {
            var users:[String] = []
            var searches:[Search] = []
        
            if let nextViewController = segue.destination as? ChatViewController {
                if table.indexPathsForSelectedRows != nil {
                    for rowIndex in table.indexPathsForSelectedRows! {
                        let cell = table.cellForRow(at: rowIndex) as! SuggestionTableViewCell
                        searches.append(cell.search!)
                        users.append(cell.user!.id)
                    }
                }
                
                let cuurentUserId = Model.instance.getCurrentUserUid()
                nextViewController.users = users;
                nextViewController.senderId = cuurentUserId
                
                self.clear()
                 Model.instance.updateSearch(searchId: self.search.id, value: ["foundSuggestion": true])
                
                users.append(cuurentUserId)
                
                for i in 0...searches.count - 1 {
                    let s = searches[i]
                    Model.instance.updateSearch(searchId: s.id, value: ["foundSuggestion": true, "suggestionsId": users.filter({ (user) -> Bool in
                        user != s.userId
                    })])
                }
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
    
    public func searchesChanged(search:Search?, params:Any?)->Void {
        if let status = params as? String {
            switch (status) {
            case "Added":
                if suggestions[search!.id] == nil {
                    self.addSuggestionOnListening(search!)
                }
                break;
            case "Removed":
                if self.suggestions[search!.id] != nil {
                    self.removeSuggestionOnListening(search!)
                }
                break;
            default:
                if suggestions[search!.id] != nil && search!.foundSuggestion {
                    self.removeSuggestionOnListening(search!)
                } else if suggestions[search!.id] == nil && search!.foundSuggestion == false {
                    self.addSuggestionOnListening(search!)
                }
                break;
            }
        }
    }
    
    private func removeSuggestionOnListening(_ search:Search) {
        self.suggestions.removeValue(forKey: search.id)
        self.orderSuggestions()
        self.table.reloadData()
    }
    
    private func addSuggestionOnListening(_ search:Search) {
        self.addSuggestion(search, nil)
        self.orderSuggestions()
        self.table.reloadData()
    }
    
    private func orderSuggestions() {
        sortedSuggestions = Array(suggestions.values).sorted { (first, second) -> Bool in
            first.distance < second.distance
        }
    }
    
    private func getAllSuggestions() {
        Model.instance.getAllSearches() {(searches) in
            let group = DispatchGroup()
            for suggestion in searches {
                self.addSuggestion(suggestion, group)
            }
            
            group.notify(queue: .main) {
                self.orderSuggestions()
                self.table.reloadData()
                self.activityIndicator.stopAnimating()
                UIApplication.shared.endIgnoringInteractionEvents()
                Model.instance.startObserveSearches()
            }
            if self.suggestions.count == 0 {
                self.table.alpha = 0
                self.alertNoSuggestions()
            }
        }
    }
    
    func alertNoSuggestions(){
        let alertController = UIAlertController(title:"", message: "Oops! there are no suggestions for you right now. Please try again later", preferredStyle:.alert)
        let OKAction = UIAlertAction(title:"OK", style:.default) { (action:UIAlertAction!) in
            //print("OK tapped");
            self.navigationController?.popViewController(animated: true)
        }
        alertController.addAction(OKAction)
        self.present(alertController, animated:true, completion:nil)
    }
    
    private func addSuggestion(_ suggestion:Search, _ group:DispatchGroup?)->Void {
        
        if suggestion.userId == self.search.userId ||  suggestion.foundSuggestion { return }
        
        let destDistance = self.calcDistance(search.destinationCoordinate, suggestion.destinationCoordinate)
        
        let stDistance = self.calcDistance(search.startingPointCoordinate, suggestion.startingPointCoordinate)
        
        if (destDistance > self.MAX_KM_DISTANCE_DESTINATION || stDistance > self.MAX_KM_DISTANCE_STARTING_POINT) { return }
        
        //validate number of passengers
        if ((suggestion.passengers+self.search.passengers)>=5){ return }
        
        //validate the time
      //  if ((suggestion.passengers<self.search.time)>=5){ return }
        
        group?.enter()
        self.suggestions[suggestion.id] = SuggestionData(userId: suggestion.userId, search: suggestion, distance: destDistance)
        
        if self.usersData[suggestion.userId] == nil {
            self.usersData[suggestion.userId] = UserData()
            Model.instance.getUserById(id: suggestion.userId) {(user) in
                self.usersData[suggestion.userId]?.user = user
                group?.leave()
            }
        } else {
            group?.leave()
        }
    }
    
    private func calcDistance(_ searchCoordinate:CLLocationCoordinate2D ,_ coordinate:CLLocationCoordinate2D)->Double {
        let searchLocation = CLLocation(latitude: searchCoordinate.latitude, longitude: searchCoordinate.longitude)
        let suggestionLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        return (searchLocation.distance(from: suggestionLocation) / 1000)
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return suggestions.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! SuggestionTableViewCell
        
        let suggestion = sortedSuggestions![indexPath.row]
        let suggUserData = self.usersData[suggestion.userId]
        
        cell.name.text = suggUserData!.user!.fName + " " + suggUserData!.user!.lName
        cell.data.text = "Distance: " + String(format: "%.2f", suggestion.distance) + " km, Passangers: " + String(suggestion.search.passengers) + ", Baggage: " + String(suggestion.search.baggage)
        
        cell.user = suggUserData!.user!
        cell.search = suggestion.search
        
        if let image = suggUserData!.image {
             cell.suggestionImage?.image = image
        } else {
            Model.instance.getImage(urlStr: suggUserData!.user!.imagePath!, callback: { (image) in
                cell.suggestionImage?.image = image
                self.usersData[suggestion.userId]!.image = image
            })
        }
        
        return cell
    }
}
