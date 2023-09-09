//
//  LssDTOCollection.swift
//
//
//  Created by Paul on 01.09.23.
//

public struct LssDTOCollection {
    public var creds: FayeCredentials = FayeCredentials(stripeMid: "", sessionId: "", mcUniqueClientId: "", rememberUserToken: "")
    
    public var radioMessages: [RadioMessage] = []
    public var chatMessages: [ChatMessage] = []
    public var missionMarkers: [MissionMarker] = []
    public var patientMarkers: [PatientMarker] = []
    public var combinedPatientMarkers: [CombinedPatientMarker] = []
    public var buildingMarkers: [BuildingMarker] = []
    public var vehicleDrives: [VehicleDrive] = []
}
