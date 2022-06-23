//
//  MapView.swift
//  GoVelib
//
//  Created by Raphaël Huang-Dubois on 18/06/2022.
//

import SwiftUI
import MapKit

// MARK: - Representable

// To instance a custom map view.
struct MapView: UIViewRepresentable {

    @Binding var region: MKCoordinateRegion
    @Binding var annotations: [MKPointAnnotation]
    @Binding var downloadedStations: [Station]
    @Binding var selectedStation: Station
    @Binding var selectedStationCoordinates: CLLocationCoordinate2D
    @Binding var directions: [String]
    @Binding var distanceInMeters: CLLocationDistance
    @Binding var isAskingForDirections: Bool
    @Binding var isShowingSheet: Bool

    var selectedStationTitle: String?
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIView(context: Context) -> MKMapView {
        
        // To instance delegate and basic map features.
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        mapView.region = region
        mapView.tintColor = .uiCustomBlack
        
        // To create the tracking button to centralize the map on the user's position.
        let trackingButton = MKUserTrackingButton(mapView: mapView)
        trackingButton.layer.backgroundColor = UIColor(white: 1, alpha: 0.8).cgColor
        trackingButton.layer.cornerRadius = 8
        trackingButton.translatesAutoresizingMaskIntoConstraints = false
        mapView.addSubview(trackingButton)
        trackingButton.leadingAnchor.constraint(equalTo: mapView.layoutMarginsGuide.leadingAnchor, constant: 19).isActive = true
        trackingButton.topAnchor.constraint(equalTo: mapView.layoutMarginsGuide.topAnchor, constant: 20).isActive = true

        return mapView
    }

    func updateUIView(_ view: MKMapView, context: Context) {
        
        // To display or refresh map annotations.
        if annotations.count != view.annotations.count {
            view.addAnnotations(annotations)
        }
        
        if isAskingForDirections {
            // To instance and apply the user's requested itinerary separating the user's position to the selected station.
            let firstPlacemark = MKPlacemark(coordinate: region.center)
            let secondPlacemark = MKPlacemark(coordinate: selectedStationCoordinates)
            let request = MKDirections.Request()
            request.source = MKMapItem(placemark: firstPlacemark)
            request.destination = MKMapItem(placemark: secondPlacemark)
            request.transportType = [.walking]

            // To instance and store the user's requested directions separating the user's position to the selected station.
            let directions = MKDirections(request: request)
            directions.calculate { response, error in
                if error == nil {
                    guard let route = response?.routes.first else { return }
                    view.addOverlay(route.polyline)
                    view.setVisibleMapRect(
                           route.polyline.boundingMapRect,
                           edgePadding: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20),
                           animated: true)
                    self.directions = route.steps.map { $0.instructions }.filter { !$0.isEmpty }
                }
            }
        } else {
            // To remove precedent itineray.
            let overlays = view.overlays
            view.removeOverlays(overlays)
        }
    }
    
    // MARK: - Coordinator
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView
        
        init(parent: MapView) {
            self.parent = parent
        }

        // To instance custom annotations properties.
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            var identifier = ""
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            
            // To differentiate custom annotations from user pin.
            if annotation is MKPointAnnotation {
                
                if annotationView == nil {
                    if let index = parent.downloadedStations.firstIndex(where: {$0.name == annotation.title}) {
                        
                        // To associate the right custom annotation to functional or under construction station.
                        if parent.downloadedStations[index].isRenting {
                            identifier = "Bike"
                            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                            annotationView?.image = textToImage(drawText: String(parent.downloadedStations[index].numBikesAvailable), inImage: UIImage(named: "BikePin") ?? UIImage())
                            annotationView?.frame.size = CGSize(width: 50, height: 50)
                        } else {
                            identifier = "Construction"
                            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                            annotationView?.image = UIImage(named: "ConstructionPin")
                            annotationView?.frame.size = CGSize(width: 50, height: 50)
                        }
                    }
                    // To instance the bubble callout and the right callout accessory view.
                    annotationView?.canShowCallout = true
                    let rightButton = UIButton(type: .detailDisclosure)
                    rightButton.addTarget(self, action: #selector(didClickDetailDisclosure), for: .touchUpInside)
                    annotationView?.rightCalloutAccessoryView = rightButton
                } else {
                    annotationView?.annotation = annotation
                }
            }
            return annotationView
        }
        
        // To trigger methods when an annotation is selected.
        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            
            // To erase precedent itinerary.
            parent.isAskingForDirections = false
            
            if let annotation = view.annotation {
                
                // To store the station coordinates and name selected by the user.
                parent.selectedStationCoordinates = annotation.coordinate
                if let title = annotation.title {
                    parent.selectedStationTitle = title
                }
                
                // To get the distance in meters between the user's location and the selected station.
                let firstLocation = toConvertToLocation(parent.region.center.latitude, parent.region.center.longitude)
                let secondLocation = toConvertToLocation(annotation.coordinate.latitude, annotation.coordinate.longitude)
                parent.distanceInMeters = firstLocation.distance(from: secondLocation)
            }
        }
    
        // To instance the properties used for the itinerary renderer.
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = .black
            renderer.lineWidth = 4
            return renderer
        }
        
        // To display the half modal sheet and store the selected station details.
        @objc private func didClickDetailDisclosure() {
            parent.isShowingSheet = true
            if let index = parent.downloadedStations.firstIndex(where: {$0.name == parent.selectedStationTitle}) {
                parent.selectedStation = parent.downloadedStations[index]
            }
        }
        
        // To superpose an image and a string to compose an UIImage.
        private func textToImage(drawText text: String, inImage image: UIImage) -> UIImage {
            let textColor = UIColor.white
            let textFont = UIFont(name: "Helvetica Bold", size: 32)!
            let scale = UIScreen.main.scale
            UIGraphicsBeginImageContextWithOptions(image.size, false, scale)
            let textFontAttributes = [
                NSAttributedString.Key.font: textFont,
                NSAttributedString.Key.foregroundColor: textColor] as [NSAttributedString.Key: Any]
            image.draw(in: CGRect(origin: CGPoint.zero, size: image.size))
            
            if text.count == 1 {
                let rect = CGRect(origin: CGPoint(x: image.size.width / 2.2, y: image.size.height / 1.4), size: image.size)
                text.draw(in: rect, withAttributes: textFontAttributes)
            } else {
                let rect = CGRect(origin: CGPoint(x: image.size.width / 2.5, y: image.size.height / 1.4), size: image.size)
                text.draw(in: rect, withAttributes: textFontAttributes)
            }
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            
            return newImage!
        }
        
        // To convert coordinates into a CLLocation which is the required type to determine a distance.
        private func toConvertToLocation(_ latitude: CLLocationDegrees, _ longitude: CLLocationDegrees) -> CLLocation {
            return CLLocation(latitude: latitude, longitude: longitude)
        }
    }
}
