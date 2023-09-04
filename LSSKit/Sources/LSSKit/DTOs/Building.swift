//
//  Building.swift
//
//
//  Created by Paul on 02.09.23.
//

import Foundation

public struct LssBuildingExtension: Codable, Hashable {
    public let caption: String
    public let enabled: Bool
    public let typeId: Int

    public struct Availability: Codable, Hashable {
        public let available: Bool
        public let availableAt: String?
        
        private enum CodingKeys: String, CodingKey {
            case available
            case availableAt = "available_at"
        }
    }
    
    public let availability: Availability
    
    private enum CodingKeys: String, CodingKey {
        case caption
        case enabled
        case typeId = "type_id"
        case availability
    }
}

public struct LssBuildingStorage: Codable, Hashable {
    public let upgradeType: String
    public let available: Bool
    public let typeId: String
    
    private enum CodingKeys: String, CodingKey {
        case upgradeType = "upgrade_type"
        case available
        case typeId = "type_id"
    }
}

public struct LssBuildingSpecialization: Codable, Hashable {
    public let caption: String
    public let type: String
    public let active: Bool
    public let available: Bool
}

public struct LssBuilding: Codable, Identifiable, Hashable {
    public let id: Int
    public let personalCount: Int
    public let level: Int
    public let buildingType: Int
    public let caption: String
    public let latitude: Double
    public let longitude: Double
    public let extensions: [LssBuildingExtension]
    public let storageUpgrades: [LssBuildingStorage]
    public let leitstelleBuildingId: Int?
    public let smallBuilding: Bool
    public let enabled: Bool
    public let generateOwnMissions: Bool
    public let personalCountTarget: Int
    public let hiringPhase: Int
    public let hiringAutomatic: Bool
    public let customIconUrl: String?
    public let specialization: [LssBuildingSpecialization]
    public let isAllianceShared: Bool
    public let allianceShareCreditsPercentage: Double
    public let patientCount: Int
    public let prisonerCount: Int
    public let generatesMissionCategories: [String]

    private enum CodingKeys: String, CodingKey {
        case id
        case personalCount = "personal_count"
        case level
        case buildingType = "building_type"
        case caption
        case latitude
        case longitude
        case extensions
        case storageUpgrades = "storage_upgrades"
        case leitstelleBuildingId = "leitstelle_building_id"
        case smallBuilding = "small_building"
        case enabled
        case generateOwnMissions = "generate_own_missions"
        case personalCountTarget = "personal_count_target"
        case hiringPhase = "hiring_phase"
        case hiringAutomatic = "hiring_automatic"
        case customIconUrl = "custom_icon_url"
        case specialization
        case isAllianceShared = "is_alliance_shared"
        case allianceShareCreditsPercentage = "alliance_share_credits_percentage"
        case patientCount = "patient_count"
        case prisonerCount = "prisoner_count"
        case generatesMissionCategories = "generates_mission_categories"
    }
}
