//
//  Fetch.swift
//
//
//  Created by Paul on 02.09.23.
//

import Foundation
import Combine

/**
 if let url = URL(string: "https://your-api-endpoint.com/data") {
     fetchData(url, responseType: MyObject.self)
         .sink(receiveCompletion: { completion in
             switch completion {
             case .finished:
                 break
             case .failure(let error):
                 // Handle the error
                 print("Error: \(error)")
             }
         }, receiveValue: { responseObject in
             // Handle the responseObject of type MyObject
             print(responseObject)
         })
         .store(in: &cancellables) // Make sure to hold a reference to the cancellable
 }
 */
internal func fetchData<T: Decodable>(_ endpointURL: URL, responseType: T.Type) -> AnyPublisher<T, Error> {
    // TODO: maybe set cookies
    URLSession.shared.dataTaskPublisher(for: endpointURL)
        .map(\.data)
        .decode(type: responseType, decoder: JSONDecoder())
        .eraseToAnyPublisher()
}
