//
//  Einsaetze.swift
//
//
//  Created by Paul on 02.09.23.
//

import Foundation

internal func restEinsaetze() async -> [LssMission] {
    let url = lssBaseURL.appending(path: "/einsaetze.json")
    
    let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 5.0)
    
    let session = URLSession.shared
    if let (data, response) = try? await session.data(for: request) {
        if let urlResponse = response as? HTTPURLResponse,
           urlResponse.statusCode != 200 {
            print("[LssKit, restEinsaetze] Non success reponse status-code.")
            return []
        }
        
        do {
            let decoder = JSONDecoder()
            let einsaetze = try decoder.decode([LssMission].self, from: data)
            return einsaetze
        } catch let error as DecodingError {
            print("[LssKit, restEinsaetze] Unable to decode response: \(error)")
        } catch {}
    } else {
        print("[LssKit, restEinsaetze] Error on-request.")
    }
    
    return []
}
