//
//  LssStreamDataUtil.swift
//  
//
//  Created by Paul on 29.08.23.
//

import Foundation


internal func scanFayeData(data: String) -> FayeData {
    var fayeData: FayeData = FayeData()
    
    // (\w+)\(\s*({?[^{}]*}?)\);
    let pattern = /(\w+)\(\s*({?[^;]*}?)\);/
    let matches = data.matches(of: pattern)
    
    let decoder = JSONDecoder()
    for match in matches {
        let methodName = match.output.1
        let jsonString = match.output.2
        
        if let jsonData = jsonString.data(using: .utf8) {
            do {
                // TODO: this json
                /*
                 [LssKit, LssStreamDataUtil] Unknown methodName: missionInvolved in json: 3055738615, true
                 [LssKit, LssStreamDataUtil] Unknown methodName: vehicleMarkerAdd in json: {"bulkInsert":false,"id":55154091,"b":14845351,"fms":3,"fms_real":3,"c":"KTW (LL S\u00fcd)","t":38}
                 [LssKit, LssStreamDataUtil] Unknown methodName: mission_participation_add in json: 3055738615
                 [LssKit, LssStreamDataUtil] Unknown methodName: allianceCandidatureCount in json: 5
                 */
                // TODO: use equal instead of contains
                // jsonString.contains("missionMarkerAdd")
                // TODO: missionSpeed(...) method support is returned as response to rest mission speed change
                if methodName.contains("missionMarkerAdd") {
                    let missionMarker = try decoder.decode(MissionMarker.self, from: jsonData)
                    fayeData.newMissionMarkers.append(missionMarker)
                }  else if methodName == "patientMarkerAddCombined" {
                    let combinedPatientMarker = try decoder.decode(CombinedPatientMarker.self, from: jsonData)
                    fayeData.newCombinedPatientMarkers.append(combinedPatientMarker)
                } else if methodName.contains("patientMarkerAdd") {
                    let patientMarker = try decoder.decode(PatientMarker.self, from: jsonData)
                    fayeData.newPatientMarkers.append(patientMarker)
                } else if methodName.contains("vehicleDrive") {
                    let vehicleDrive = try decoder.decode(VehicleDrive.self, from: jsonData)
                    fayeData.newVehicleDrives.append(vehicleDrive)
                } else if methodName.contains("vehicleMarkerAdd") {
                    let vehicleMarker = try decoder.decode(VehicleMarker.self, from: jsonData)
                    fayeData.newVehicleMarker.append(vehicleMarker)
                } else if methodName.contains("prisonerMarkerAdd") {
                    let prisonerMarker = try decoder.decode(PrisonerMarker.self, from: jsonData)
                    fayeData.newPrisonerMarkers.append(prisonerMarker)
                } else if methodName.contains("radioMessage") {
                    let radioMessage = try decoder.decode(RadioMessage.self, from: jsonData)
                    fayeData.newRadioMessages.append(radioMessage)
                } else if methodName.contains("allianceChat") {
                    let chatMessage = try decoder.decode(ChatMessage.self, from: jsonData)
                    fayeData.newChatMessages.append(chatMessage)
                } else if methodName.contains("mission_participation_add") {
                    if let missionId = Int(jsonString) {
                        fayeData.missionParticipationAdd.append(missionId)
                    } else {
                        print("[LssKit, LssStreamDataUtil] Unable to parse mission-ID from mission_participation_add.")
                    }
                    
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
                } else {
                    print("[LssKit, LssStreamDataUtil] Unknown methodName: \(methodName) in json: \(jsonString)")
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
