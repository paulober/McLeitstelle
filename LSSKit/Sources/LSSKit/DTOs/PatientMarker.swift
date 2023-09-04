//
//  PatientMarker.swift
//  
//
//  Created by Paul on 29.08.23.
//

public struct PatientMarker: Identifiable, Codable, Hashable, Equatable {
    public let missingText: String?
    public let name: String
    public let missionId: Int
    public let id: Int
    public let milisecondsByPercent: Int?
    public let targetPercent: Int?
    public let liveCurrentValue: Int
    
    private enum CodingKeys: String, CodingKey {
        case missingText = "missing_text"
        case name
        case missionId = "mission_id"
        case id
        case milisecondsByPercent = "miliseconds_by_percent"
        case targetPercent = "target_percent"
        case liveCurrentValue = "live_current_value"
    }
    
    public static func == (lhs: PatientMarker, rhs: PatientMarker) -> Bool {
        // TODO: maybe the missionId comparisson can be obmitted
        return lhs.id == rhs.id && lhs.missionId == rhs.missionId
    }
}
