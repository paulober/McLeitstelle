//
//  Users.swift
//
//
//  Created by Paul on 03.09.23.
//

import Foundation

/**
 E-Mail/Username max length 50
 Password max length 50
 csrfToken parse seperatly so it can be check if null before and then be parsed as not nullable
 */
internal func restUsersSignIn(creds: inout FayeCredentials, csrfToken: String, emailOrUsername: String, password: String) async -> Bool {
    var request = URLRequest(url: lssUsersSignInURL, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 5.0)
    postDefaultHeaderWithContentTypeForm(request: &request, csrfToken: csrfToken, url: lssUsersSignInURL)
    
    // TODO: create kit for url encoding
    let allowedCharacters = CharacterSet(charactersIn: "!*'();:@&=+$,/?%#[]").inverted

    // Encode the string
    guard let encodedCsrfToken = csrfToken.addingPercentEncoding(withAllowedCharacters: allowedCharacters),
          let encodedEmailOrUsername = emailOrUsername.addingPercentEncoding(withAllowedCharacters: allowedCharacters),
          let encodedPassword = password.addingPercentEncoding(withAllowedCharacters: allowedCharacters) else {
        return false
    }
    
    let formDataString = "utf8=%E2%9C%93&authenticity_token=\(encodedCsrfToken)&user[email]=\(encodedEmailOrUsername)&user[password]=\(encodedPassword)&user[remember_me]=1&commit=Einloggen"
    
    request.httpBody = formDataString.data(using: .utf8)
    
    let session = URLSession.shared
    
    if let (_, response) = try? await session.data(for: request),
       let httpResponse = response as? HTTPURLResponse {
        if httpResponse.statusCode != 302 && httpResponse.statusCode != 200 {
            return false
        }
        
        //print(httpResponse.statusCode)
        //print(httpResponse.allHeaderFields)
        //print(String(data: data, encoding: .utf8) ?? "NO data")
        
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
                case Cookie.stripeMid.rawValue:
                    creds.stripeMid = cookie.value
                    
                // will be set if login was successfull
                case Cookie.rememberUserToken.rawValue:
                    creds.rememberUserToken = cookie.value
                    
                default:
                    break
                }
            }
        }
        
        return creds.rememberUserToken != ""
    }
    
    return false
}
