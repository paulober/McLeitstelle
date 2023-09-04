//
//  FayeData.swift
//  
//
//  Created by Paul on 03.09.23.
//

/// Not a DTO used by Lss
public struct FayeData {
    public var newPatientMarkers: [PatientMarker] = []
    public var newMissionMarkers: [MissionMarker] = []
    public var newVehicleDrives: [VehicleDrive] = []
    public var newPrisonerMarkers: [PrisonerMarker] = []
    public var newRadioMessages: [RadioMessage] = []
    public var newChatMessages: [ChatMessage] = []
    
    public var deletedMissions: [Int] = []
    public var deletedPatients: [Int] = []
    public var deletedPrisoners: [Int] = []
}
