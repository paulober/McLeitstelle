//
//  IndexHTML.swift
//
//
//  Created by Paul on 31.08.23.
//

import Foundation

/**
 Downloads lss root html and refreshes cookies.
 */
internal func downloadIndexHTML(from url: URL, creds: inout FayeCredentials) async -> String? {
    var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 5.0)
    if let requestCookies = lssCookies[url] {
        let cookieHeaders = HTTPCookie.requestHeaderFields(with: requestCookies)
        request.allHTTPHeaderFields = cookieHeaders
    }
    
    let session = URLSession(configuration: .default)
    
    do {
        let (data, response) = try await session.data(for: request)
        if let httpResponse = response as? HTTPURLResponse,
           let allCookies = httpResponse.value(forHTTPHeaderField: "Set-Cookie") {
            // Parse the cookie string into HTTPCookie objects
            let cookies = HTTPCookie.cookies(withResponseHeaderFields: ["Set-Cookie": allCookies], for: response.url!)
            
            // Update cookies
            for cookie in cookies {
                switch cookie.name {
                case Cookie.stripeMid.rawValue:
                    creds.stripeMid = cookie.value
                case Cookie.sessionID.rawValue:
                    creds.sessionId = cookie.value
                case Cookie.mcUniqueClientID.rawValue:
                    creds.mcUniqueClientId = cookie.value
                case Cookie.rememberUserToken.rawValue:
                    creds.rememberUserToken = cookie.value
                default:
                    break
                }
            }
        }
        
        return String(data: data, encoding: .utf8)
    } catch {
        print("[LssAPI, downloadIndexHTML] An error occured.")
    }
    
    return nil
}
