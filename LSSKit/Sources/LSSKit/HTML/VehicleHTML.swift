//
//  VehicleHTML.swift
//
//
//  Created by Paul on 06.09.23.
//

import Foundation
import SwiftSoup

public struct Hospital {
    public var id: Int = -1
    public var name: String = ""
    public var isMine: Bool = false
    public var distance: Float = -1.0
    public var hasRequiredSpecialisation: Bool = false
    public var freeBeds: String = ""
    public var share: UInt8?
}

public struct RtwTransportDetails {
    public var hospitals: [Hospital] = []
    public var rtwId: Int
}

fileprivate let hospitalIdRegex = /\/patient\/(\d+)\"/

internal func scanRtwHTML(csrfToken: String, rtwId: Int) async -> RtwTransportDetails {
    var url = lssBaseURL.appendingPathComponent("vehicles/\(rtwId)")
    url.append(queryItems: [URLQueryItem(name: "free_beds_only", value: "true")])
    var request = URLRequest(url: url)
    getDefaultHeader(request: &request, csrfToken: csrfToken, url: url)
    
    if let (data, response) = try? await URLSession.shared.data(for: request),
       let httpResponse = response as? HTTPURLResponse,
       let html = String(data: data, encoding: .utf8) {
        var transport = RtwTransportDetails(rtwId: rtwId)
        
        if httpResponse.statusCode != 200 {
            return transport
        }
        
        do {
            let doc: Document = try SwiftSoup.parse(html)
            
            if let ownHospitalsTable = try? doc.getElementById("own-hospitals") {
                (try? ownHospitalsTable.select("tbody tr"))?.forEach { hospitalTr in
                    var stage: UInt8 = 0
                    var hospital = Hospital(isMine: true)
                    
                    (try? hospitalTr.select("td"))?.forEach { td in
                        switch stage {
                        case 0:
                            // name
                            if let name = try? td.html() {
                                hospital.name = String(name.split(separator: "<div")[0]).trimmingCharacters(in: .whitespacesAndNewlines)
                            }
                            
                        case 1:
                            // distance
                            if let distanceStr = try? td.html() {
                                hospital.distance = Float(distanceStr.split(separator: " ")[0].replacing(",", with: ".")) ?? -1.0
                            }
                            
                        case 2:
                            // free beds
                            if let freeBeds = try? td.html() {
                                hospital.freeBeds = freeBeds
                            }

                        case 3:
                            // does have required specialisation
                            if let specString = try? td.html() {
                                hospital.hasRequiredSpecialisation = specString.contains("Ja")
                            }
                            
                        case 4:
                            if let tdString = try? td.html(),
                               let match = tdString.firstMatch(of: hospitalIdRegex) {
                                hospital.id = Int(match.output.1) ?? -1
                            }
                            
                        default:
                            break
                        }
                        
                        stage += 1
                    }
                    transport.hospitals.append(hospital)
                }
            }
            
            if let allianceHospitalsTable = try? doc.getElementById("alliance-hospitals") {
                (try? allianceHospitalsTable.select("tbody tr"))?.forEach { hospitalTr in
                    var stage: UInt8 = 0
                    var hospital = Hospital()
                    
                    (try? hospitalTr.select("td"))?.forEach { td in
                        switch stage {
                        case 0:
                            // name
                            if let name = try? td.html() {
                                hospital.name = String(name.split(separator: "<div")[0]).trimmingCharacters(in: .whitespacesAndNewlines)
                            }
                        case 1:
                            // distance
                            if let distanceStr = try? td.html() {
                                hospital.distance = Float(distanceStr.split(separator: " ")[0].replacing(",", with: ".")) ?? -1.0
                            }
                            
                        case 2:
                            // free beds
                            if let freeBeds = try? td.html() {
                                hospital.freeBeds = freeBeds
                            }
                            
                        case 3:
                            // abgabe
                            if let share = try? td.html() {
                                hospital.share = UInt8(share.split(separator: " ")[0])
                            }
                            
                        case 4:
                            // does have required specialisation
                            if let specString = try? td.html() {
                                hospital.hasRequiredSpecialisation = specString.contains("Ja")
                            }
                            
                        case 5:
                            if let tdString = try? td.html(),
                               let match = tdString.firstMatch(of: hospitalIdRegex) {
                                hospital.id = Int(match.output.1) ?? -1
                            }
                            
                        default:
                            break
                        }
                        
                        stage += 1
                    }
                    transport.hospitals.append(hospital)
                }
            }
            
            return transport
        } catch Exception.Error(_, let message) {
            // type, message
            print(message)
        } catch {
            print("error")
        }
        
        return transport
    }
    
    return RtwTransportDetails(rtwId: -1)
}
