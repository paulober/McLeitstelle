//
//  DailyBonuses.swift
//
//
//  Created by Paul on 05.09.23.
//

import Foundation

internal func restCollectDailyBonuses(csrfToken: String, day: UInt8) async -> Bool {
    var url = lssBaseURL.appendingPathComponent("daily_bonuses/collect")
    url.append(queryItems: [URLQueryItem(name: "day", value: String(day))])
    var request = URLRequest(url: url)
    postDefaultHeaderWithContentTypeForm(request: &request, csrfToken: csrfToken, url: url)
    
    let allowedCharacters = CharacterSet(charactersIn: "!*'();:@&=+$,/?%#[]").inverted

    // Encode the string
    guard let encodedCsrfToken = csrfToken.addingPercentEncoding(withAllowedCharacters: allowedCharacters) else {
        return false
    }
    
    let formDataString = "utf8=%E2%9C%93&authenticity_token=\(encodedCsrfToken)"    
    request.httpBody = formDataString.data(using: .utf8)
    
    let session = URLSession.shared
    if let (_, response) = try? await session.data(for: request),
        let httpResponse = response as? HTTPURLResponse {
        return httpResponse.statusCode == 200
    }
    
    return false
}
