//
//  Buildings.swift
//
//
//  Created by Paul on 01.09.23.
//

import Foundation

fileprivate let vehicleMarkerAddRegex = /vehicleMarkerAdd\((.*?)\);/
fileprivate let session = URLSession(configuration: .default)

// TODO: implement /buildings/<building id>/vehiclesMap GET
internal func restBuildingsVehiclesMap(csrfToken: String, buildingIds: [String]) async -> [VehicleMarker] {
    var urlComponents = URLComponents(url: lssBuildingsVehiclesMapURL, resolvingAgainstBaseURL: false)
    var queryItems: [URLQueryItem] = []
    
    for buildingId in buildingIds {
        let queryItem = URLQueryItem(name: "building_ids[]", value: buildingId)
        queryItems.append(queryItem)
    }
    urlComponents?.queryItems = queryItems
    
    guard let url = urlComponents?.url else {
        return []
    }
    
    var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 5.0)
    postDefaultHeaderWithContentTypeForm(request: &request, csrfToken: csrfToken, url: url)
    
    if let (data, response) = try? await session.data(for: request) {
        if let httpResponse = response as? HTTPURLResponse {
            if httpResponse.statusCode != 200 {
                return []
            }
        }
        
        guard let responseBody = String(data: data, encoding: .utf8) else {
            return []
        }
        
        let decoder = JSONDecoder()
        var vehicleMarkers: [VehicleMarker] = []
        
        for match in responseBody.matches(of: vehicleMarkerAddRegex) {
            if  let jsonData = String(match.output.1).data(using: .utf8),
                let vehicleMarker = try? decoder.decode(VehicleMarker.self, from: jsonData) {
                vehicleMarkers.append(vehicleMarker)
            }
        }
        
        return vehicleMarkers
    } else {
        print("[LssKit, restBuildingsVehiclesMap] Error on-request.")
    }
    
    return []
}

internal func restBuildingInfo(csrfToken: String, buildingId: String) async -> LssBuilding? {
    let url = lssBuildingsIDURL(buildingId: buildingId)
    var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 5.0)
    getDefaultHeader(request: &request, csrfToken: csrfToken, url: url)

    if let (data, response) = try? await session.data(for: request) {
        if let httpResponse = response as? HTTPURLResponse,
           httpResponse.statusCode != 200 {
            print("[LssKit, restBuildingInfo] Non success response status code.")
            return nil
        }
        
        do {
            let decoder = JSONDecoder()
            let building = try decoder.decode(LssBuilding.self, from: data)
            return building
        } catch {
            print("[LssKit, restBuildingInfo] Error decoding response.")
        }
    } else {
        print("[LssKit, restBuildingInfo] Error on-request.")
    }
    
    return nil
}
