//
//  Station.swift
//  GoVelib
//
//  Created by Raphaël Huang-Dubois on 15/06/2022.
//

import MapKit

// To store all the variables related to Velib station.
struct Station: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let stationCode: String
    let ebike: Int
    let mechanical: Int
    let coordinates: CLLocationCoordinate2D
    let numBikesAvailable: Int
    let numDocksAvailable: Int
    let isRenting: Bool
    let city: String
    
    // To conform to Equatable protocol.
    static func == (lhs: Station, rhs: Station) -> Bool {
        lhs.id == rhs.id
    }
}
