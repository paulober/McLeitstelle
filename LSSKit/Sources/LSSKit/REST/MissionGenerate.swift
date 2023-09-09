//
//  MissionGenerate.swift
//
//
//  Created by Paul on 07.09.23.
//

import Foundation

internal func restMissionGenerate(csrfToken: String) async -> Bool {
    var url = lssBaseURL.appendingPathComponent("mission-generate")
    url.append(queryItems: [URLQueryItem(name: "_", value: String(Date().timeIntervalSince1970))])
    var request = URLRequest(url: url)
    getDefaultHeader(request: &request, csrfToken: csrfToken, url: url)
    
    if let (_, response) = try? await URLSession.shared.data(for: request),
       let httpResponse = response as? HTTPURLResponse {
        return httpResponse.statusCode == 200
    } else {
        print("[LssKit, restMissionGenerate] Error on-request.")
    }
    
    return false
}
