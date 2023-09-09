//
//  MissionMarker.swift
//  
//
//  Created by Paul on 29.08.23.
//

import Foundation
import SwiftUI


public struct MissionMarker: Codable, Identifiable, Equatable {
    public let id: Int
    public var swStartIn: Int?
    public var sw: Bool?
    public var tv: Int?
    /// Id of mission type in einsaetze.json
    public var missionTypeId: UInt16?
    public var missionType: String?
    public var kt: Bool?
    public var allianceId: Int?
    public var prisonersCount: Int?
    public var patientsCount: Int?
    public var userId: Int?
    public var address: String
    public var vehicleState: Int?
    public var missingText: String?
    public var missingTextShort: String?
    public var liveCurrentValue: Int?
    public var liveCurrentWaterDamagePumpValue: Double?
    public var waterDamagePumpValue: Int?
    public var pumpingMissionValue: Int?
    public var finishUrl: String?
    public var dateEnd: Int?
    public var pumpingDateStart: Int?
    public var pumpingDateEnd: Int?
    public var dateNow: Date
    public var longitude: Double
    public var latitude: Double
    public var tlng: Double?
    public var tlat: Double?
    public var icon: String
    public var caption: String
    public var captionOld: String?
    public var filterId: String?
    public var overlayIndex: Int?
    public var additiveOverlays: String?
    public var handoff: Bool?
    
    public var missionOwnerType: MarkerOwnerType {
        get {
            #if DEBUG
            if (allianceId == nil && userId != 2313975) {
                // TODO: remove
                print("ERRRRORORORORO")
            }
            #endif
            return allianceId == nil ? MarkerOwnerType.user : MarkerOwnerType.alliance
        }
    }
    
    private enum CodingKeys: String, CodingKey {
        case id
        case swStartIn = "sw_start_in"
        case sw
        case tv
        case missionTypeId = "mtid"
        case missionType = "mission_type"
        case kt
        case allianceId = "alliance_id"
        case prisonersCount = "prisoners_count"
        case patientsCount = "patients_count"
        case userId = "user_id"
        case address
        case vehicleState = "vehicle_state"
        case missingText = "missing_text"
        case missingTextShort = "missing_text_short"
        case liveCurrentValue = "live_current_value"
        case liveCurrentWaterDamagePumpValue = "live_current_water_damage_pump_value"
        case waterDamagePumpValue = "water_damage_pump_value"
        case pumpingMissionValue = "pumping_mission_value"
        case finishUrl = "finish_url"
        case dateEnd = "date_end"
        case pumpingDateStart = "pumping_date_start"
        case pumpingDateEnd = "pumping_date_end"
        case dateNow = "date_now"
        case longitude
        case latitude
        case tlng
        case tlat
        case icon
        case caption
        case captionOld = "captionOld"
        case filterId = "filter_id"
        case overlayIndex = "overlay_index"
        case additiveOverlays = "additive_overlays"
        case handoff
    }
    
    public func matches(searchText: String) -> Bool {
        if searchText.isEmpty ||
            caption.localizedCaseInsensitiveContains(searchText) ||
            address.localizedCaseInsensitiveContains(searchText) {
            return true
        }
        // Search missions...
        return false
    }
    
    public static func == (lhs: MissionMarker, rhs: MissionMarker) -> Bool {
        return lhs.id == rhs.id
    }
    
