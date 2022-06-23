//
//  DetailsSelectedStationView.swift
//  GoVelib
//
//  Created by Raphaël Huang-Dubois on 20/06/2022.
//

import SwiftUI
import MapKit

// To display selected station information and itineray directions.
struct DetailsSelectedStationView: View {
    
    // MARK: - Properties
    
    @ObservedObject var locationViewModel: LocationViewModel
    
    @Binding var selectedStation: Station
    @Binding var isAskingForDirections: Bool
    @Binding var directions: [String]
    @Binding var distanceInMeters: CLLocationDistance
    
    // MARK: - Body
    
    var body: some View {
        
        ZStack {
            
            ScrollView {
    
                HStack {
            
                    VStack(alignment: .leading, spacing: 26) {
            
                        VStack(alignment: .leading, spacing: 18) {
                            
                            HStack {
                                // To display selected station name and city.
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(selectedStation.name)
                                        .font(.custom("AmericanTypewriter", size: 21)).bold()
                                        .foregroundColor(.black)
                                        .lineLimit(1)
                
                                    Text(selectedStation.city)
                                        .font(.custom("AmericanTypewriter", size: 21))
                                        .foregroundColor(.customBlack)
                                }
                                Spacer()
                                
                                // To instance and display ask directions button.
                                VStack {
                                    Button {
                                        isAskingForDirections = true
                                    } label: {
                                        Image(systemName: "figure.walk.diamond")
                                            .foregroundColor(.blue)
                                            .font(.system(size: 35))
                                    }
                                    Text("DIRECTIONS")
                                        .foregroundColor(.blue).bold()
                                        .font(.system(size: 10))
                                }
                            }
            
                            Divider()
            
                            // Selected station code.
                            Text("Station nº" + selectedStation.stationCode)
                                .font(.custom("ArialMT", size: 19))
                                .padding(.top, 3)
                            }
                        
                        ZStack {
                            // To display selected station bike repartition.
                            VStack(spacing: 17) {
                                ShowDetailsHStack(spacing: 22, image: "bicycle", imageSize: 70, color: .mechanicalGreen, imageLeading: 0, number: String(selectedStation.ebike), text: " mechanical left")
                                
                                ShowDetailsHStack(spacing: 22, image: "bicycle", imageSize: 70, color: .ebikeBlue, imageLeading: 0, number: String(selectedStation.mechanical), text: " electric left")
                                
                                ShowDetailsHStack(spacing: 28, image: "parkingsign.circle.fill", imageSize: 58, color: .parkingBlue, imageLeading: 6, number: String(selectedStation.numDocksAvailable), text: " docks left")
                                    .padding(.top, 8)
                            }.isHidden(selectedStation.isRenting ? false : true)
                            
                            // If selected station is not operational, display under construction information.
                            VStack {
                                Image("ConstructionPin")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 200, height: 200)
                                
                                Text("This station is under construction.")
                                    .font(.system(size: 20))
                                    .italic().bold()
                            }.padding(.top, -20)
                            .isHidden(selectedStation.isRenting ? true : false)
                        }
                    }
                    Spacer()
                }
            }.isHidden(isAskingForDirections ? true : false)
            .padding()
            .padding(.top, 10)
                
            // If user is asking for an itinerary, reorganize view elements and display distance in meters and directions.
            ScrollView {
                VStack(spacing: 25) {
                    
                    HStack(spacing: 10) {
                        FigureWalkingImage()
                        
                        Text(String(locationViewModel.convertDistance(distanceInMeters)))
                            .font(.custom("AmericanTypewriter", size: 30)).bold()
                        
                        FigureWalkingImage()
                    }.padding(.bottom, 5)
                
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(directions, id: \.self) { direction in
                            Text(direction)
                                .font(.headline)
                                .italic()
                        
                            Divider()
                        }
                    }
                Spacer()
                }
            }.padding()
            .padding(.top, 13)
            .isHidden(isAskingForDirections ? false : true)
        }
    }
}

// MARK: - Refactoring views

struct ShowDetailsHStack: View {
    
    var spacing: CGFloat
    var image: String
    var imageSize: CGFloat
    var color: Color
    var imageLeading: CGFloat
    var number: String
    var text: String
    
    var body: some View {
        HStack(spacing: spacing) {
            Image(systemName: image)
                .resizable()
                .scaledToFit()
                .frame(width: imageSize, height: imageSize)
                .foregroundColor(color)
                .padding(.leading, imageLeading)

            HStack(spacing: 2) {
                Text(number)
                    .font(.custom("ArialMT", size: 42))
                    .foregroundColor(color).bold()

                Text(text)
                    .font(.custom("ArialMT", size: 24))
                    .foregroundColor(color).bold()
                }
            Spacer()
        }
    }
}

struct FigureWalkingImage: View {
    
    var body: some View {
        Image(systemName: "figure.walk")
            .font(.title)
            .foregroundColor(.blue)
    }
}
