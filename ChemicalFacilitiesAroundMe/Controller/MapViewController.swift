//
//  ViewController.swift
//  ChemicalFacilitiesAroundMe
//
//  Created by Haotian Shen on 9/28/20.
//

import UIKit
import MapKit
import CoreData

protocol HandleMapSearch {
    func dropPinZoomIn(placemark: MKPlacemark)
}

class MapViewController: UIViewController {
    private var locationManager: CLLocationManager!
    private var currentLocation: CLLocation?
    private var resultSearchController: UISearchController?
    private var selectedPin: MKPlacemark?
    private var compassButton: MKCompassButton?
    private var facilityList = [FacilityItem]()
    private var distanceList = [(FacilityItem, CLLocation, Double)]()
    private var facilityPointer: [MKPointAnnotation]?
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    private let myLocationButton = UIButton(frame: CGRect(x: ChemFacilityConstants.myLocationFrameX, y: ChemFacilityConstants.myLocationFrameY, width: ChemFacilityConstants.myLocationFrameWidth, height: ChemFacilityConstants.myLocationFrameHeight))
    private var shouldAllowStepper = true
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mileTextField: UITextField!
    @IBOutlet weak var mileStepper: UIStepper!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        
        mapView.showsUserLocation = true
        
        // Initialize the search display table
        let locationSearchTable = storyboard?.instantiateViewController(identifier: "locationSearchTable") as? LocationSearchTable
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController?.searchResultsUpdater = locationSearchTable
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        resultSearchController?.obscuresBackgroundDuringPresentation = true
        
        // Create a search bar with placeholder
        let searchBar = resultSearchController!.searchBar
        searchBar.autocapitalizationType = .words
        searchBar.placeholder = ChemFacilityConstants.searchBarPlaceholder
        navigationItem.searchController = resultSearchController
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.title = ChemFacilityConstants.navigationTitle
        definesPresentationContext = true
        locationSearchTable?.mapView = mapView
        locationSearchTable?.handleMapSearchDelegate = self
        
        // Create a compass at customized location
        mapView.showsCompass = false
        compassButton = MKCompassButton(mapView: mapView)
        if let compass = compassButton {
            mapView.addSubview(compass)
            compass.compassVisibility = .visible
            compass.translatesAutoresizingMaskIntoConstraints = false
            compass.topAnchor.constraint(equalTo: mapView.topAnchor, constant: ChemFacilityConstants.compassTopAnchor).isActive = true
            compass.trailingAnchor.constraint(equalTo: mapView.trailingAnchor, constant: ChemFacilityConstants.compassTrailingAnchor).isActive = true
        }
        
        // Create the myLocation button
        let largeButtonConfig = UIImage.SymbolConfiguration(pointSize: 100, weight: .regular, scale: .large)
        let largeLocationButton = UIImage(systemName: "location.fill.viewfinder", withConfiguration: largeButtonConfig)
        myLocationButton.setImage(largeLocationButton, for: .normal)
        myLocationButton.tintColor = UIColor.red
        myLocationButton.addTarget(self, action: #selector(myLocationButtonPressed), for: .touchUpInside)
        mapView.addSubview(myLocationButton)

        // Define the default value of the mileTextField
        updateStepperDisplay(mileStepper)
        
        // Fetch all the preloaded facility data
        fetchFacility()
    }
}

//MARK: - UI Methods Arrangement
extension MapViewController {
    @objc func myLocationButtonPressed() {
        locationManager.startUpdatingLocation()
    }
    
    @IBAction func refreshPressed(_ sender: UIBarButtonItem) {
        mapView.removeAnnotations(mapView.annotations)
        shouldAllowStepper = false
    }
    
    @IBAction func menuPressed(_ sender: UIBarButtonItem) {
        
    }
    
    @IBAction func stepperPressed(_ sender: UIStepper) {
        updateStepperDisplay(sender)
        if shouldAllowStepper {
            if let pin = selectedPin {
                createNewSurroundingAnnotations(with: pin, miles: sender.value)
            }
        }
    }
}

//MARK: - Facility Manipulation methods
extension MapViewController {
    // Fetch facility
    func fetchFacility() {
        do {
            let request = FacilityItem.fetchRequest() as NSFetchRequest<FacilityItem>
            self.facilityList = try context.fetch(request)
        } catch {
            fatalError("Failed to fetch facility, \(error.localizedDescription)")
        }
    }
    
