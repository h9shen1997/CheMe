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

protocol MapViewControllerDelegate {
    func toggleMenuPanel(forMenuOption menuOption: MenuOption?)
}

protocol UpdateFacilityResultTable {
    func updateResultTable()
}

class MapViewController: UIViewController {

    private let reuseIdentifier = "facilityResultCell"
    
    private var locationManager: CLLocationManager!
    private var currentLocation: CLLocation?
    private var resultSearchController: UISearchController?
    private var selectedPin: MKPlacemark?
    private var compassButton: MKCompassButton?
    private var facilityList = [FacilityItem]()
    private var distanceList = [(FacilityItem, CLLocation, Double)]()
    private var surroundingFacility: [(FacilityItem, CLLocation, Double)]?
    private var facilityPointer: [MKPointAnnotation]?
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    private let myLocationButton = UIButton()
    private var shouldAllowStepper = true
    private var mapView = MKMapView()
    private var compassVStack = UIStackView()

    
    var updateDelegate: UpdateFacilityResultTable!
    var facilityResultController: FacilityResultTable!
    var menuDelegate: MapViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        self.view.addSubview(mapView)
        mapView.showsUserLocation = true
        mapView.showsCompass = false
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        
        mapView.addSubview(compassVStack)
        compassVStack.translatesAutoresizingMaskIntoConstraints = false
        compassVStack.axis = .vertical
        compassVStack.distribution = .fillEqually
        compassVStack.alignment = .center
        compassVStack.spacing = 3
        compassVStack.trailingAnchor.constraint(equalTo: mapView.trailingAnchor, constant: -25).isActive = true
        compassVStack.topAnchor.constraint(equalTo: mapView.topAnchor, constant: 180).isActive = true
        
        // Initialize the search display table
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let locationSearchTable = storyboard.instantiateViewController(identifier: "locationSearchTable") as! LocationSearchTable
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController?.searchResultsUpdater = locationSearchTable
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        resultSearchController?.obscuresBackgroundDuringPresentation = true
        
        facilityResultController = FacilityResultTable()
        facilityResultController.updateDelegate = self
        addChild(facilityResultController)
        //view.addSubview(facilityResultController.view)
        facilityResultController.didMove(toParent: self)
        
        // Create a search bar with placeholder
        let searchBar = resultSearchController!.searchBar
        searchBar.autocapitalizationType = .words
        searchBar.placeholder = ChemFacilityConstants.searchBarPlaceholder
        navigationItem.searchController = resultSearchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
        locationSearchTable.mapView = mapView
        locationSearchTable.handleMapSearchDelegate = self
        
        // Create the myLocation button
        compassVStack.addArrangedSubview(myLocationButton)
        let largeButtonConfig = UIImage.SymbolConfiguration(pointSize: 30, weight: .regular, scale: .large)
        let largeLocationButton = UIImage(systemName: "location.fill.viewfinder", withConfiguration: largeButtonConfig)
        myLocationButton.translatesAutoresizingMaskIntoConstraints = false
        myLocationButton.heightAnchor.constraint(equalToConstant: 42).isActive = true
        myLocationButton.widthAnchor.constraint(equalToConstant: 42).isActive = true
        myLocationButton.setImage(largeLocationButton, for: .normal)
        myLocationButton.tintColor = UIColor.red
        myLocationButton.addTarget(self, action: #selector(myLocationButtonPressed), for: .touchUpInside)
        
        // Create a compass at customized location
        compassButton = MKCompassButton(mapView: mapView)
        if let compass = compassButton {
            compassVStack.addArrangedSubview(compass)
            compass.compassVisibility = .visible
            compass.translatesAutoresizingMaskIntoConstraints = false
        }
        configureNavigationBar()
        // Fetch all the preloaded facility data
        fetchFacility()
    }
    
    func configureNavigationBar() {
        navigationController?.navigationBar.barTintColor = .none
        navigationController?.navigationBar.barStyle = .default
        navigationItem.title = "Chemical Facility Around Me"
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "text.justify"), style: .plain, target: self, action: #selector(menuPressed(_:)))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refreshPressed(_:)))
    }
    

}
//MARK: - UI Methods Arrangement
extension MapViewController {
    @objc func myLocationButtonPressed() {
        locationManager.startUpdatingLocation()
    }
    
    @objc func refreshPressed(_ sender: UIBarButtonItem) {
        mapView.removeAnnotations(mapView.annotations)
        shouldAllowStepper = false
    }
    
    @objc func menuPressed(_ sender: UIBarButtonItem) {
        menuDelegate?.toggleMenuPanel(forMenuOption: nil)
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
        mapView.addSubview(facilityResultController.view)
        mapView.removeAnnotations(self.mapView.annotations)
        
        createNewSurroundingAnnotations(with: placemark, miles: facilityResultController.stepper.value)
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
        surroundingFacility = showFacilitiesWithin(within: miles)
        facilityResultController.surroundingFacility = surroundingFacility
        facilityResultController.tableView.reloadData()
        var facilityPointerList = [MKPointAnnotation]()
        if facilityPointer != nil {
            mapView.removeAnnotations(facilityPointer!)
            facilityPointer!.removeAll()
        }
        if let surroundingFacility = surroundingFacility {
            for facility in surroundingFacility {
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

extension MapViewController: UpdateFacilityResultTable {
    func updateResultTable() {
        if let selectedPin = selectedPin {
            createNewSurroundingAnnotations(with: selectedPin, miles: facilityResultController.stepper.value)
        }
    }
}
