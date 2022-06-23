//
//  StationService.swift
//  GoVelib
//
//  Created by Raphaël Huang-Dubois on 14/06/2022.
//

import SwiftUI

// To handle error related to network.
enum NetworkError: Error {
    case stationsNotFound
    case serverSideError
    case transportError
}

// To prepare the API's calling network request.
class StationService {
    
    private let session: NetworkRequest
    
    init(session: NetworkRequest = StationSession()) {
        self.session = session
    }
    
    func getVelibStations(url: String , completionHandler : @escaping (Result<StationResponse, NetworkError>) -> Void) {

        guard let url = URL(string: url) else {
            completionHandler(.failure(NetworkError.stationsNotFound))
            return
        }
        
        session.request(with: url) { (data, error, response) in
            
            guard let data = data, error == nil else {
                completionHandler(.failure(NetworkError.transportError))
                return
            }

            guard let response = response, response.statusCode == 200 else {
                completionHandler(.failure(NetworkError.serverSideError))
                return
            }
                
            do {
                let responseJSON = try JSONDecoder().decode(StationResponse.self, from: data)
                    
                DispatchQueue.main.async {
                    completionHandler(.success(responseJSON))
                }
            } catch {
                DispatchQueue.main.async {
                    completionHandler(.failure(NetworkError.stationsNotFound))
                }
            }
        }
    }
}
