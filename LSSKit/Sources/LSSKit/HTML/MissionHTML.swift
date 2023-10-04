//
//  MissionHTML.swift
//
//
//  Created by Paul on 03.09.23.
//

import Foundation
import SwiftSoup

fileprivate let vehicleArrivalCountdownRegex = /vehicleArrivalCountdown\((\d+),\s*\d+,\s*\d+\)/

public func scanMissionHTML(csrfToken: String, missionId: String) async -> LiveMissionDetails {
    let url = lssBaseURL.appendingPathComponent("missions/\(missionId)")
    
    var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 5)
    getDefaultHeader(request: &request, csrfToken: csrfToken, url: url)
    let session = URLSession.shared
    
    if let (data, response) = try? await session.data(for: request),
       let html = String(data: data, encoding: .utf8),
       let httpResponse = response as? HTTPURLResponse {
        var liveDetails = LiveMissionDetails()
        
        if httpResponse.statusCode != 200 {
            return liveDetails
        }
        
        do {
            let doc: Document = try SwiftSoup.parse(html)
            if let vehiclesAtMissionTable = try? doc.getElementById("mission_vehicle_at_mission") {
                let vehicleIdsAtMission: [Int]? = (try? vehiclesAtMissionTable.select("tr[id]"))?.compactMap { tr in
                    let tempId: String = tr.id()
                    // id should look like: vehicle_row_1234 Doing ?? "a" so it will return nil if not possible to get vehicle-ID
                    let vID = tempId == "" ? nil : Int(tempId.split(separator: "_").last ?? "a")
                    
                    if let vehicleNameA = (try? tr.select("a[vehicle_type_id]"))?.first() {
                        let typeId = try? vehicleNameA.attr("vehicle_type_id")
                        let name = try? vehicleNameA.html()
                        
                        if let vehicleId = vID, let tId = typeId {
                            liveDetails.vehicleTypeIds[vehicleId] = Int(tId)
                        }
                        
                        if let vehicleId = vID, let vName = name {
                            liveDetails.vehicleNames[vehicleId] = vName
                        }
                    }
                    
                    if let vehicleId = vID {
                        (try? tr.select("a[href]"))?.forEach { ownerTag in
                            let href = try? ownerTag.attr("href")
                            if let href = href, href.starts(with: "/profile/"), let owner = try? ownerTag.html() {
                                liveDetails.vehicleOwners[vehicleId] = owner
                            }
                        }
                        
                        /*(try? tr.select("td:not(:has(*))"))?.forEach { buildingNameTag in
                            if let buildingName = try? buildingNameTag.html() {
                                liveDetais.vehicleBuildings[vehicleId] = buildingName
                            }
                        }*/
                        
                        // TODO: suport RTH
                        if let typeId = liveDetails.vehicleTypeIds[vehicleId], typeId == VehicleType.rtw.rawValue || typeId == VehicleType.naw.rawValue {
                            if let patientTd = try? tr.select("td:contains(Patient)").first,
                               let patientName = try? patientTd.text() {
                                
                                
                                liveDetails.patientsAtVehicleIds["\(String(patientName.split(separator: "Patient:")[1].trimmingCharacters(in: .whitespacesAndNewlines).split(separator: ".")[0]))."] = vehicleId
                            }
                        }
                    }
                    
                    return vID
                }
                
                liveDetails.vehiclesAtIds = vehicleIdsAtMission ?? []
            }
            
            if let vehiclesDrivingMissionTable = try? doc.getElementById("mission_vehicle_driving") {
                let vehicleIdsDrivingToMission: [Int]? = (try? vehiclesDrivingMissionTable.select("tr[id]"))?.compactMap { tr in
                    var travelTime: Int = -1
                    if let scriptTag = (try? tr.getElementsByTag("script"))?.first(),
                        // maybe alternative to get from sortValue key of the <td sortValue="<maybe-travel-time-in-sec>" id="vehicle_drive_<vID>"
                        let timeMatch = (try? scriptTag.html())?.firstMatch(of: vehicleArrivalCountdownRegex) {
                        if let time = Int(timeMatch.output.1) {
                            travelTime = time
                        }
                    }
                    
                    let tempId: String = tr.id()
                    // id should look like: vehicle_row_1234 Doing ?? "a" so it will return nil if not possible to get vehicle-ID
                    let vID = tempId == "" ? nil : Int(tempId.split(separator: "_").last ?? "a")
                    
                    if let key = vID {
                        liveDetails.vehicleTravelTimes[key] = travelTime
                    }
                    
                    if let vehicleNameA = (try? tr.select("a[vehicle_type_id]"))?.first() {
                        let typeId = try? vehicleNameA.attr("vehicle_type_id")
                        let name = try? vehicleNameA.html()
                        
                        if let vehicleId = vID, let tId = typeId {
                            liveDetails.vehicleTypeIds[vehicleId] = Int(tId)
                        }
                        
                        if let vehicleId = vID, let vName = name {
                            liveDetails.vehicleNames[vehicleId] = vName
                        }
                    }
                    
                    if let vehicleId = vID {
                        (try? tr.select("a[href]"))?.forEach { ownerTag in
                            let href = try? ownerTag.attr("href")
                            if let href = href, href.starts(with: "/profile/"), let owner = try? ownerTag.html() {
                                liveDetails.vehicleOwners[vehicleId] = owner
                            }
                        }
                        
                        /*(try? tr.select("td:not(:has(*))"))?.forEach { buildingNameTag in
                            if let buildingName = try? buildingNameTag.html() {
                                liveDetais.vehicleBuildings[vehicleId] = buildingName
                            }
                        }*/
                    }
                    
                    return vID
                }
                
                liveDetails.vehiclesDrivingIds = vehicleIdsDrivingToMission ?? []
            }
            
            let vehiclesWithMessage: [Int] = (try? doc.select("a[href]:contains(Sprechwunsch bearbeiten)"))?.compactMap { link in
                if let vId = (try? link.attr("href"))?.split(separator: "/").last {
                    return Int(vId)
                } else {
                    return nil
                }
            } ?? []
            liveDetails.vehiclesWithMessages = vehiclesWithMessage
        } catch Exception.Error(_, let message) {
            // type, message
            print(message)
        } catch {
            print("[LssKit, scanMissionHTML] Error")
        }
        
        return liveDetails
    }
    
    return LiveMissionDetails()
}
