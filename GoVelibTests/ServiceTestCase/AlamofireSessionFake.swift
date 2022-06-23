//
//  URLSessionFake.swift
//  GoVelibTests
//
//  Created by Raphaël Huang-Dubois on 22/06/2022.
//

import SwiftUI
import Alamofire
@testable import GoVelib

class AlamofireSessionFake: NetworkRequest {
    
    // MARK: - Properties
    
    var data: Data?
    var response: HTTPURLResponse?
    var error: Error?
    
    // MARK: - Initialization
    
    init(data: Data?, response: HTTPURLResponse?, error: Error?) {
        self.data = data
        self.response = response
        self.error = error
    }
    
    // MARK: - Method
    
    func request(with url: URL, completionHandler: @escaping (Data?, Error?, HTTPURLResponse?) -> Void) {
        return completionHandler(data, error, response)
    }
}
