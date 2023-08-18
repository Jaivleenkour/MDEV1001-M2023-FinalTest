//
//  Building.swift
//  MDEV1001-M2023-FinalTest
//
//  Created by Jaivleen Kour on 2023-08-18.
//

import Foundation

struct Building: Codable {
    var documentID: String?
    var name: String
    var type: String
    var dateBuilt: Int
    var city: String
    var country: String
    var description: String
    var architects: String
    var cost: String
    var website: String
    var imageURL: String
    
    
}
