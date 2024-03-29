//
//  Missions.swift
//
//
//  Created by Paul on 01.09.23.
//

import Foundation

fileprivate let session = URLSession(configuration: .default)


internal func restMissionAlarm(csrfToken: String, missionId: Int, vehicleIds: Set<Int>) async -> Bool {
    var request = URLRequest(url: lssMissionAlarmURL(missionId), cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 5.0)
    postDefaultHeaderWithContentTypeForm(request: &request, csrfToken: csrfToken, url: lssMissionAlarmURL(missionId))
    
    let allowedCharacters = CharacterSet(charactersIn: "!*'();:@&=+$,/?%#[]").inverted

    // Encode the string
    guard let encodedCsrfToken = csrfToken.addingPercentEncoding(withAllowedCharacters: allowedCharacters) else {
        return false
    }
    
    var formDataString = "utf8=%E2%9C%93&authenticity_token=\(encodedCsrfToken)&commit=Alarmieren&next_mission=0&alliance_mission_publish=0"
    for vehicleId in vehicleIds {
        formDataString.append("&vehicle_ids[]=\(vehicleId)")
    }
    
    request.httpBody = formDataString.data(using: .utf8)
    
    let session = URLSession.shared
    
    if let (_, response) = try? await session.data(for: request),
       let httpResponse = response as? HTTPURLResponse {
        return httpResponse.statusCode == 200
    }
    
    return false
}
