//
//  StationViewModel.swift
//  GoVelib
//
//  Created by Raphaël Huang-Dubois on 13/06/2022.
//

import SwiftUI
import MapKit

// Various properties and methods interacting with the service manager and several views.
class StationViewModel: ObservableObject {

    // MARK: - Properties
    
    @Published var downloadedStations: [Station] = []
    @Published var annotations: [MKPointAnnotation] = []
    @Published var showErrorAlert = false
    @Published var alertDescription = ""
    
    let stationService = StationService()
    
    // Calling retrieved the 10th closest stations from given coordinates.
    private var url: String {
        return "https://opendata.paris.fr/api/records/1.0/search/?dataset=velib-disponibilite-en-temps-reel&rows=10&geofilter.distance=\(userLocation),2500"
    }
    
    // The user's coordinates converted into a string.
    private var userLocation = ""
    
    // MARK: - Methods
    
    // To retrieve Velib API's stations and create an instanced array of MKPointAnnotation to populate the mapview.
    func getVelibStations(userLocation: String, completionAlert: @escaping (String) -> Void, completionIsShowing: @escaping (Bool) -> Void, completion: (() -> Void)? = nil) {
        self.userLocation = userLocation
        
        stationService.getVelibStations(url: url, completionHandler: { result in
            switch result {
            case .success(let data):
                let firstGroup = DispatchGroup()
                for station in data.records {
                    firstGroup.enter()
                    self.downloadedStations.append(Station(name: station.fields.name, stationCode: station.fields.stationcode, ebike: station.fields.ebike, mechanical: station.fields.mechanical, coordinates: self.convertCoordinates(coordinates: station.fields.coordonnees_geo), numBikesAvailable: station.fields.numbikesavailable, numDocksAvailable: station.fields.numdocksavailable, isRenting: self.convertIntoBool(isRenting: station.fields.is_renting), city: station.fields.nom_arrondissement_communes))
                        
                    let annotation = MKPointAnnotation()
                    annotation.title = station.fields.name
                    annotation.coordinate = self.convertCoordinates(coordinates: station.fields.coordonnees_geo)
                    self.annotations.append(annotation)
                    firstGroup.leave()
                }
                firstGroup.notify(queue: .main) {
                    completion?()
                }
                
            // To handle network errors and create alerts in views to warn the user.
            case .failure(let error):
                if error == .stationsNotFound {
                    completionAlert("Impossible to access Velib's API data.")
                    completionIsShowing(true)
                    completion?()
                } else if error == .serverSideError {
                    completionAlert("An internal server error occured during your request.")
                    completionIsShowing(true)
                    completion?()
                } else {
                    completionAlert("Please check your internet connection or try again later.")
                    completionIsShowing(true)
                    completion?()
                }
            }
        })
    }
    
    func refreshVelibStations(userLocation: String, completionAlert: @escaping (String) -> Void, completionIsShowing: @escaping (Bool) -> Void, completion: (() -> Void)? = nil) {
        self.downloadedStations.removeAll()
        self.annotations.removeAll()
        self.getVelibStations(userLocation: userLocation, completionAlert: completionAlert, completionIsShowing: completionIsShowing, completion: completion)
    }
    
    // To convert retrived API's data into valid type.
    func convertIntoBool(isRenting: String) -> Bool {
        if isRenting == "OUI" {
            return true
        } else {
            return false
        }
    }
    
    // To convert retrived API's data into valid type.
    func convertCoordinates(coordinates: [Double]) -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: coordinates[0], longitude: coordinates[1])
    }
}
