//
//  PrisonerMarker.swift
//
//
//  Created by Paul on 03.09.23.
//

public struct PrisonerMarker: Codable, Identifiable {
    public let name: String
    public let missionId: Int?
    public let id: Int

    enum CodingKeys: String, CodingKey {
        case name
        case missionId = "mission_id"
        case id
    }
}
