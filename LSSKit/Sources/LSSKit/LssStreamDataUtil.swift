//
//  LssStreamDataUtil.swift
//  
//
//  Created by Paul on 29.08.23.
//

import Foundation


internal func scanFayeData(data: String) -> FayeData {
    var fayeData: FayeData = FayeData()
    
    // /\{[^{}]*\}/
    let pattern = /(\w+)\(\s*({?[^{}]*}?)\);/
    let matches = data.matches(of: pattern)
    
    let decoder = JSONDecoder()
    for match in matches {
        let methodName = match.output.1
        let jsonString = match.output.2
        
        if let jsonData = jsonString.data(using: .utf8) {
            do {
                // jsonString.contains("missionMarkerAdd")
                if methodName.contains("missionMarkerAdd") {
                    let missionMarker = try decoder.decode(MissionMarker.self, from: jsonData)
                    fayeData.newMissionMarkers.append(missionMarker)
                } else if methodName.contains("patientMarkerAdd") {
                    let patientMarker = try decoder.decode(PatientMarker.self, from: jsonData)
                    fayeData.newPatientMarkers.append(patientMarker)
                } else if methodName.contains("vehicleDrive") {
                    let vehicleDrive = try decoder.decode(VehicleDrive.self, from: jsonData)
                    fayeData.newVehicleDrives.append(vehicleDrive)
                } else if methodName.contains("prisonerMarkerAdd") {
                    let prisonerMarker = try decoder.decode(PrisonerMarker.self, from: jsonData)
                    fayeData.newPrisonerMarkers.append(prisonerMarker)
                } else if methodName.contains("radioMessage") {
                    let radioMessage = try decoder.decode(RadioMessage.self, from: jsonData)
                    fayeData.newRadioMessages.append(radioMessage)
                } else if methodName.contains("allianceChat") {
                    let chatMessage = try decoder.decode(ChatMessage.self, from: jsonData)
                    fayeData.newChatMessages.append(chatMessage)
                    
                // delete functions
                } else if methodName.contains("missionDelete") {
                    if let missionId = Int(jsonString) {
                        fayeData.deletedMissions.append(missionId)
                    } else {
                        print("[LssKit, LssStreamDataUtil] Unable to parse mission-ID from missionDelete.")
                    }
                } else if methodName.contains("patientDelete") {
                    if let patientId = Int(jsonString) {
                        fayeData.deletedPatients.append(patientId)
                    } else {
                        print("[LssKit, LssStreamDataUtil] Unable to parse patient-ID from patientDelete.")
                    }
                } else if methodName.contains("prisonerDelete") {
                    if let prisonerId = Int(jsonString) {
                        fayeData.deletedPrisoners.append(prisonerId)
                    } else {
                        print("[LssKit, LssStreamDataUtil] Unable to parse prisoner-ID from prisonerDelete.")
                    }
                }
            } catch let error as DecodingError {
                print("[LssKit, LssStreamDataUtil] DecodingError: \(error)\n For methodName: \(methodName) For json: \(jsonString)")
            } catch {
                print("[LssKit, LssStreamDataUtil] Error decoding ")
            }
        }
    }
    
    return fayeData
}
