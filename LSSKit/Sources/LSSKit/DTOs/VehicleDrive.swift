//
//  VehicleDrive.swift
//  
//
//  Created by Paul on 29.08.23.
//

public struct VehicleDrive: Codable, Identifiable, Hashable, Equatable {
    public let id: Int
    public let buildingId: Int?
    public let routeHandle: String?
    public let vom: Bool?
    public let vehicleTypeId: Int?
    public let missionId: String
    /// time since last stop at building or mission in s
    public let driveDuration: Int?
    public let steps: String?
    public let fms: UInt8
    public let fmsReal: UInt8?
    public let userId: Int
    /// image siren
    public let imageSonderrechte: String?
    /// image normal
    public let imageNormal: String?
    public let apngSonderrechte: String?
    public let ioverwrite: String?
    public let caption: String
    public let specialRights: String?
    
    private enum CodingKeys: String, CodingKey {
        case id
        case buildingId = "b"
        case routeHandle = "rh"
        case vom
        case vehicleTypeId = "vtid"
        case missionId = "mid"
        case driveDuration = "dd"
        case steps = "s"
        case fms
        case fmsReal = "fms_real"
        case userId = "user_id"
        case imageSonderrechte = "isr"
        case imageNormal = "in"
        case apngSonderrechte = "apng_sonderrechte"
        case ioverwrite
        case caption
        case specialRights = "sr"
    }
    
    public static func == (lhs: VehicleDrive, rhs: VehicleDrive) -> Bool {
        // TODO: maybe the missionId comparisson can be obmitted
        return lhs.id == rhs.id && lhs.missionId == rhs.missionId
    }
}
