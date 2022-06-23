//
//  LocationViewModel.swift
//  GoVelib
//
//  Created by Raphaël Huang-Dubois on 15/06/2022.
//

import MapKit

// Default properties to instance MKCoordinateRegion.
enum MapDetails {
    static let startingLocation = CLLocationCoordinate2D(latitude: 48.858370, longitude: 2.294481)
    static let defaultSpan = MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)
}

// Various properties and methods related to location manager (to authorize and catch the user's position).
class LocationViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    // MARK: - Properties
    
    @Published var region = MKCoordinateRegion(center: MapDetails.startingLocation, span: MapDetails.defaultSpan)
    @Published var permissionDenied = false
    @Published var alertDescription = ""
    @Published var didSaveUserLocation = false
    
    var locationManager: CLLocationManager?
    
    // MARK: - Methods
    
    func checkIfLocationServicesIsEnabled() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager = CLLocationManager()
            locationManager?.delegate = self
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization()
    }
    
    private func checkLocationAuthorization() {
        guard let locationManager = locationManager else { return }

        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            self.alertDescription = "Your location is restricted likely due to parental controls"
            self.permissionDenied = true
        case .denied:
            self.alertDescription = "Please enable permission in App Settings"
            self.permissionDenied = true
        case .authorizedAlways, .authorizedWhenInUse:
            if let location = locationManager.location {
                region = MKCoordinateRegion(center: location.coordinate, span: MapDetails.defaultSpan)
            }
            didSaveUserLocation = true
        @unknown default:
            break
        }
    }
    
    // To display readable distance.
    func convertDistance(_ givenDistance: CLLocationDistance) -> String {
        let distance = Double(givenDistance)
        if distance >= 1000 {
            let km = distance / 1000
            let round = Double(round(10 * km) / 10)
            return String(round) + " km"
        } else {
            let round = Int(distance.rounded())
            return String(round) + " m"
        }
    }
}
