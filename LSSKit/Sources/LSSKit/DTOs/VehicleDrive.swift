//
//  VehicleDrive.swift
//  
//
//  Created by Paul on 29.08.23.
//

public struct VehicleDrive: Codable, Identifiable, Hashable, Equatable {
    public let id: Int
    public let b: Int
    public let rh: String
    public let vom: Bool
    public let vtid: Int
    public let mid: String
    public let dd: Int
    public let s: String
    public let fms: Int
    public let fmsReal: Int
    public let userId: Int
    public let isr: String
    public let inGraphic: String
    public let apngSonderrechte: String
    public let ioverwrite: String
    public let caption: String
    public let sr: String
    
    private enum CodingKeys: String, CodingKey {
        case id
        case b
        case rh
        case vom
        case vtid
        case mid
        case dd
        case s
        case fms
        case fmsReal = "fms_real"
        case userId = "user_id"
        case isr
        case inGraphic = "in"
        case apngSonderrechte = "apng_sonderrechte"
        case ioverwrite
        case caption
        case sr
    }
    
    public static func == (lhs: VehicleDrive, rhs: VehicleDrive) -> Bool {
        // TODO: maybe the missionId comparisson can be obmitted
        return lhs.id == rhs.id && lhs.mid == rhs.mid
    }
}
