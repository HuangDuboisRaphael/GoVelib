//
//  HomeView.swift
//  GoVelib
//
//  Created by Raphaël Huang-Dubois on 18/06/2022.
//

import SwiftUI
import MapKit

// Main view which displays the map.
struct HomeView: View {
    
    // MARK: - Properties
    
    @StateObject private var locationViewModel = LocationViewModel()
    @StateObject private var stationViewModel = StationViewModel()
    
    @State private var selectedStation = Station(name: "", stationCode: "", ebike: 0, mechanical: 0, coordinates: CLLocationCoordinate2D(latitude: 0, longitude: 0), numBikesAvailable: 0, numDocksAvailable: 0, isRenting: true, city: "")
    @State private var selectedStationCoordinates = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    @State private var directions: [String] = []
    @State private var distanceInMeters = CLLocationDistance()
    @State private var isAskingForDirections = false
    @State private var isShowingSheet = false
    @State private var isRotating = false
    @State private var finishLoading = false
    @State private var alertNetworkDescription = ""
    @State private var isShowingNetworkAlert = false
    
    private let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()

    // MARK: - Body
    
    var body: some View {
        
        ZStack(alignment: .topLeading) {
            
            // To display custom mapview.
            MapView(region: $locationViewModel.region, annotations: $stationViewModel.annotations, downloadedStations: $stationViewModel.downloadedStations, selectedStation: $selectedStation, selectedStationCoordinates: $selectedStationCoordinates, directions: $directions, distanceInMeters: $distanceInMeters, isAskingForDirections: $isAskingForDirections, isShowingSheet: $isShowingSheet)
                .isHidden(locationViewModel.didSaveUserLocation ? false : true)
                .ignoresSafeArea()
            
                // Asking for user permission.
                .onAppear {
                    locationViewModel.checkIfLocationServicesIsEnabled()
                }
            
                // Once the user's position is determined, trigger API call.
                .onChange(of: locationViewModel.didSaveUserLocation) { _ in
                    stationViewModel.getVelibStations(userLocation: String(locationViewModel.region.center.latitude) + "," + String(locationViewModel.region.center.longitude)) { alert in
                        self.alertNetworkDescription = alert
                        print(alertNetworkDescription)
                    } completionIsShowing: { isShowing in
                        self.isShowingNetworkAlert = isShowing
                        print(isShowingNetworkAlert)
                    }
                }
                // Network error alert.
                .alert(isPresented: $isShowingNetworkAlert) {
                    Alert(title: Text(self.alertNetworkDescription))
                }
            
            // Refresh data button with rotating animation.
            Button {
                finishLoading = false
                isRotating = true
                stationViewModel.getVelibStations(userLocation: String(locationViewModel.region.center.latitude) + "," + String(locationViewModel.region.center.longitude)) { alert in
                    self.alertNetworkDescription = alert
                } completionIsShowing: { isShowing in
                    self.isShowingNetworkAlert = isShowing
                } completion: {
                    if isShowingNetworkAlert {
                        isRotating = false
                    } else {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            isRotating = false
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                                finishLoading = true
                            }
                        }
                    }
                }
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .frame(width: 36, height: 36)
                        .foregroundColor(.white).opacity(0.8)
                    
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .font(.system(size: 20))
                        .foregroundColor(.black)
                        .rotationEffect(.degrees(isRotating ? 360 : 0))
                        .animation(.easeIn(duration: 0.8).repeatCount(isRotating ? .max : 0, autoreverses: false), value: isRotating)
                    
                    Image(systemName: "checkmark")
                        .font(.system(size: 10))
                        .foregroundColor(.black)
                        .isHidden(finishLoading ? false : true)
 
                }.offset(x: 19, y: 70)
                .isHidden(locationViewModel.didSaveUserLocation ? false : true)
            }.buttonStyle(.plain)
            
            // User permission denied alert.
            .alert(isPresented: $locationViewModel.permissionDenied, content: {
                Alert(title: Text("Permission Denied"), message: Text(locationViewModel.alertDescription), dismissButton: .default(Text("Go to Settings"), action: {
                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                }))
            })
        }
        // To put the refresh button back to its initial render.
        .onReceive(timer) { _ in
            if finishLoading {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    finishLoading = false
                }
            }
        }
        // To instance the half modal sheet.
        .halfSheet(showSheet: $isShowingSheet) {
            DetailsSelectedStationView(locationViewModel: locationViewModel, selectedStation: $selectedStation, isAskingForDirections: $isAskingForDirections, directions: $directions, distanceInMeters: $distanceInMeters)
        }
    }
}
