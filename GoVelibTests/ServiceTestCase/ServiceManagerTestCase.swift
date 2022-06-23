//
//  ServiceManagerTestCase.swift
//  GoVelibTests
//
//  Created by Raphaël Huang-Dubois on 22/06/2022.
//

import XCTest
@testable import GoVelib

class ServiceManagerTestCase: XCTestCase {
    
    private let url = "https://opendata.paris.fr/api/records/1.0/search/?dataset=velib-disponibilite-en-temps-reel&rows=10&geofilter.distance=48.917402,2.269675,2500"
    
    func testGetVelibStationsShouldPostTransportErrorIfError() {
        
        // Given
        let stationSession = StationService(session: AlamofireSessionFake(data: nil, response: nil, error: FakeResponseData.error))

        // When
        let expectation = XCTestExpectation(description: "Wait for queue change.")
        stationSession.getVelibStations(url: url) { result in
            
        // Then
            switch result {
            case .success(let data):
                XCTAssertNil(data)
                expectation.fulfill()
            case .failure(let error):
                XCTAssertEqual(error, NetworkError.transportError)
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 0.01)
    }
    
    func testGetVelibStationsShouldPostTransportErrorIfNoData() {
        
        // Given
        let stationSession = StationService(session: AlamofireSessionFake(data: nil, response: nil, error: nil))

        // When
        let expectation = XCTestExpectation(description: "Wait for queue change.")
        stationSession.getVelibStations(url: url) { result in
            
        // Then
            switch result {
            case .success(let data):
                XCTAssertNil(data)
                expectation.fulfill()
            case .failure(let error):
                XCTAssertEqual(error, NetworkError.transportError)
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 0.01)
    }
    
    func testGetVelibStationsShouldPostServerSideErrorIfIncorrectResponse() {
        // Given
        let stationSession = StationService(session: AlamofireSessionFake(data: FakeResponseData.stationCorrectData, response: FakeResponseData.responseKO, error: nil))

        // When
        let expectation = XCTestExpectation(description: "Wait for queue change.")
        stationSession.getVelibStations(url: url) { result in
            
        // Then
            switch result {
            case .success(let data):
                XCTAssertNil(data)
                expectation.fulfill()
            case .failure(let error):
                XCTAssertEqual(error, NetworkError.serverSideError)
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 0.01)
    }
    
    func testGetVelibStationsShouldPostStationsNotFoundIfIncorrectData() {
        // Given
        let stationSession = StationService(session: AlamofireSessionFake(data: FakeResponseData.incorrectData, response: FakeResponseData.responseOK, error: nil))
        
        // When
        let expectation = XCTestExpectation(description: "Wait for queue change.")
        stationSession.getVelibStations(url: url) { result in
            
        // Then
            switch result {
            case .success(let data):
                XCTAssertNil(data)
                expectation.fulfill()
            case .failure(let error):
                XCTAssertEqual(error, NetworkError.stationsNotFound)
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 0.01)
    }
    
    func testGetVelibStationsShouldPostStationsNotFoundIfIncorrectUrl() {
        // Given
        let stationSession = StationService(session: AlamofireSessionFake(data: nil, response: nil, error: nil))

        // When
        let expectation = XCTestExpectation(description: "Wait for queue change.")
        stationSession.getVelibStations(url: "") { result in
            
        // Then
            switch result {
            case .success(let data):
                XCTAssertNil(data)
                expectation.fulfill()
            case .failure(let error):
                XCTAssertEqual(error, NetworkError.stationsNotFound)
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 0.01)
    }
    
    func testGetVelibStationsShouldPostSuccessIfNoErrorAndCorrectData() {
        // Given
        let stationSession = StationService(session: AlamofireSessionFake(data: FakeResponseData.stationCorrectData, response: FakeResponseData.responseOK, error: nil))
        
        // When
        let expectation = XCTestExpectation(description: "Wait for queue change.")
        stationSession.getVelibStations(url: url) { result in
            
        // Then
            let name = "Hispano Suiza - Parc des Bruyères"
            
            switch result {
            case .success(let data):
                XCTAssertNotNil(data)
                XCTAssertEqual(data.records[0].fields.name, name)
                expectation.fulfill()
            case .failure(let error):
                XCTAssertNil(error)
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 0.5)
    }
}
