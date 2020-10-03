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

    var locationManager: CLLocationManager!
    var currentLocation: CLLocation?
    var resultSearchController: UISearchController?
    var selectedPin: MKPlacemark?
    var compassButton: MKCompassButton?
    let myLocationButton = UIButton(frame: CGRect(x: 351, y: 187, width: 43, height: 41))
    let milesStepper = UIStepper(frame: CGRect(x: 160, y: 790, width: 0, height: 0))
    let stack = UIStackView(frame: CGRect(x: 107, y: 720, width: 200, height: 50))
    let mileNumberTextField = UITextField()
    let mileTextField = UITextField()
    var facilityList = [FacilityItem]()
    var distanceList = [(FacilityItem, CLLocation, Double)]()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    @IBOutlet weak var mapView: MKMapView!
    //@IBOutlet weak var myLocationButton: UIButton!
    
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
        searchBar.placeholder = "Type an address to search..."
        navigationItem.searchController = resultSearchController
        navigationItem.hidesSearchBarWhenScrolling = false
        
        // Create the title of the app
        navigationItem.title = "Chemical Facility Around Me"
        
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
            compass.topAnchor.constraint(equalTo: mapView.topAnchor, constant: 240).isActive = true
            compass.trailingAnchor.constraint(equalTo: mapView.trailingAnchor, constant: -25).isActive = true
        }
        
        // Create the myLocation button
        let largeButtonConfig = UIImage.SymbolConfiguration(pointSize: 100, weight: .regular, scale: .large)
        let largeLocationButton = UIImage(systemName: "location.fill.viewfinder", withConfiguration: largeButtonConfig)
        myLocationButton.setImage(largeLocationButton, for: .normal)
        myLocationButton.tintColor = UIColor.red
        myLocationButton.addTarget(self, action: #selector(myLocationButtonPressed), for: .touchUpInside)
        mapView.addSubview(myLocationButton)
        
        // Create the miles stepper to change the purview around the searched location
        milesStepper.autorepeat = false
        milesStepper.isContinuous = true
        milesStepper.minimumValue = 1
        milesStepper.maximumValue = 10
        milesStepper.stepValue = 1
        milesStepper.value = 1
        mapView.addSubview(milesStepper)
        
        
        // Fetch all the preloaded facility data
        fetchFacility()
    }
    
    //MARK: - Button Methods
    @objc func myLocationButtonPressed() {
        locationManager.startUpdatingLocation()
    }
    
    @IBAction func refreshPressed(_ sender: UIBarButtonItem) {
        mapView.removeAnnotations(mapView.annotations)
    }
    
    @IBAction func menuPressed(_ sender: UIBarButtonItem) {
        
    }
    
    //MARK: - Calculate Facility Related Information
    func calculateHazardScore() {
        
    }
    
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
        let sortedDistanceList = distanceList.sorted(by: { (lhs, rhs) -> Bool in
            lhs.2 <= rhs.2
        })
        let distanceInMeter = distance * 1069.344
        let filteredList = sortedDistanceList.filter({ (facility, location, distance) -> Bool in
            distance <= distanceInMeter
        })
        return filteredList
    }
    
    //MARK: - Fetch Facility Methods
    func fetchFacility() {
        do {
            let request = FacilityItem.fetchRequest() as NSFetchRequest<FacilityItem>
            self.facilityList = try context.fetch(request)
        } catch {
            fatalError("Failed to fetch facility, \(error.localizedDescription)")
        }
    }
}


//MARK: - CLLocationManagerDelegate
extension MapViewController: CLLocationManagerDelegate {
    // Handle incoming location events.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        DispatchQueue.main.async {
            if let location = locations.first {
                let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                let region = MKCoordinateRegion(center: location.coordinate, span: span)
                self.mapView.setRegion(region, animated: true)
                self.locationManager.stopUpdatingLocation()
            }
        }
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
        // cache the pin
        selectedPin = placemark
        
        // Calculate the facilities around the selected location
        calculateLocationDistance(with: placemark)
        let surroundingFacility = showFacilitiesWithin(within: milesStepper.value)
        
        // clear existing pin
        mapView.removeAnnotations(mapView.annotations)
        
        var facilityPointer = [MKPointAnnotation]()
        if let nearbyFacilityList = surroundingFacility {
            for facility in nearbyFacilityList {
                let annotation = MKPointAnnotation()
                annotation.coordinate = facility.1.coordinate
                annotation.title = facility.0.facilityName
                annotation.subtitle = "\(String(facility.0.county ?? "")), \(String(facility.0.city ?? ""))"
                facilityPointer.append(annotation)
            }
        }
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name
        if let city = placemark.locality, let state = placemark.administrativeArea {
            annotation.subtitle = "\(city) \(state)"
        }
        mapView.addAnnotation(annotation)
        mapView.addAnnotations(facilityPointer)
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: placemark.coordinate, span: span)
        mapView.setRegion(region, animated: true)
    }
}