    public mutating func update(newData: MissionMarker) {
        self.swStartIn = newData.swStartIn
        self.sw = newData.sw
        self.tv = newData.tv
        self.missionTypeId = newData.missionTypeId
        self.missionType = newData.missionType
        self.kt = newData.kt
        self.allianceId = newData.allianceId
        self.prisonersCount = newData.prisonersCount
        self.patientsCount = newData.patientsCount
        self.userId = newData.userId
        self.address = newData.address
        self.vehicleState = newData.vehicleState
        self.missingText = newData.missingText
        self.missingTextShort = newData.missingTextShort
        self.liveCurrentValue = newData.liveCurrentValue
        self.liveCurrentWaterDamagePumpValue = newData.liveCurrentWaterDamagePumpValue
        self.waterDamagePumpValue = newData.waterDamagePumpValue
        self.pumpingMissionValue = newData.pumpingMissionValue
        self.finishUrl = newData.finishUrl
        self.dateEnd = newData.dateEnd
        self.pumpingDateStart = newData.pumpingDateStart
        self.pumpingDateEnd = newData.pumpingDateEnd
        self.dateNow = newData.dateNow
        self.longitude = newData.longitude
        self.latitude = newData.latitude
        self.tlng = newData.tlng
        self.tlat = newData.tlat
        self.icon = newData.icon
        self.caption = newData.caption
        self.captionOld = newData.captionOld
        self.filterId = newData.filterId
        self.overlayIndex = newData.overlayIndex
        self.additiveOverlays = newData.additiveOverlays
        self.handoff = newData.handoff
    }

    
    public init(id: Int,
                swStartIn: Int?,
                sw: Bool?,
                tv: Int?,
                missionTypeId: UInt16?,
                missionType: String?,
                kt: Bool?,
                allianceId: Int?,
                prisonersCount: Int?,
                patientsCount: Int?,
                userId: Int?,
                address: String,
                vehicleState: Int?,
                missingText: String?,
                missingTextShort: String?,
                liveCurrentValue: Int?,
                liveCurrentWaterDamagePumpValue: Double?,
                waterDamagePumpValue: Int?,
                pumpingMissionValue: Int?,
                finishUrl: String?,
                dateEnd: Int?,
                pumpingDateStart: Int?,
                pumpingDateEnd: Int?,
                dateNow: Date,
                longitude: Double,
                latitude: Double,
                tlng: Double?,
                tlat: Double?,
                icon: String,
                caption: String,
                captionOld: String?,
                filterId: String?,
                overlayIndex: Int?,
                additiveOverlays: String?,
                handoff: Bool?) {
        
        self.id = id
        self.swStartIn = swStartIn
        self.sw = sw
        self.tv = tv
        self.missionTypeId = missionTypeId
        self.missionType = missionType
        self.kt = kt
        self.allianceId = allianceId
        self.prisonersCount = prisonersCount
        self.patientsCount = patientsCount
        self.userId = userId
        self.address = address
        self.vehicleState = vehicleState
        self.missingText = missingText
        self.missingTextShort = missingTextShort
        self.liveCurrentValue = liveCurrentValue
        self.liveCurrentWaterDamagePumpValue = liveCurrentWaterDamagePumpValue
        self.waterDamagePumpValue = waterDamagePumpValue
        self.pumpingMissionValue = pumpingMissionValue
        self.finishUrl = finishUrl
        self.dateEnd = dateEnd
        self.pumpingDateStart = pumpingDateStart
        self.pumpingDateEnd = pumpingDateEnd
        self.dateNow = dateNow
        self.longitude = longitude
        self.latitude = latitude
        self.tlng = tlng
        self.tlat = tlat
        self.icon = icon
        self.caption = caption
        self.captionOld = captionOld
        self.filterId = filterId
        self.overlayIndex = overlayIndex
        self.additiveOverlays = additiveOverlays
        self.handoff = handoff
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: MissionMarker.CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        
        self.swStartIn = try container.decodeIfPresent(Int.self, forKey: .swStartIn)
        self.sw = try container.decodeIfPresent(Bool.self, forKey: .sw)
        self.tv = try container.decodeIfPresent(Int.self, forKey: .tv)
        self.missionTypeId = try container.decodeIfPresent(UInt16.self, forKey: .missionTypeId)
        self.missionType = try container.decodeIfPresent(String.self, forKey: .missionType)
        self.kt = try container.decodeIfPresent(Bool.self, forKey: .kt)
        self.allianceId = try container.decodeIfPresent(Int.self, forKey: .allianceId)
        self.prisonersCount = try container.decodeIfPresent(Int.self, forKey: .prisonersCount)
        self.patientsCount = try container.decodeIfPresent(Int.self, forKey: .patientsCount)
        self.userId = try container.decodeIfPresent(Int.self, forKey: .userId)
        self.address = try container.decode(String.self, forKey: .address)
        self.vehicleState = try container.decodeIfPresent(Int.self, forKey: .vehicleState)
        self.missingText = try container.decodeIfPresent(String.self, forKey: .missingText)
        self.missingTextShort = try container.decodeIfPresent(String.self, forKey: .missingTextShort)
        self.liveCurrentValue = try container.decodeIfPresent(Int.self, forKey: .liveCurrentValue)
        self.liveCurrentWaterDamagePumpValue = try container.decodeIfPresent(Double.self, forKey: .liveCurrentWaterDamagePumpValue)
        self.waterDamagePumpValue = try container.decodeIfPresent(Int.self, forKey: .waterDamagePumpValue)
        self.pumpingMissionValue = try container.decodeIfPresent(Int.self, forKey: .pumpingMissionValue)
        self.finishUrl = try container.decodeIfPresent(String.self, forKey: .finishUrl)
        self.dateEnd = try container.decodeIfPresent(Int.self, forKey: .dateEnd)
        self.pumpingDateStart = try container.decodeIfPresent(Int.self, forKey: .pumpingDateStart)
        self.pumpingDateEnd = try container.decodeIfPresent(Int.self, forKey: .pumpingDateEnd)
        
        let dateNowTimestamp = try container.decode(Int.self, forKey: .dateNow)
        self.dateNow = Date(timeIntervalSince1970: TimeInterval(dateNowTimestamp))
        
        self.longitude = try container.decode(Double.self, forKey: .longitude)
        self.latitude = try container.decode(Double.self, forKey: .latitude)
        self.tlng = try container.decodeIfPresent(Double.self, forKey: .tlng)
        self.tlat = try container.decodeIfPresent(Double.self, forKey: .tlat)
        self.icon = try container.decode(String.self, forKey: .icon)
        self.caption = try container.decode(String.self, forKey: .caption)
        self.captionOld = try container.decodeIfPresent(String.self, forKey: .captionOld)
        self.filterId = try container.decodeIfPresent(String.self, forKey: .filterId)
        self.overlayIndex = try container.decodeIfPresent(Int.self, forKey: .overlayIndex)
        self.additiveOverlays = try container.decodeIfPresent(String.self, forKey: .additiveOverlays)
        self.handoff = try container.decodeIfPresent(Bool.self, forKey: .handoff)
    }
}

public extension MissionMarker {
    static let preview = MissionMarker(id: 1, swStartIn: 1, sw: true, tv: 2, missionTypeId: 2, missionType: "Feuer", kt: false, allianceId: 2, prisonersCount: 2, patientsCount: 3, userId: 2, address: "Eine Addresse", vehicleState: 2, missingText: "Nichts fehlt", missingTextShort: "", liveCurrentValue: 2, liveCurrentWaterDamagePumpValue: 3.1, waterDamagePumpValue: 2, pumpingMissionValue: 2, finishUrl: "", dateEnd: 2, pumpingDateStart: 2, pumpingDateEnd: 2, dateNow: Date(), longitude: 48.1, latitude: 10.5, tlng: 12.2, tlat: 1.4, icon: "fire_rot", caption: "Feuer in Schule", captionOld: "", filterId: "", overlayIndex: 2, additiveOverlays: "", handoff: false)
}