   // Calculate Facility Related Information
    func calculateLocationDistance(with placemark: MKPlacemark) {
        let selectedLocation = CLLocation(latitude: placemark.coordinate.latitude, longitude: placemark.coordinate.longitude)
        distanceList.removeAll()
        for facility in facilityList {
            let facilityLocation = CLLocation(latitude: facility.latitude, longitude: facility.longitude)
            let distance = Double(selectedLocation.distance(from: facilityLocation))
            distanceList.append((facility, facilityLocation, distance))
        }
    }
    
    func showFacilitiesWithin(within distance: Double) -> [(FacilityItem, CLLocation, Double)]? {
        let sortedDistanceList = distanceList.sorted(by: {(lhs, rhs) -> Bool in
            lhs.2 <= rhs.2
        })
        let distanceInMeter = distance * ChemFacilityConstants.milesToMeterConverter
        let filteredList = sortedDistanceList.filter({ (facility, location, distance) -> Bool in
            distance <= distanceInMeter
        })
        return filteredList
    }
    
    func updateStepperDisplay(_ stepper: UIStepper) {
        if stepper.value == ChemFacilityConstants.stepperDefaultValue {
            mileTextField.text = String(Int(mileStepper.value)) + ChemFacilityConstants.stepperDefaultText
        } else {
            mileTextField.text = String(Int(mileStepper.value)) + ChemFacilityConstants.stepperNonDefaultText
        }
    }
}

//MARK: - CLLocationManagerDelegate
extension MapViewController: CLLocationManagerDelegate {
    // Handle incoming location events.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        DispatchQueue.main.async {
            if let location = locations.last {
                let span = MKCoordinateSpan(latitudeDelta: ChemFacilityConstants.latitudeDelta, longitudeDelta: ChemFacilityConstants.longitudeDelta)
                let region = MKCoordinateRegion(center: location.coordinate, span: span)
                self.mapView.setRegion(region, animated: true)
            }
        }
        self.locationManager.stopUpdatingLocation()
    }
    
    // Handle authorization for the location manager.
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let accuracy = manager.accuracyAuthorization
        switch accuracy {
        case .fullAccuracy:
            print("Location accuracy is precise")
        case .reducedAccuracy:
            print("Location accuracy is not precise")
        @unknown default:
            fatalError()
        }
        
        let status = manager.authorizationStatus
        switch status {
        case .authorizedAlways:
            fallthrough
        case .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
        case .denied:
            locationManager.stopUpdatingLocation()
        case .notDetermined:
            locationManager.stopUpdatingLocation()
        case .restricted:
            locationManager.stopUpdatingLocation()
        @unknown default:
            fatalError()
        }
    }

    // Handle location manager errors.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        print("error:: \(error.localizedDescription)")
    }
}

//MARK: - HandleMapSearch Protocol
extension MapViewController: HandleMapSearch {
    func dropPinZoomIn(placemark: MKPlacemark) {
        shouldAllowStepper = true
        selectedPin = placemark
        self.mapView.removeAnnotations(self.mapView.annotations)
        
        createNewSurroundingAnnotations(with: placemark, miles: mileStepper.value)
        let span = MKCoordinateSpan(latitudeDelta: ChemFacilityConstants.latitudeDelta, longitudeDelta: ChemFacilityConstants.longitudeDelta)
        let region = MKCoordinateRegion(center: placemark.coordinate, span: span)
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name
        if let city = placemark.locality, let state = placemark.administrativeArea {
            annotation.subtitle = "\(city) \(state)"
        }
        
        DispatchQueue.main.async {
            self.mapView.addAnnotation(annotation)
            self.mapView.setRegion(region, animated: true)
        }
    }
}

//MARK: - Update Surrounding Facilities Pinpoint
extension MapViewController {
    func createNewSurroundingAnnotations(with placemark: MKPlacemark, miles: Double) {
        
        calculateLocationDistance(with: placemark)
        let surroundingFacility = showFacilitiesWithin(within: miles)
        var facilityPointerList = [MKPointAnnotation]()
        if facilityPointer != nil {
            mapView.removeAnnotations(facilityPointer!)
            facilityPointer!.removeAll()
        }
        if let nearbyFacility = surroundingFacility {
            for facility in nearbyFacility {
                let annotation = MKPointAnnotation()
                annotation.coordinate = facility.1.coordinate
                annotation.title = facility.0.facilityName
                annotation.subtitle = "\(String(facility.0.county ?? "")), \(String(facility.0.city ?? ""))"
                facilityPointerList.append(annotation)
            }
        }
        
        DispatchQueue.main.async {
            self.mapView.addAnnotations(facilityPointerList)
        }
        facilityPointer = facilityPointerList
    }
}
