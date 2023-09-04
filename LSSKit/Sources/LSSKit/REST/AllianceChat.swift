//
//  AllianceChat.swift
//
//
//  Created by Paul on 04.09.23.
//

import Foundation

/**
 Message maxLength 50
 */
internal func restAllianceChatSend(csrfToken: String, message: String, missionId: String? = nil) async -> Bool {
    var request = URLRequest(url: lssUsersSignInURL, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 5.0)
    postDefaultHeaderWithContentTypeForm(request: &request, csrfToken: csrfToken, url: lssUsersSignInURL)
    
    // TODO: create kit for url encoding
    let allowedCharacters = CharacterSet(charactersIn: "!*'();:@&=+$,/?%#[]").inverted

    // Encode the string
    guard let encodedCsrfToken = csrfToken.addingPercentEncoding(withAllowedCharacters: allowedCharacters),
          let encodedMessage = message.addingPercentEncoding(withAllowedCharacters: allowedCharacters) else {
        return false
    }
    
    let formDataString = "utf8=%E2%9C%93&authenticity_token=\(encodedCsrfToken)&alliance_chat[message]=\(encodedMessage)"
    
    request.httpBody = formDataString.data(using: .utf8)
    
    let session = URLSession.shared
    if let (_, response) = try? await session.data(for: request),
       let httpResponse = response as? HTTPURLResponse {
        return httpResponse.statusCode == 200
    }
    
    return false
}

internal func restSendMissionReply(csrfToken: String, message: String, missionId: String) async -> Bool {
    var request = URLRequest(url: lssUsersSignInURL, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 5.0)
    postDefaultHeaderWithContentTypeForm(request: &request, csrfToken: csrfToken, url: lssUsersSignInURL)
    
    // TODO: create kit for url encoding
    let allowedCharacters = CharacterSet(charactersIn: "!*'();:@&=+$,/?%#[]").inverted

    // Encode the string
    guard let encodedCsrfToken = csrfToken.addingPercentEncoding(withAllowedCharacters: allowedCharacters),
          let encodedMessage = message.addingPercentEncoding(withAllowedCharacters: allowedCharacters) else {
        return false
    }
    
    let formDataString = "utf8=%E2%9C%93&authenticity_token=\(encodedCsrfToken)&mission_reply[content]=\(encodedMessage)&mission_reply[mission_id]=\(missionId)"
    
    request.httpBody = formDataString.data(using: .utf8)
    
    let session = URLSession.shared
    if let (_, response) = try? await session.data(for: request),
       let httpResponse = response as? HTTPURLResponse {
        return httpResponse.statusCode == 200
    }
    
    return false
}
