//
//  SignUpHTML.swift
//
//
//  Created by Paul on 03.09.23.
//

import Foundation

internal func scanSignUpHTML() async -> FayeCredentials? {
    let url = lssBaseURL.appendingPathComponent("users/sign_up")
    
    var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 5)
    request.httpMethod = "GET"
    // don't send any cookies with the request to only get new stuff
    request.httpShouldHandleCookies = false
    let session = URLSession.shared
    
    if let (data, response) = try? await session.data(for: request),
        let httpResponse = response as? HTTPURLResponse {
        if httpResponse.statusCode != 200 {
            return nil
        }
        
        var creds: FayeCredentials = FayeCredentials(stripeMid: "", sessionId: "", mcUniqueClientId: "", rememberUserToken: "")
        
        // see if i can get some cookies
        if let allCookies = httpResponse.value(forHTTPHeaderField: "Set-Cookie") {
            // Parse the cookie string into HTTPCookie objects
            let cookies = HTTPCookie.cookies(withResponseHeaderFields: ["Set-Cookie": allCookies], for: response.url!)
            
            // set cookies
            for cookie in cookies {
                switch cookie.name {
                
                case Cookie.sessionID.rawValue:
                    creds.sessionId = cookie.value
                case Cookie.mcUniqueClientID.rawValue:
                    creds.mcUniqueClientId = cookie.value
                
                // will not be delievered
                //case Cookie.stripeMid.rawValue:
                //    creds.stripeMid = cookie.value
                // will not be delivered
                //case Cookie.rememberUserToken.rawValue:
                //    creds.rememberUserToken = cookie.value
                    
                default:
                    break
                }
            }
        }
        
        let html = String(data: data, encoding: .utf8) ?? ""
        let userDetails = await htmlExtractUserDetails(from: html, indexHTML: html)
        for detail in userDetails {
            switch detail {
            case .userID(let userID):
                creds.userId = userID
            case .userName(let userName):
                creds.userName = userName
            case .allianceId(let allianceId):
                creds.allianceId = allianceId
            case .extensions(let extensions, let allianceGuid):
                creds.exts = extensions
                if let allianceGuid = allianceGuid {
                    creds.allianceGuid = allianceGuid
                }
            case .csrfToken(let csrfToken):
                creds.csrfToken = csrfToken
            case .missionSpeed(let missionSpeed):
                creds.missionSpeed = missionSpeed
            case .latLong(let lat, let long):
                creds.mapView = (lat, long)
            }
        }
        
        return creds
    }
    
    return nil
}
