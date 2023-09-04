//
//  UserDetails.swift
//
//
//  Created by Paul on 31.08.23.
//

import Foundation
import RegexBuilder

fileprivate let userIdRegex = Regex {
    "var user_id = "
    Capture {
        OneOrMore(.digit)
    }
    ";"
}
fileprivate let userNameRegex = /var username = \"([^\"]+)\";/
fileprivate let allianceIdRegex = Regex {
    "var alliance_id = "
    Capture {
        OneOrMore(.digit)
    }
    ";"
}
fileprivate let extRegex = try! NSRegularExpression(pattern: #"message\.ext\["([^"]+)"\] = "([^"]+)";"#)
fileprivate let mapViewRegex = /\.map\('map'\)\.setView\(\[(\-?\d+\.\d+), (\-?\d+\.\d+)\]/
fileprivate let mapViewRegex2 = /const coordinate = new mapkit\.Coordinate\((\-?\d+\.\d+), (\-?\d+\.\d+)\)/
fileprivate let csrfRegex = /<meta[^>]*content="([^"]*)"[^>]*name="csrf-token"/

internal func htmlExtractUserDetails(from html: String, creds: inout FayeCredentials) {
    if let userIdMatch = try? userIdRegex.firstMatch(in: html){
        let userId = String(userIdMatch.output.1)
        print("[LssKit, htmlExtractUserDetails] Found userId: \(userId)")
        creds.userId = userId
    }

    // Extract userName
    if let userNamedMatch = try? userNameRegex.firstMatch(in: html) {
        let userName = String(userNamedMatch.output.1)
        creds.userName = userName
    }

    // Extract allianceId
    if let allianceIdMatch = try? allianceIdRegex.firstMatch(in: html) {
        let allianceId = String(allianceIdMatch.output.1)
        creds.allianceId = allianceId
    }
    
    let extMatches = extRegex.matches(in: html, range: NSRange(html.startIndex..., in: html))
    for match in extMatches {
        if let keyRange = Range(match.range(at: 1), in: html),
           let valueRange = Range(match.range(at: 2), in: html) {
            let key = String(html[keyRange])
            let value = String(html[valueRange])
            creds.exts[key] = value
            
            if key.starts(with: "/private-alliance") {
                if let allianceGuidMatch = try? /\/private-alliance\/([0-9a-fA-F-]+)\/de_DE/.wholeMatch(in: key) {
                    creds.allianceGuid = String(allianceGuidMatch.output.1)
                }
            }
        }
    }
    
    if let mapViewMatch = html.firstMatch(of: mapViewRegex) {
        if let lat = Double(mapViewMatch.output.1),
           let long = Double(mapViewMatch.output.2) {
           creds.mapView = (lat, long)
       }
    } else if let mapViewMatch2 = html.firstMatch(of: mapViewRegex2) {
        if let lat = Double(mapViewMatch2.output.1),
           let long = Double(mapViewMatch2.output.2) {
           creds.mapView = (lat, long)
       }
    }
    
    if let csrfTokenMatch = html.firstMatch(of: csrfRegex) {
        let csrfToken = String(csrfTokenMatch.output.1)
        print("[LssKit, htmlExtractUserDetails] Found csrfToken: \(csrfToken)")
        creds.csrfToken = csrfToken
    }
}
