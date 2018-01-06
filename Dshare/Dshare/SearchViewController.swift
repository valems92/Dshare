import UIKit
import GooglePlaces

class SearchViewController: UIViewController, CLLocationManagerDelegate {
    @IBOutlet weak var startingPoint: UITextField!
    @IBOutlet weak var detination: UITextField!
    @IBOutlet weak var changeSpBtn: UIButton!
    @IBOutlet weak var timePicker: UIDatePicker!
    @IBOutlet weak var flightNumber: UITextField!
    @IBOutlet weak var waitingTime: UITextField!
    @IBOutlet weak var passangers: UITextField!
    @IBOutlet weak var baggage: UITextField!
    
    var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    
    var isStaringPointChanged:Bool!
    var startingPointPlace: GMSPlace!
    var destinationPlace: GMSPlace!
    var leaveNow:Bool!
    var nowDate:Date!
    var search:Search!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.setHidesBackButton(true, animated: false);
        
        Utils.instance.initActivityIndicator(activityIndicator: activityIndicator, controller: self)
        
        leaveNow = true
        nowDate = Date()
        
        timePicker.minimumDate = nowDate
        var oneWeekfromNow: Date { return (Calendar.current as NSCalendar).date(byAdding: .day, value: 7, to: timePicker.minimumDate!, options: [])! }
        timePicker.maximumDate = oneWeekfromNow
        timePicker.date = timePicker.minimumDate!
        
        setCurrentPlace()
        
        //Dismiss keyboard when touching anywhere outside text field
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tap(gesture:)))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tap(gesture: UITapGestureRecognizer) {
        flightNumber.resignFirstResponder()
        waitingTime.resignFirstResponder()
        passangers.resignFirstResponder()
        baggage.resignFirstResponder()
    }
    
    @IBAction func onLeaveTimeChange(_ sender: UISegmentedControl) {
        leaveNow = (sender.selectedSegmentIndex == 0) ? true : false
        
        waitingTime.isHidden = !leaveNow
        timePicker.isHidden = leaveNow
        
        showSelectFlight(place: startingPointPlace)
    }
    
    @IBAction func onChangeDestination(_ sender: UIButton) {
        self.isStaringPointChanged = false
        presentAutoCompleteView()
    }
    
    @IBAction func onChangeStartingPoint(_ sender: UIButton) {
        self.isStaringPointChanged = true
        presentAutoCompleteView()
    }
    
    @IBAction func onChangeLeaveTime(_ sender: UIDatePicker) {
        self.showSelectFlight(place: self.startingPointPlace)
    }
    
    @IBAction func onSearch(_ sender: Any) {
        if (validateUserInput()) {
            self.setSearch();
            self.addSearchToFirebase()
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
            self.changeSpBtn.isEnabled = true
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
        
        flightNumber.isHidden = (isAirport && !leaveNow) ? false: true
    }
    
    func setStartingPoint(place: GMSPlace) {
        self.startingPoint.text = place.name
        self.startingPointPlace = place
        self.showSelectFlight(place: place)
    }
    
    func setDestinationPoint(place: GMSPlace) {
        self.detination.text = place.name
        self.destinationPlace = place
    }
    
    func validateUserInput() -> Bool {
        if ((startingPoint.text?.isEmpty)! || (detination.text?.isEmpty)! || (passangers.text?.isEmpty)! || (baggage.text?.isEmpty)!
            || (leaveNow && (waitingTime.text?.isEmpty)!)) {
            Utils.instance.displayAlertMessage(messageToDisplay:"Please fill out the mandatory fields to proceed", controller: self)
            return false
        }
        
        if (Int(passangers.text!) == nil || Int(baggage.text!) == nil || (leaveNow && Int(waitingTime.text!) == nil)) {
            Utils.instance.displayAlertMessage(messageToDisplay:"Passangers, Baggage and Waiting time should be an integer", controller: self)
            return false
        }
        
        return true
    }
    
    func addSearchToFirebase() {
        activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
        
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
        
        if (leaveNow) {
            self.search = Search(userId: userId, startingPoint: startingPointPlace.placeID, destination: destinationPlace.placeID, passengers: Int(passangers.text!)!, baggage: Int(baggage.text!)!, leavingTime: nowDate, waitingTime: Int(waitingTime.text!)!, flightNumber: nil)
        } else {
            self.search = Search(userId: userId, startingPoint: startingPointPlace.placeID, destination: destinationPlace.placeID, passengers: Int(passangers.text!)!, baggage: Int(baggage.text!)!, leavingTime: timePicker.date, waitingTime: nil, flightNumber: flightNumber.text)
        }
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
