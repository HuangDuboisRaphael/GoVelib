//
//  StationSession.swift
//  GoVelib
//
//  Created by Raphaël Huang-Dubois on 22/06/2022.
//

import SwiftUI
import Alamofire

// To instance the network session using Alamofire library.
protocol NetworkRequest {
    func request(with url: URL, completionHandler: @escaping (Data?, Error?, HTTPURLResponse?) -> Void)
}

class StationSession: NetworkRequest {
    func request(with url: URL, completionHandler: @escaping (Data?, Error?, HTTPURLResponse?) -> Void) {
        AF.request(url).responseData { (response: AFDataResponse<Data>) in
            completionHandler(response.data, response.error, response.response)
        }
    }
}
