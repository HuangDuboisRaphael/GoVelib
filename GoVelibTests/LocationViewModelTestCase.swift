//
//  LocationViewModelTestCase.swift
//  GoVelibTests
//
//  Created by Raphaël Huang-Dubois on 22/06/2022.
//

import XCTest
import MapKit
@testable import GoVelib

class LocationViewModelTestCase: XCTestCase {
        
    private var locationViewModel: LocationViewModel!
        
    override func setUp() {
        super.setUp()
        locationViewModel = LocationViewModel()
    }
    
    func testGivenFunctionConvertDistance_WhenIsGivingALocation_ThenConvertToAppropriateString() {
        let shortDistance = CLLocationDistance(150)
        let longDistance = CLLocationDistance(1253)
        XCTAssertEqual(locationViewModel.convertDistance(shortDistance), "150 m")
        XCTAssertEqual(locationViewModel.convertDistance(longDistance), "1.3 km")
    }
}
