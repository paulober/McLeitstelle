//
//  FayeData.swift
//  
//
//  Created by Paul on 03.09.23.
//

/// Not a DTO used by Lss
public struct FayeData {
    public var newPatientMarkers: [PatientMarker] = []
    public var newCombinedPatientMarkers: [CombinedPatientMarker] = []
    public var newMissionMarkers: [MissionMarker] = []
    public var newVehicleDrives: [VehicleDrive] = []
    public var newVehicleMarker: [VehicleMarker] = []
    public var newPrisonerMarkers: [PrisonerMarker] = []
    public var newRadioMessages: [RadioMessage] = []
    public var newChatMessages: [ChatMessage] = []
    
    public var missionParticipationAdd: [Int] = []
    
    public var deletedMissions: [Int] = []
    public var deletedPatients: [Int] = []
    public var deletedPrisoners: [Int] = []
}
