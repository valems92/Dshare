import UIKit
import GooglePlaces
import Foundation

class SearchViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var startingPoint: UITextField!
    @IBOutlet weak var destination: UITextField!
    @IBOutlet weak var timePicker: UIDatePicker!
    @IBOutlet weak var airlineCode: UITextField!
    @IBOutlet weak var flightNumber: UITextField!
    @IBOutlet weak var waitingTime: UITextField!
    @IBOutlet weak var passangers: UITextField!
    @IBOutlet weak var baggage: UITextField!
    @IBOutlet weak var searchBtn: UIButton!
    @IBOutlet weak var searchTopConstraint: NSLayoutConstraint!
    
    var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect(x:0, y:100, width:50, height:50))

    var isStaringPointChanged:Bool!
    var startingPointPlace: GMSPlace!
    var destinationPlace: GMSPlace!
    var leaveNow:Bool = true
    var nowDate:Date!
    var search:Search!
    var observerId:Any?
    var flightId:Int?
    var flightArrivalDate:Date?

    let LEAVE_NOW_CONSTANT:CGFloat = 75
    let LEAVE_LATER_FLIGHT_CONSTANT:CGFloat = 365
    let LEAVE_LATER_NO_FLIGHT_CONSTANT:CGFloat = 250
    
    let APP_ID:String = "579fdea6"
    let APP_KEY:String = "1eaa8f62ff8400e4871b7ed7a49de045"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.setHidesBackButton(true, animated: false)
        
        Utils.instance.initActivityIndicator(activityIndicator: activityIndicator, controller: self)
        searchTopConstraint.constant = LEAVE_NOW_CONSTANT
        
        nowDate = Date()
        
        timePicker.minimumDate = nowDate
        var oneWeekfromNow: Date { return (Calendar.current as NSCalendar).date(byAdding: .day, value: 7, to: timePicker.minimumDate!, options: [])! }
        timePicker.maximumDate = oneWeekfromNow
        timePicker.date = timePicker.minimumDate!
        timePicker.setValue(UIColor.white, forKeyPath: "textColor")
        
        setCurrentPlace()
        
        startingPoint.addTarget(self, action: #selector(onChangeStartingPoint), for: .editingDidBegin)
        destination.addTarget(self, action: #selector(onChangeDestination), for: .editingDidBegin)
        
        //Dismiss keyboard when touching anywhere outside text field
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tap(gesture:)))
        view.addGestureRecognizer(tapGesture)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
    
    func tap(gesture: UITapGestureRecognizer) {
        airlineCode.resignFirstResponder()
        flightNumber.resignFirstResponder()
        waitingTime.resignFirstResponder()
        passangers.resignFirstResponder()
        baggage.resignFirstResponder()
    }
    
    @IBAction func onLeaveTimeChange(_ sender: UISegmentedControl) {
        leaveNow = (sender.selectedSegmentIndex == 0) ? true : false
        
        showSelectFlight(place: startingPointPlace)
        
        waitingTime.isHidden = !leaveNow
        timePicker.isHidden = leaveNow
    }
    
    func onChangeStartingPoint() {
        self.isStaringPointChanged = true
        presentAutoCompleteView()
    }
    
    func onChangeDestination() {
        self.isStaringPointChanged = false
        presentAutoCompleteView()
    }
    
    @IBAction func onChangeLeaveTime(_ sender: UIDatePicker) {
        self.showSelectFlight(place: self.startingPointPlace)
    }
    
    @IBAction func onSearch(_ sender: Any) {
        activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        validateUserInput { (valid) in
            if valid {
                self.setSearch()
                self.addSearchToFirebase()
            } else {
                self.activityIndicator.stopAnimating()
                UIApplication.shared.endIgnoringInteractionEvents()
            }
        }
    }
    
    func presentAutoCompleteView() {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        present(autocompleteController, animated: true, completion: nil)
    }
    
    func setCurrentPlace() {
        let placesClient: GMSPlacesClient! = GMSPlacesClient.shared()
        placesClient.currentPlace(callback: { (placeLikelihoodList, error) -> Void in
            if let error = error {
                print("Pick Place error: \(error.localizedDescription)")
                return
            }
            
            if let placeLikelihoodList = placeLikelihoodList {
                for likelihood in placeLikelihoodList.likelihoods {
                    let place = likelihood.place
                    self.setStartingPoint(place: place)
                }
            }
        })
    }
    
    func showSelectFlight(place:GMSPlace) {
        var isAirport:Bool = false
        for type in place.types {
            if(type == "airport") {
                isAirport = true
                break;
            }
        }
        
        if isAirport {
            flightNumber.isHidden = leaveNow
            airlineCode.isHidden = leaveNow
            timePicker.datePickerMode = UIDatePickerMode.date
            searchTopConstraint.constant = (!leaveNow) ? LEAVE_LATER_FLIGHT_CONSTANT: LEAVE_NOW_CONSTANT;
        } else {
            flightNumber.isHidden = true
            airlineCode.isHidden = true
            timePicker.datePickerMode = UIDatePickerMode.dateAndTime
            searchTopConstraint.constant = LEAVE_LATER_NO_FLIGHT_CONSTANT
        }
    }
    
    func setStartingPoint(place: GMSPlace) {
        self.startingPoint.text = place.name
        self.startingPointPlace = place
        self.showSelectFlight(place: place)
    }
    
    func setDestinationPoint(place: GMSPlace) {
        self.destination.text = place.name
        self.destinationPlace = place
    }
    
    func validateUserInput(completionHandler: @escaping (_ valid: Bool) -> Void) {
        // Validate starting point, destination, passangrs and baggage are not empty
        if ((startingPoint.text?.isEmpty)! || (destination.text?.isEmpty)! || (passangers.text?.isEmpty)!  || (baggage.text?.isEmpty)!
            || (leaveNow && (waitingTime.text?.isEmpty)!) || Int((passangers.text)!)!<=0) {
            
            Utils.instance.displayAlertMessage(messageToDisplay:"Please fill out the mandatory fields to proceed", controller: self)
            completionHandler(false)
            return
        }
        
        // Validate the passangrs number
        if (Int((passangers.text)!)!>3 ) {
            Utils.instance.displayAlertMessage(messageToDisplay:"The maximun number of the passangers for sharing one taxi is four ", controller: self)
            completionHandler(false)
            return
        }
        
        // Validate passangers, baggage and waiting time are integers
        if (Int(passangers.text!) == nil || Int(baggage.text!) == nil || (leaveNow && Int(waitingTime.text!) == nil)) {
            Utils.instance.displayAlertMessage(messageToDisplay:"Passangers, Baggage and Waiting time should be an integer", controller: self)
            completionHandler(false)
            return
        }
        
        // Validate flight number if needed
        if (flightNumber.isHidden == false) {
            if ((flightNumber.text?.isEmpty)! || (airlineCode.text?.isEmpty)!) {
                Utils.instance.displayAlertMessage(messageToDisplay:"Please fill out the airline code and flight number", controller: self)
                completionHandler(false)
                return
            } else {
                validateFlightNumber(completionHandler: completionHandler)
                return
            }
        } else {
            flightId = nil
            flightArrivalDate = nil
        }
        
        completionHandler(true)
    }
    
    func validateFlightNumber(completionHandler: @escaping (_ valid: Bool) -> Void) {
        let airlineCode = self.airlineCode.text
        let flightNumber = self.flightNumber.text
        
        // Get date selected
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        let date = dateFormatter.string(from: self.timePicker.date)
        
        // Create URL
        let baseUrl = "https://api.flightstats.com/flex/flightstatus/rest/v2/json/flight/status/\(airlineCode!)/\(flightNumber!)/arr/\(date)?appId=\(self.APP_ID)&appKey=\(self.APP_KEY)&utc=false"
        
        getFlightData(baseUrl: baseUrl) { (res) in
            if let data = res {
                let flightsArray:NSArray = data["flightStatuses"] as! NSArray
                if flightsArray.count == 0 {
                    Utils.instance.displayAlertMessage(messageToDisplay:"Invalid Flight", controller: self)
                    completionHandler(false)
                } else {
                    let flightData = flightsArray[0] as? NSDictionary
                    self.flightId = flightData!["flightId"] as? Int
                    
                    let operationalTimes = flightData!["operationalTimes"] as? NSDictionary
                    let estimatedRunwayArrival = operationalTimes!["estimatedRunwayArrival"] as? NSDictionary
                    let dateLocal = (estimatedRunwayArrival!["dateLocal"] as? String)!
                    
                    // TODO: Convert dateLocal to Date
                    /*let df = DateFormatter()
                    df.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                    guard let flightDate = df.date(from: dateLocal) else {
                        completionHandler(false)
                        return
                    }
                    self.flightArrivalDate = flightDate*/
                    completionHandler(true)
                }
            } else {
                Utils.instance.displayAlertMessage(messageToDisplay:"Error ocurred while verifing the flight", controller: self)
                completionHandler(false)
            }
        }
    }
    
    func getFlightData(baseUrl:String, completionHandler: @escaping (_ data: NSDictionary?) -> Void) {
        guard let endpoint = URL(string: baseUrl) else {
            completionHandler(nil)
            return
        }
        
        let task = URLSession.shared.dataTask(with: endpoint) { (data, response, error) in
            do {
                guard let data = data else {
                    completionHandler(nil)
                    return
                }
                guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary else {
                    completionHandler(nil)
                    return
                }
                completionHandler(json)
            } catch _ as NSError {
                completionHandler(nil)
                return
            }
        }
        task.resume()
    }
    
    func addSearchToFirebase() {
        Model.instance.addNewSearch(search: self.search) { (error) in
            self.activityIndicator.stopAnimating()
            UIApplication.shared.endIgnoringInteractionEvents()
            if error != nil {
                Utils.instance.displayAlertMessage(messageToDisplay: "There was an error saving your search. Please try again", controller: self)
            }
            else {
                self.performSegue(withIdentifier: "toSuggestionsFromSearch", sender: self)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toSuggestionsFromSearch" {
            if let nextViewController = segue.destination as? TableViewController {
                nextViewController.search = self.search;
            }
        }
    }
    
    func setSearch() {
        let userId = Model.instance.getCurrentUserUid()
        var lt:Date
        var wt:Int? = nil
        
        if (leaveNow) {
            lt = nowDate
            wt = Int(waitingTime.text!)!
        } else {
            lt = ((flightArrivalDate) != nil) ? flightArrivalDate! : timePicker.date;
        }
        
        self.search = Search(userId: userId, startingPointCoordinate: startingPointPlace.coordinate, startingPointAddress: startingPointPlace.formattedAddress!, destinationCoordinate: destinationPlace.coordinate, destinationAddress: destinationPlace.formattedAddress!, passengers: Int(passangers.text!)!, baggage: Int(baggage.text!)!, leavingTime: lt, waitingTime: wt, flightId: flightId)
    }
}

extension SearchViewController: GMSAutocompleteViewControllerDelegate {
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        if(self.isStaringPointChanged) {
            self.setStartingPoint(place: place)
        } else {
            self.setDestinationPoint(place: place)
        }
        dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print("Error: ", error.localizedDescription)
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}
