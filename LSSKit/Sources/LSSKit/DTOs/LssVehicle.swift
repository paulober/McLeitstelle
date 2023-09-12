//
//  Vehicle.swift
//  
//
//  Created by Paul on 01.09.23.
//

import Foundation

public struct LssVehiclesResponseData: Codable {
    public let result: [LssVehicle]
    // Add other properties if needed
}

public struct LssVehicleEquipments: Codable, Identifiable, Hashable {
    public let id: Int
    public let equipmentType: String
    /// Only in V2
    public let caption: String?
    /// Only in V2/
    public let size: Int?
    
    private enum CodingKeys: String, CodingKey {
        case id
        case equipmentType = "equipment_type"
        case caption
        case size
    }
}

public struct LssVehicleAEquipments: Codable, Identifiable, Hashable {
    public let id: Int
    public let equipmentType: String
    
    private enum CodingKeys: String, CodingKey {
        case id
        case equipmentType = "equipment_type"
    }
}

public struct LssVehicle: Codable, Identifiable, Hashable, Equatable {
    public let id: Int
    public let caption: String
    public let buildingId: Int
    public let vehicleType: UInt16
    public var fmsReal: Int
    public let fmsShow: Int
    public let vehicleTypeCaption: String?
    public let workingHourStart: Int
    public let workingHourEnd: Int
    public let alarmDelay: Int
    public let maxPersonnelOverride: Int?
    public let assignedPersonnelCount: Int = 0
    public let ignoreAao: Bool
    public let targetType: String? // Use an enum if there are specific values
    public let targetId: Int?
    public let tractiveVehicleId: Int?
    public let queuedMissionId: Int?
    public let equipments: [LssVehicleEquipments]
    public let assignedEquipments: [LssVehicleAEquipments]?
    public let imageUrlStatic: String
    public let imageUrlAnimated: String
    
    private enum CodingKeys: String, CodingKey {
        case id
        case caption
        case buildingId = "building_id"
        case vehicleType = "vehicle_type"
        case fmsReal = "fms_real"
        case fmsShow = "fms_show"
        case vehicleTypeCaption = "vehicle_type_caption"
        case workingHourStart = "working_hour_start"
        case workingHourEnd = "working_hour_end"
        case alarmDelay = "alarm_delay"
        case maxPersonnelOverride = "max_personnel_override"
        case assignedPersonnelCount = "assigned_personnel_count"
        case ignoreAao = "ignore_aao"
        case targetType = "target_type"
        case targetId = "target_id"
        case tractiveVehicleId = "tractive_vehicle_id"
        case queuedMissionId = "queued_mission_id"
        case equipments
        case assignedEquipments = "assigned_equipments"
        case imageUrlStatic = "image_url_static"
        case imageUrlAnimated = "image_url_animated"
    }
    
    public static func == (lhs: LssVehicle, rhs: LssVehicle) -> Bool {
        return lhs.id == rhs.id
    }
    
    public func matches(searchText: String) -> Bool {
        if searchText == "" ||
            caption.localizedCaseInsensitiveContains(searchText) ||
            (vehicleTypeCaption?.localizedCaseInsensitiveContains(searchText) ?? false) {
            return true
        }
        // Search missions...
        return false
    }
}

public extension LssVehicle {
    static let preview = LssVehicle(id: 1, caption: "LF 1 (Leverkusen)", buildingId: 1, vehicleType: VehicleType.lf20.rawValue, fmsReal: 2, fmsShow: 2, vehicleTypeCaption: "LF 20", workingHourStart: 1, workingHourEnd: 1, alarmDelay: 1, maxPersonnelOverride: 1, ignoreAao: false, targetType: "", targetId: 1, tractiveVehicleId: 1, queuedMissionId: nil, equipments: [], assignedEquipments: [], imageUrlStatic: "", imageUrlAnimated: "")
    static let preview2 = LssVehicle(id: 2, caption: "ELW 1/1 (Leverkusen)", buildingId: 1, vehicleType: VehicleType.elw1.rawValue, fmsReal: 2, fmsShow: 2, vehicleTypeCaption: "ELW 1", workingHourStart: 1, workingHourEnd: 1, alarmDelay: 1, maxPersonnelOverride: 1, ignoreAao: false, targetType: "", targetId: 1, tractiveVehicleId: 1, queuedMissionId: nil, equipments: [], assignedEquipments: [], imageUrlStatic: "", imageUrlAnimated: "")
    static let preview3 = LssVehicle(id: 3, caption: "ELW 1/2 (Leverkusen)", buildingId: 1, vehicleType: VehicleType.elw1.rawValue, fmsReal: 2, fmsShow: 2, vehicleTypeCaption: "ELW 1", workingHourStart: 1, workingHourEnd: 1, alarmDelay: 1, maxPersonnelOverride: 1, ignoreAao: false, targetType: "", targetId: 1, tractiveVehicleId: 1, queuedMissionId: nil, equipments: [], assignedEquipments: [], imageUrlStatic: "", imageUrlAnimated: "")
    static let preview4 = LssVehicle(id: 4, caption: "ELW 2 (Landsberg am Lech)", buildingId: 1, vehicleType: VehicleType.elw2.rawValue, fmsReal: 2, fmsShow: 2, vehicleTypeCaption: "ELW 2", workingHourStart: 1, workingHourEnd: 1, alarmDelay: 1, maxPersonnelOverride: 1, ignoreAao: false, targetType: "", targetId: 1, tractiveVehicleId: 1, queuedMissionId: nil, equipments: [], assignedEquipments: [], imageUrlStatic: "", imageUrlAnimated: "")
}
