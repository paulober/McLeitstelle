//
//  MissionSpeed.swift
//  
//
//  Created by Paul on 08.09.23.
//

import Foundation

internal func restSetMissionSpeed(csrfToken: String, speed: UInt8) async -> Bool {
    var url = lssBaseURL.appendingPathComponent("missionSpeed")
    url.append(queryItems: [
        URLQueryItem(name: "from_settings", value: "false"),
        URLQueryItem(name: "speed", value: String(speed))
    ])
    var request = URLRequest(url: url)
    getDefaultHeader(request: &request, csrfToken: csrfToken, url: url)
    
    if let (_, response) = try? await URLSession.shared.data(for: request),
       let httpResponse = response as? HTTPURLResponse {
        return httpResponse.statusCode == 200
    }
    
    return false
}
