//
//  VehicleMarker.swift
//
//
//  Created by Paul on 01.09.23.
//

public struct VehicleMarker: Codable, Identifiable, Hashable, Equatable {
    public let bulkInsert: Bool
    public let id: Int
    /// Building id where the vehicle connects to.
    public let buildingId: Int
    public let fms: UInt8
    public let fmsReal: UInt8
    public let caption: String
    public let t: UInt16
    
    private enum CodingKeys: String, CodingKey {
        case bulkInsert = "bulkInsert"
        case id
        case buildingId = "b"
        case fms
        case fmsReal = "fms_real"
        case caption = "c"
        case t
    }
    
    public static func == (lhs: VehicleMarker, rhs: VehicleMarker) -> Bool {
        // TODO: maybe the buildingId comparisson can be obmitted
        return lhs.id == rhs.id && lhs.buildingId == rhs.buildingId
    }
}
