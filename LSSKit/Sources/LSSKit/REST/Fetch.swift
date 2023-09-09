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
public func fetchData<T: Decodable>(_ endpointURL: URL, responseType: T.Type) -> AnyPublisher<T, Error> {
    var request = URLRequest(url: endpointURL)
        
    // Set cookies if provided
    if let cookies = lssCookies[lssBaseURL] {
        let jar = HTTPCookieStorage.shared
        jar.setCookies(cookies, for: endpointURL, mainDocumentURL: endpointURL)
        
        let headers = HTTPCookie.requestHeaderFields(with: cookies)
        request.allHTTPHeaderFields = headers
    }
    
    return URLSession.shared.dataTaskPublisher(for: request)
        .map(\.data)
        .decode(type: responseType, decoder: JSONDecoder())
        .eraseToAnyPublisher()
}

public func fetchDataAlt<T: Decodable>(_ endpointURL: URL, responseType: T.Type) async -> T? {
    var request = URLRequest(url: endpointURL)
        
    // Set cookies if provided
    if let cookies = lssCookies[lssBaseURL] {
        let jar = HTTPCookieStorage.shared
        jar.setCookies(cookies, for: endpointURL, mainDocumentURL: endpointURL)
        
        let headers = HTTPCookie.requestHeaderFields(with: cookies)
        request.allHTTPHeaderFields = headers
    }
    
    if let (data, response) = try? await URLSession.shared.data(for: request),
        let httpResponse = response as? HTTPURLResponse {
        print("Response status code: \(httpResponse.statusCode)")
        print("Data: \(String(data: data, encoding: .utf8) ?? "N/A")")
        
        do {
            let decoder = JSONDecoder()
            let result = try decoder.decode(responseType, from: data)
            return result
        } catch {
            print("Nice error")
        }
    }
    
    return nil
}

public func fetchDataAltWrapper<T: Decodable>(_ endpointURL: URL, responseType: T.Type) -> AnyPublisher<T, Error> {
    return Future<T, Error> { promise in
        Task {
            let result = await fetchDataAlt(endpointURL, responseType: responseType)
            if let result = result {
                promise(.success(result))
            } else {
                return promise(.failure(NSError(domain: "nice.domain", code: 123)))
            }
        }
    }
    .eraseToAnyPublisher()
}

