//
//  CombinedPatientMarker.swift
//
//
//  Created by Paul on 09.09.23.
//

public struct CombinedPatientMarker: Codable, Hashable, Equatable {
    public var count: UInt16
    public var missionId: Int
    public var untouched: UInt8
    public var errors: [String: UInt16]
    
    private enum CodingKeys: String, CodingKey {
        case count
        case missionId = "mission_id"
        case untouched
        case errors
    }
    
    public static func == (lhs: CombinedPatientMarker, rhs: CombinedPatientMarker) -> Bool {
        return lhs.missionId == rhs.missionId
    }
}
