//
//  BuildingMarker.swift
//
//
//  Created by Paul on 01.09.23.
//

public struct BuildingMarker: Codable, Identifiable, Hashable, Equatable {
    public let id: Int
    public let userId: Int?
    public let name: String
    public let longitude: Double
    public let latitude: Double
    public let icon: String
    public let iconOther: String
    public let vgi: UInt16?
    public let lbid: Int
    public let showVehiclesAtStartpage: Bool
    /// THW stations for example doesn't have a level
    public let level: Int?
    public let personalCount: Int
    public let buildingType: UInt8
    public let filterId: String
    public let detailButton: String
    
    public var buildingOwnerType: MarkerOwnerType {
        get {
            return userId != nil ? MarkerOwnerType.user : MarkerOwnerType.alliance
        }
    }
    
    // TODO: myabe fill static property with this on Decode to reduce performance usage where Buildings are used
    public var buildingTypeString: String {
        get {
            return LssBuildingType(rawValue: self.buildingType)?.asGermanString() ?? "N/A"
        }
    }
    
    private enum CodingKeys: String, CodingKey {
        case id, userId = "user_id", name, longitude, latitude, icon, iconOther = "icon_other", vgi, lbid, showVehiclesAtStartpage = "show_vehicles_at_startpage",
             level, personalCount = "personal_count", buildingType = "building_type", filterId = "filter_id", detailButton = "detail_button"
    }
    
    public func matches(searchText: String) -> Bool {
        if searchText == "" ||
            name.localizedCaseInsensitiveContains(searchText) ||
            buildingTypeString.localizedCaseInsensitiveContains(searchText) {
            return true
        }
        // Search buildings...
        return false
    }
    
    public static func == (lhs: BuildingMarker, rhs: BuildingMarker) -> Bool {
        // TODO: maybe the userId comparisson can be obmitted
        return lhs.id == rhs.id && lhs.userId == rhs.userId
    }
}
