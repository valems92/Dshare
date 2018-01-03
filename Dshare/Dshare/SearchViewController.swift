import UIKit
import GooglePlaces

class SearchViewController: UIViewController, CLLocationManagerDelegate {
    @IBOutlet weak var startingPoint: UITextField!
    @IBOutlet weak var detination: UITextField!
    @IBOutlet weak var changeSpBtn: UIButton!
    @IBOutlet weak var timePicker: UIDatePicker!
    @IBOutlet weak var flightNumber: UITextField!
    @IBOutlet weak var passangers: UITextField!
    @IBOutlet weak var baggage: UITextField!
    
    var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    
    var isStaringPointChanged:Bool!
    var startingPointPlace: GMSPlace!
    var placesClient: GMSPlacesClient!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.setHidesBackButton(true, animated: false);
        
        Utils.instance.initActivityIndicator(activityIndicator: activityIndicator, controller: self);
        
        timePicker.minimumDate = Date();
        var oneWeekfromNow: Date { return (Calendar.current as NSCalendar).date(byAdding: .day, value: 7, to: timePicker.minimumDate!, options: [])! }
        timePicker.maximumDate = oneWeekfromNow;
        timePicker.date = timePicker.minimumDate!;
        
        placesClient = GMSPlacesClient.shared();
        setCurrentPlace();
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func onChangeDestination(_ sender: UIButton) {
        self.isStaringPointChanged = false;
        presentAutoCompleteView();
    }
    
    @IBAction func onChangeStartingPoint(_ sender: UIButton) {
        self.isStaringPointChanged = true;
        presentAutoCompleteView();
    }
    
    @IBAction func onChangeLeaveTime(_ sender: UIDatePicker) {
        self.showSelectFlight(place: self.startingPointPlace);
    }
    
    func presentAutoCompleteView() {
        let autocompleteController = GMSAutocompleteViewController();
        autocompleteController.delegate = self;
        present(autocompleteController, animated: true, completion: nil);
    }
    
    func setCurrentPlace() {
        placesClient.currentPlace(callback: { (placeLikelihoodList, error) -> Void in
            self.changeSpBtn.isEnabled = true;
            if let error = error {
                print("Pick Place error: \(error.localizedDescription)");
                return;
            }
            
            if let placeLikelihoodList = placeLikelihoodList {
                for likelihood in placeLikelihoodList.likelihoods {
                    let place = likelihood.place;
                    self.setStartingPoint(place: place);
                }
            }
        })
    }
    
    func showSelectFlight(place:GMSPlace) {
        var isAirport:Bool = false;
        for type in place.types {
            if(type == "airport") {
                isAirport = true;
                break;
            }
        }
        
        flightNumber.isHidden = (isAirport) ? false: true;
    }
    
    func setStartingPoint(place: GMSPlace) {
        self.startingPoint.text = place.name;
        self.startingPointPlace = place;
        self.showSelectFlight(place: place);
    
    }
    
    func setDestinationPoint(place: GMSPlace) {
        self.detination.text = place.name;
    }
    
    func validateUserInput() -> Bool {
        if ((startingPoint.text?.isEmpty)! || (detination.text?.isEmpty)! || (passangers.text?.isEmpty)! || (baggage.text?.isEmpty)!) {
            Utils.instance.displayAlertMessage(messageToDisplay:"Please fill out all fields to proceed", controller: self);
            return false;
        }
        
        return true;
    }
    
    @IBAction func onSearch(_ sender: Any) {
        if (validateUserInput()) {
            self.addSearchToFirebase();
        }
    }
    
    func addSearchToFirebase() {
        activityIndicator.startAnimating();
        UIApplication.shared.beginIgnoringInteractionEvents()
        let userId = Model.instance.getCurrentUserUid();
    
        let search = Search(userId: userId, startingPoint: startingPoint.text!, destination: detination.text!, passengers: Int(passangers.text!)!, baggage: Int(baggage.text!)!, leavingTime:timePicker.date, flightNumber:flightNumber.text!);
    
        Model.instance.addNewSearch(search: search) { (error) in
            self.activityIndicator.stopAnimating()
            UIApplication.shared.endIgnoringInteractionEvents()
            if error != nil {
                Utils.instance.displayAlertMessage(messageToDisplay: "There was an error saving your search. Please try again", controller: self);
            }
            else {
                //self.deleteOldestUserSearch(id: userId, callback: { (error) in
                self.performSegue(withIdentifier: "toSuggestionsFromSearch", sender: self);
                //})
            }
        }
    }
    
    // Not in use!
    func deleteOldestUserSearch(id:String, callback:@escaping (Error?)->Void) {
        Model.instance.getSearchesByUserId(id: id) { (error, searchesArray) in
            let totalSearches = searchesArray.count;
            
            if(totalSearches >= 3) {
                
            }
        }

    }
}

extension SearchViewController: GMSAutocompleteViewControllerDelegate {
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        if(self.isStaringPointChanged) {
            self.setStartingPoint(place: place);
        } else {
            self.setDestinationPoint(place: place);
        }
        dismiss(animated: true, completion: nil);
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print("Error: ", error.localizedDescription)
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil);
    }
    
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true;
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false;
    }
}
