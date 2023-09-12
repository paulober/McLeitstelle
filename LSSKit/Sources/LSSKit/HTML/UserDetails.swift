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
fileprivate let missionSpeedRegex = /missionSpeed\(\s*(\d)\s*\);/

internal enum UserDetailsResult {
    case userID(_ userId: String)
    case userName(_ userName: String)
    case allianceId(_ allianceId: String)
    case extensions(_ extensions: [String: String], _ allianceId: String?)
    case csrfToken(_ csrfToken: String)
    case missionSpeed(_ missionSpeed: UInt8)
    case latLong(_ lat: Double, _ long: Double)
}

internal func htmlExtractUserDetails(from html: String, indexHTML: String) async -> [UserDetailsResult] {
    let result = await withTaskGroup(of: UserDetailsResult?.self, returning: [UserDetailsResult].self) { group in
        group.addTask {
            if let userIdMatch = try? userIdRegex.firstMatch(in: html){
                let userId = String(userIdMatch.output.1)
                print("[LssKit, htmlExtractUserDetails] Found userId: \(userId)")
                //theCreds.userId = userId
                return UserDetailsResult.userID(userId)
            }
            return nil
        }
        
        group.addTask {
            // Extract userName
            if let userNamedMatch = try? userNameRegex.firstMatch(in: html) {
                let userName = String(userNamedMatch.output.1)
                //theCreds.userName = userName
                return UserDetailsResult.userName(userName)
            }
            return nil
        }
        
        group.addTask {
            // Extract allianceId
            if let allianceIdMatch = try? allianceIdRegex.firstMatch(in: html) {
                let allianceId = String(allianceIdMatch.output.1)
                //creds.allianceId = allianceId
                return UserDetailsResult.allianceId(allianceId)
            }
            return nil
        }
        
        group.addTask {
            var extensions: [String: String] = [:]
            var allianceGuid: String?
            
            let extMatches = extRegex.matches(in: html, range: NSRange(html.startIndex..., in: html))
            
            for match in extMatches {
                if let keyRange = Range(match.range(at: 1), in: html),
                   let valueRange = Range(match.range(at: 2), in: html) {
                    let key = String(html[keyRange])
                    let value = String(html[valueRange])
                    extensions[key] = value
                    
                    if key.starts(with: "/private-alliance") {
                        if let allianceGuidMatch = try? /\/private-alliance\/([0-9a-fA-F-]+)\/de_DE/.wholeMatch(in: key) {
                            // this does work, why?
                            allianceGuid = String(allianceGuidMatch.output.1)
                        }
                    }
                }
            }
            
            return UserDetailsResult.extensions(extensions, allianceGuid)
        }
        
        
        group.addTask {
            var lat, long: Double?
            
            if let mapViewMatch = html.firstMatch(of: mapViewRegex) {
                if let newLat = Double(mapViewMatch.output.1),
                   let newLong = Double(mapViewMatch.output.2) {
                    (lat, long) = (newLat, newLong)
                }
            } else if let mapViewMatch2 = html.firstMatch(of: mapViewRegex2) {
                if let newLat = Double(mapViewMatch2.output.1),
                   let newLong = Double(mapViewMatch2.output.2) {
                    (lat, long) = (newLat, newLong)
                }
            }
            
            if let lat = lat, let long = long {
                return UserDetailsResult.latLong(lat, long)
            }
            
            return nil
        }
        
        group.addTask {
            if let csrfTokenMatch = indexHTML.firstMatch(of: csrfRegex) {
                let csrfToken = String(csrfTokenMatch.output.1)
                print("[LssKit, htmlExtractUserDetails] Found csrfToken: \(csrfToken)")
                //creds.csrfToken = csrfToken
                return UserDetailsResult.csrfToken(csrfToken)
            }
            return nil
        }
        
        group.addTask {
            if let missionSpeedMatch = html.firstMatch(of: missionSpeedRegex) {
                if let missionSpeed = UInt8(missionSpeedMatch.output.1) {
                    print("[LssKit, htmlExtractUserDetails] Found missionSpeed: \(missionSpeed)")
                    //creds.missionSpeed = missionSpeed
                    return UserDetailsResult.missionSpeed(missionSpeed)
                }
            }
            return nil
        }
        
        var values: [UserDetailsResult] = []
        for await value in group {
            if let value = value {
                values.append(value)
            }
        }
        
        return values
    }
    
    return result
}
