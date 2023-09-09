//
//  MissionEinsatzHTML.swift
//
//
//  Created by Paul on 08.09.23.
//

import Foundation
import SwiftSoup

public func scanMissionEinsatzHTML(csrfToken: String, missionTypeId: UInt16, missionId: Int) async -> MissionEinsatzDetails {
    var url = lssBaseURL.appendingPathComponent("einsaetze/\(missionTypeId)")
    url.append(queryItems: [URLQueryItem(name: "mission_id", value: String(missionId))])
    var request = URLRequest(url: url)
    getDefaultHeader(request: &request, csrfToken: csrfToken, url: url)
    
    if let (data, response) = try? await URLSession.shared.data(for: request),
       let html = String(data: data, encoding: .utf8),
       let httpResponse = response as? HTTPURLResponse {
        var details = MissionEinsatzDetails()
        
        if httpResponse.statusCode != 200 {
            return details
        }
        
        do {
            let doc: Document = try SwiftSoup.parse(html)
            
            if let rewardsTable = try? doc.select("table:contains(Belohnung und Voraussetzungen)").first() {
                let rows = try rewardsTable.select("tr")
                
                for row in rows {
                    let columns = try row.select("td")
                    if columns.count == 2 {
                        let key = try columns[0].text()
                        let value = try columns[1].text()
                        details.rewardAndPrerequisites[key] = value
                    }
                }
            }
            
            if let assetsTable = try? doc.select("table:contains(Benötigte Fahrzeuge und Personal)").first() {
                let rows = try assetsTable.select("tr")
                
                for row in rows {
                    let columns = try row.select("td")
                    if columns.count == 2 {
                        let key = try columns[0].text()
                        let value = try columns[1].text()
                        // Assuming the values are UInt8
                        if let intValue = UInt8(value) {
                            details.requiredAssets[key] = intValue
                        }
                    }
                }
            }
            
            if let additionalTable = try? doc.select("table:contains(Weitere Informationen)").first() {
                let rows = try additionalTable.select("tr")
                
                for row in rows {
                    let columns = try row.select("td")
                    if columns.count == 2 {
                        let key = try columns[0].text()
                        let value = try columns[1].text()
                        details.additionalDetails[key] = value
                    }
                }
            }
            
            return details
        } catch {
            print("Error parsing einsatz HTML: \(error)")
        }
    }
    
    return MissionEinsatzDetails()
}
