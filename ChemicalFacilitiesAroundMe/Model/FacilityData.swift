//
//  FacilityData.swift
//  ChemicalFacilitiesAroundMe
//
//  Created by Haotian Shen on 10/13/20.
//

import UIKit

struct FacilityData: Codable {
    let candidates: [Candidate]
    let status: String
}

struct Candidate: Codable {
    let formatted_address: String
    let name: String
    let place_id: String
}
