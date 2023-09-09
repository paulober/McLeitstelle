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
    let url = lssBaseURL.appendingPathComponent("alliance_chats")
    var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 5.0)
    postDefaultHeaderWithContentTypeForm(request: &request, csrfToken: csrfToken, url: url)
    
    // TODO: create kit for url encoding
    let allowedCharacters = CharacterSet(charactersIn: "!*'();:@&=+$,/?%#[]").inverted

    // Encode the string
    guard let encodedCsrfToken = csrfToken.addingPercentEncoding(withAllowedCharacters: allowedCharacters),
          let encodedMessage = message.addingPercentEncoding(withAllowedCharacters: allowedCharacters),
          let messageKey = "alliance_chat[message]".addingPercentEncoding(withAllowedCharacters: allowedCharacters) else {
        return false
    }
    
    let formDataString = "utf8=%E2%9C%93&authenticity_token=\(encodedCsrfToken)&\(messageKey)=\(encodedMessage)"
    
    request.httpBody = formDataString.data(using: .utf8)
    
    let session = URLSession.shared
    if let (data, response) = try? await session.data(for: request),
       let httpResponse = response as? HTTPURLResponse {
        print("COll: \(String(data: data, encoding: .utf8) ?? "nice")")
        return httpResponse.statusCode == 200
    }
    
    return false
}

internal func restSendMissionReply(csrfToken: String, message: String, missionId: String) async -> Bool {
    let url = lssBaseURL.appendingPathComponent("mission_replies")
    var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 5.0)
    postDefaultHeaderWithContentTypeForm(request: &request, csrfToken: csrfToken, url: url)
    
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

internal func restEnabelAllianceFMS(csrfToken: String, on: Bool) async -> Bool {
    let url = lssBaseURL.appendingPathComponent("profile/alliance_ignore_fms/\(on ? 0 : 1)")
    var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 5.0)
    postDefaultHeader(request: &request, csrfToken: csrfToken, url: url)
    
    let session = URLSession.shared
    if let (_, response) = try? await session.data(for: request),
       let httpResponse = response as? HTTPURLResponse {
        return httpResponse.statusCode == 200
    }
    
    return false
}
