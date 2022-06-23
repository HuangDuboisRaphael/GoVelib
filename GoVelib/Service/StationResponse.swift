//
//  StationResponse.swift
//  GoVelib
//
//  Created by Raphaël Huang-Dubois on 13/06/2022.
//

import SwiftUI

// To parse Json API's data.
struct StationResponse: Codable {
    let nhits: Int
    let records: [Records]
}

struct Records: Codable {
    let fields: Fields
}

struct Fields: Codable {
    let name: String
    let stationcode: String
    let ebike: Int
    let mechanical: Int
    let coordonnees_geo: [Double]
    let numbikesavailable: Int
    let numdocksavailable: Int
    let is_renting: String
    let nom_arrondissement_communes: String
}
