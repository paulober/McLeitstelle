//
//  RadioMessage.swift
//  
//
//  Created by Paul on 31.08.23.
//

public struct RadioMessage: Codable, Identifiable, Hashable, Equatable {
    public let targetBuildingId: Int?
    public let missionId: Int?
    public let additionalText: String?
    public let userId: Int
    public let type: String
    /// Equals to vehicle id if type == "vehicle_fms"
    public let id: Int
    public let fmsReal: UInt8
    public let fms: UInt8
    public let fmsText: String
    public let caption: String
    
    public var optionalMissionId: Int {
        return missionId ?? -1
    }

    private enum CodingKeys: String, CodingKey {
        case targetBuildingId = "target_building_id"
        case missionId = "mission_id"
        case additionalText
        case userId = "user_id"
        case type
        case id
        case fmsReal = "fms_real"
        case fms
        case fmsText = "fms_text"
        case caption
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(targetBuildingId)
        hasher.combine(missionId)
        hasher.combine(additionalText)
        hasher.combine(userId)
        hasher.combine(type)
        hasher.combine(id)
        hasher.combine(fmsReal)
        hasher.combine(fms)
        hasher.combine(fmsText)
        hasher.combine(caption)
    }
    
    public static func == (lhs: RadioMessage, rhs: RadioMessage) -> Bool {
        // TODO: maybe the missionId and userID comparisson can be obmitted
        return lhs.id == rhs.id && lhs.userId == rhs.userId && lhs.missionId == rhs.missionId
    }
}

public extension RadioMessage {
    static let preview = RadioMessage(targetBuildingId: nil, missionId: 123, additionalText: nil, userId: 1234, type: "vehicle_fms", id: 421, fmsReal: 5, fms: 5, fmsText: "Sprechwunsch", caption: "RTW 2 (LL Nord)")
}
