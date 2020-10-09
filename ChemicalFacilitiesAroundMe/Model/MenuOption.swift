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
        case .Map: return "Map"
        case .AirQualityIndex: return "Air Quality Index"
        case .Education: return "Education"
        case .Complaint: return "Complaint"
        case .Explore: return "Explore"
        }
    }
    
    var image: UIImage {
        switch self {
        case .Map: return UIImage(named: "map") ?? UIImage()
        case .AirQualityIndex: return UIImage(named: "aqiicon") ?? UIImage()
        case .Education: return UIImage(named: "education") ?? UIImage()
        case .Complaint: return UIImage(named: "complaint") ?? UIImage()
        case .Explore: return UIImage(named: "explore") ?? UIImage()
        }
    }
    
    case Map
    case AirQualityIndex
    case Education
    case Complaint
    case Explore
}
