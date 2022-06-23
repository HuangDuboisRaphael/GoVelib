//
//  StationViewModelTestCase.swift
//  GoVelibTests
//
//  Created by Raphaël Huang-Dubois on 22/06/2022.
//

import XCTest
import MapKit
@testable import GoVelib

class StationViewModelTestCase: XCTestCase {
    
    private var stationViewModel: StationViewModel!
    private let url = "https://opendata.paris.fr/api/records/1.0/search/?dataset=velib-disponibilite-en-temps-reel&rows=10&geofilter.distance=48.917402,2.269675,2500"
        
    override func setUp() {
        super.setUp()
        stationViewModel = StationViewModel()
    }
    
    func testGivenFunctionConvertIntoBool_WhenIsGivingOUIAsString_ThenObtainTrue() {
        XCTAssertEqual(stationViewModel.convertIntoBool(isRenting: "OUI"), true)
    }
    func testGivenFunctionConvertIntoBool_WhenIsGivingOtherString_ThenObtainFalse() {
        XCTAssertEqual(stationViewModel.convertIntoBool(isRenting: "NON"), false)
    }
        
    func testGivenFunctionConvertCoordinates_WhenIsGivingADouble_ThenObtainValidLocationCoordinates() {
        let coordinates: [Double] = [48.915885074177, 2.2682306702811]
        XCTAssertEqual(stationViewModel.convertCoordinates(coordinates: coordinates), CLLocationCoordinate2D(latitude: 48.915885074177, longitude: 2.2682306702811))
    }
}
