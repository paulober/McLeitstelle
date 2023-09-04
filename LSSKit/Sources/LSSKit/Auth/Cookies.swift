//
//  Cookies.swift
//
//
//  Created by Paul on 31.08.23.
//

import Foundation

internal enum Cookie: String {
    case stripeMid = "__stripe_mid"
    case sessionID = "_session_id"
    case mcUniqueClientID = "mc_unique_client_id"
    case rememberUserToken = "remember_user_token"
}

internal var lssCookies: [URL: [HTTPCookie]] = [:]

internal func constructCookies(for url: URL = lssBaseURL, creds: FayeCredentials) {
    var cookiesHeaderField = ["Set-Cookie": "\(Cookie.sessionID.rawValue)=\(creds.sessionId), cookie_eu_consented=true, deactive_m_selection=[], \(Cookie.mcUniqueClientID.rawValue)=\(creds.mcUniqueClientId)"]
    if creds.rememberUserToken != "" {
        cookiesHeaderField["Set-Cookie"]? += ", \(Cookie.rememberUserToken.rawValue)=\(creds.rememberUserToken)"
    }
    if creds.stripeMid != "" {
        cookiesHeaderField["Set-Cookie"]? += ", \(Cookie.stripeMid.rawValue)=\(creds.stripeMid)"
    }
    let cookies = HTTPCookie.cookies(withResponseHeaderFields: cookiesHeaderField, for: url)
    
    let jar = HTTPCookieStorage.shared
    jar.setCookies(cookies, for: url, mainDocumentURL: url)
    
    lssCookies[url] = cookies
}

fileprivate func setDefaultCookieHeader(request: inout URLRequest, url: URL?) {
    guard let requestCookies = lssCookies[lssBaseURL] else {
        return
    }
    
    if let url = url {
        let jar = HTTPCookieStorage.shared
        jar.setCookies(requestCookies, for: url, mainDocumentURL: url)
    }
    
    let cookieHeaders = HTTPCookie.requestHeaderFields(with: requestCookies)
    request.allHTTPHeaderFields = cookieHeaders
}

fileprivate func setBasicHeaders(request: inout URLRequest, csrfToken: String, url: URL?) {
    request.setValue(csrfToken, forHTTPHeaderField: "X-CSRF-Token")
    request.setValue(lssBaseURL.absoluteString, forHTTPHeaderField: "Origin")
    request.setValue(url?.absoluteString ?? lssBaseURL.absoluteString, forHTTPHeaderField: "Referer")
}

fileprivate func setDefaultHeaderWithContentTypeForm(request: inout URLRequest, csrfToken: String, url: URL?) {
    setDefaultHeader(request: &request, csrfToken: csrfToken, url: url)
    request.setValue("application/x-www-form-urlencoded; charset=UTF-8", forHTTPHeaderField: "Content-Type")
}

fileprivate func setDefaultHeader(request: inout URLRequest, csrfToken: String, url: URL?) {
    setDefaultCookieHeader(request: &request, url: url)
    setBasicHeaders(request: &request, csrfToken: csrfToken, url: url)
}

internal func getDefaultHeaderWithContentTypeForm(request: inout URLRequest, csrfToken: String, url: URL? = nil) {
    setDefaultHeaderWithContentTypeForm(request: &request, csrfToken: csrfToken, url: url)
    request.httpMethod = "GET"
}

internal func getDefaultHeader(request: inout URLRequest, csrfToken: String, url: URL? = nil) {
    setDefaultHeader(request: &request, csrfToken: csrfToken, url: url)
    request.httpMethod = "GET"
}

internal func postDefaultHeaderWithContentTypeForm(request: inout URLRequest, csrfToken: String, url: URL? = nil) {
    setDefaultHeaderWithContentTypeForm(request: &request, csrfToken: csrfToken, url: url)
    request.httpMethod = "POST"
}

internal func postDefaultHeader(request: inout URLRequest, csrfToken: String, url: URL? = nil) {
    setDefaultHeader(request: &request, csrfToken: csrfToken, url: url)
    request.httpMethod = "POST"
}
