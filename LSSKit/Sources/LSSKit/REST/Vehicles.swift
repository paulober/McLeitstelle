//
//  Vehicles.swift
//
//
//  Created by Paul on 01.09.23.
//

import Foundation

fileprivate let session = URLSession(configuration: .default)

internal func restSendPatientToHospital(csrfToken: String, vehicleId: Int, hospitalId: Int) async -> Bool {    
    let url = lssIVehiclesURL(vehicleId).appending(component: "/patient/\(hospitalId)")
    
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
