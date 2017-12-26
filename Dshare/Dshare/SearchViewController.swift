import UIKit
import GooglePlaces

class SearchViewController: UIViewController, CLLocationManagerDelegate {
    @IBOutlet weak var startingPoint: UITextField!
    @IBOutlet weak var detination: UITextField!
    @IBOutlet weak var changeSpBtn: UIButton!
    @IBOutlet weak var timePicker: UIDatePicker!
    @IBOutlet weak var flightNumber: UITextField!
    
    var isStaringPointChanged:Bool!;
    var startingPointPlace: GMSPlace!
    var placesClient: GMSPlacesClient!
    var nowDate:Date!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.setHidesBackButton(true, animated: false);
        
        self.nowDate = Date();
        timePicker.minimumDate = self.nowDate;
        var oneWeekfromNow: Date { return (Calendar.current as NSCalendar).date(byAdding: .day, value: 7, to: self.nowDate, options: [])! }
        timePicker.maximumDate = oneWeekfromNow;
        timePicker.date = self.nowDate;
        
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
        //if(timePicker.date == Date()) {
            var isAirport:Bool = false;
            for type in place.types {
                if(type == "airport") {
                    isAirport = true;
                    break;
                }
            }
        
            flightNumber.isHidden = (isAirport) ? false: true;
        //}
    }
    
    func setStartingPoint(place: GMSPlace) {
        self.startingPoint.text = place.name;
        self.startingPointPlace = place;
        self.showSelectFlight(place: place);
    
    }
    
    func setDestinationPoint(place: GMSPlace) {
        self.detination.text = place.name;
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
