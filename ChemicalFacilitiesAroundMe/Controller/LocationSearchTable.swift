//
//  LocationSearchTable.swift
//  ChemicalFacilitiesAroundMe
//
//  Created by Haotian Shen on 9/28/20.
//

import UIKit
import MapKit

class LocationSearchTable: UITableViewController {
    
    private let reuseIdentifier = "searchResultCell"
    private var matchingItems = [MKMapItem]()
    private var searchBar: UISearchBar?
    public var mapView: MKMapView?
    public var handleMapSearchDelegate: HandleMapSearch?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

//MARK: - UISearchResultsUpdating
extension LocationSearchTable: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let mapView = mapView,
              let searchBarText = searchController.searchBar.text else {
            return
        }
        searchBar = searchController.searchBar
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = searchBarText
        searchRequest.region = mapView.region
        let search = MKLocalSearch(request: searchRequest)
        search.start { (response, error) in
            guard let response = response else {
                return
            }
            self.matchingItems = response.mapItems
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
}

//MARK: - UITableViewDelegate and UITableViewDataSource
extension LocationSearchTable {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matchingItems.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        let selectedItem = matchingItems[indexPath.row].placemark
        let address = "\(selectedItem.locality ?? ""), \(selectedItem.administrativeArea ?? ""), \(selectedItem.country ?? "") \(selectedItem.postalCode ?? "")"
        cell.textLabel?.text = selectedItem.name
        cell.detailTextLabel?.text = address
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = matchingItems[indexPath.row].placemark
        handleMapSearchDelegate?.dropPinZoomIn(placemark: selectedItem)
        searchBar?.text = ChemFacilityConstants.searchBarDefaultText
        dismiss(animated: true, completion: nil)
    }
}
