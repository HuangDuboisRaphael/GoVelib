//
//  FakeResponseData.swift
//  GoVelibTests
//
//  Created by Raphaël Huang-Dubois on 22/06/2022.
//

import SwiftUI

class FakeResponseData {
    
    // MARK: - Data
    
    static var stationCorrectData: Data? {
        let bundle = Bundle(for: FakeResponseData.self)
        let url = bundle.url(forResource: "Station", withExtension: "json")!
        return try? Data(contentsOf: url)
    }
    
    static let incorrectData = "erreur".data(using: .utf8)
    
    // MARK: - Response
    
    static let responseOK = HTTPURLResponse(
        url: URL(string: "https://opendata.paris.fr/api/records/1.0/search/?dataset=velib-disponibilite-en-temps-reel&rows=10&geofilter.distance=48.917402,2.269675,2500")!,
        statusCode: 200, httpVersion: nil, headerFields: [:])!

    static let responseKO = HTTPURLResponse(
        url: URL(string: "https://opendata.paris.fr/api/records/1.0/search/?dataset=velib-disponibilite-en-temps-reel&rows=10&geofilter.distance=48.917402,2.269675,2500")!,
        statusCode: 500, httpVersion: nil, headerFields: [:])!
    
    // MARK: - Error
    
    class ServiceError: Error {}
    static let error = ServiceError()
}
