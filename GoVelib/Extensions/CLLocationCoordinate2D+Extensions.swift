//
//  CLLocationCoordinate2D+Extensions.swift
//  GoVelib
//
//  Created by Raphaël Huang-Dubois on 22/06/2022.
//

import MapKit

// To let CLLocationCoordinate2D adopt the Equatable protocol.
extension CLLocationCoordinate2D: Equatable {}

public func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
    return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
}
