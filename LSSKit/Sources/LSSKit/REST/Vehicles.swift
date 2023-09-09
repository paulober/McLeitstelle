//
//  Vehicles.swift
//
//
//  Created by Paul on 01.09.23.
//

import Foundation

fileprivate let session = URLSession.shared

internal func restSendPatientToHospital(csrfToken: String, vehicleId: Int, hospitalId: Int) async -> Bool {    
    let url = lssIVehiclesURL(vehicleId).appendingPathComponent("patient/\(hospitalId)")
    
    var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 5.0)
    getDefaultHeaderWithContentTypeForm(request: &request, csrfToken: csrfToken, url: url)
    
    if let (_, response) = try? await session.data(for: request) {
        if let httpResponse = response as? HTTPURLResponse {
            if httpResponse.statusCode == 200 {
                return true
            }
        }
    } else {
        print("[LssKit, restSendPatientToHospital] Error on-request.")
    }
    
    return false
}

internal func restBackalarmVehicle(_ vehicleId: Int, csrfToken: String, missionId: Int? = nil) async -> Bool {
    let url = lssBaseURL.appendingPathComponent("vehicles/\(vehicleId)/backalarm").appending(queryItems: [URLQueryItem(name: "return", value: "mission_js")])
    var request = URLRequest(url: url)
    getDefaultHeader(request: &request, csrfToken: csrfToken)
    if let missionId = missionId {
        request.setValue(lssBaseURL.appendingPathComponent("missions/\(missionId)").absoluteString, forHTTPHeaderField: "Referer")
    }
    
    if let (_, response) = try? await session.data(for: request),
        let httpResponse = response as? HTTPURLResponse {
        return httpResponse.statusCode == 200
    }
    
    return false
}
