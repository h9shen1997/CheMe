//
//  MenuOption.swift
//  ChemicalFacilitiesAroundMe
//
//  Created by Haotian Shen on 10/9/20.
//
import UIKit

enum MenuOption: Int, CustomStringConvertible {
    var description: String {
        switch self {
        case .Map: return "Facility Map"
        case .AirQualityIndex: return "Air Quality"
        case .Explore: return "Explore"
        case .News: return "News"
        case .Complaint: return "Complaint"
        }
    }
    
    var image: UIImage {
        switch self {
        case .Map: return UIImage(named: "map") ?? UIImage()
        case .AirQualityIndex: return UIImage(named: "air") ?? UIImage()
        case .Explore: return UIImage(named: "explore") ?? UIImage()
        case .News: return UIImage(named: "news") ?? UIImage()
        case .Complaint: return UIImage(named: "complaint") ?? UIImage()
        }
    }
    
    case Map
    case AirQualityIndex
    case Explore
    case News
    case Complaint
}
