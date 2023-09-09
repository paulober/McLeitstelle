//
//  URLs.swift
//
//
//  Created by Paul on 31.08.23.
//

import Foundation

internal let lssBaseURL = URL(string: "https://www.leitstellenspiel.de")!
internal let lssFayeURL = URL(string: "wss://www.leitstellenspiel.de/faye")!

internal let lssBuildingsURL = lssBaseURL.appending(component: "/buildings")
internal let lssBuildingsVehiclesMapURL = lssBuildingsURL.appending(component: "/vehiclesMap")

internal func lssBuildingsIDURL(buildingId: String) -> URL {
    return lssBuildingsURL.appending(component: "/\(buildingId)")
}

internal func lssBuildingsVehiclesURL(buildingId: String) -> URL {
    return lssBaseURL.appendingPathComponent("api/v2/buildings/\(buildingId)/vehicles")
}

internal let lssVehiclesURL = lssBaseURL.appendingPathComponent("vehicles")

internal func lssIVehiclesURL(_ vehicleId: Int) -> URL {
    return lssVehiclesURL(String(vehicleId))
}

internal func lssVehiclesURL(_ vehicleId: String) -> URL {
    return lssVehiclesURL.appending(component: vehicleId)
}

internal let lssMissionsURL = lssBaseURL.appending(component: "/missions")

internal func lssMissionAlarmURL(_ missionId: Int) -> URL {
    return lssBaseURL.appendingPathComponent("missions/\(missionId)/alarm")
}

internal let lssUsersSignInURL = lssBaseURL.appendingPathComponent("users/sign_in")

public struct LssEndpoint {
    static let vehicles = "api/vehicles"
    static func vehiclesByID(_ id: Int) -> String { return "api/vehicles/\(id)" }
    static let vehicleStates = "api/vehicle_states"
    static let buildings = "api/buildings"
    static func buildingsByID(_ id: Int) -> String { return "api/buildings/\(id)" }
    static func buildingsVehiclesByID(_ id: Int) -> String { return "api/buildings/\(id)/vehicles" }
    static let allianceBuildings = "api/alliance_buildings"
    static let credits = "api/credits"
    static let allianceInfo = "api/allianceinfo"
    static let settings = "api/settings"
    static let missions = "einsaetze.json"
    
    // V2 Endpoints
    static let v2Vehicles = "api/v2/vehicles"
    static func v2VehiclesByID(_ id: Int) -> String { return "api/v2/vehicles/\(id)" }
    static func v2BuildingsVehiclesByID(_ id: Int) -> String { return "api/v2/buildings/\(id)/vehicles" }
    static func v2BuildingsVehiclesByID(_ id: String) -> String { return "api/v2/buildings/\(id)/vehicles" }
    
    static func urlForVehicles() -> URL {
        return lssBaseURL.appendingPathComponent(vehicles)
    }

    static func urlForVehiclesByID(_ id: Int) -> URL {
        return lssBaseURL.appendingPathComponent(vehiclesByID(id))
    }

    static func urlForVehicleStates() -> URL {
        return lssBaseURL.appendingPathComponent(vehicleStates)
    }

    static func urlForBuildings() -> URL {
        return lssBaseURL.appendingPathComponent(buildings)
    }

    static func urlForBuildingsByID(_ id: Int) -> URL {
        return lssBaseURL.appendingPathComponent(buildingsByID(id))
    }

    static func urlForBuildingsVehiclesByID(_ id: Int) -> URL {
        return lssBaseURL.appendingPathComponent(buildingsVehiclesByID(id))
    }

    static func urlForAllianceBuildings() -> URL {
        return lssBaseURL.appendingPathComponent(allianceBuildings)
    }

    static func urlForCredits() -> URL {
        return lssBaseURL.appendingPathComponent(credits)
    }

    static func urlForAllianceInfo() -> URL {
        return lssBaseURL.appendingPathComponent(allianceInfo)
    }

    static func urlForSettings() -> URL {
        return lssBaseURL.appendingPathComponent(settings)
    }

    static func urlForMissions() -> URL {
        return lssBaseURL.appendingPathComponent(missions)
    }

    // V2 Endpoints
    public static func urlForV2Vehicles() -> URL {
        return lssBaseURL.appendingPathComponent(v2Vehicles)
    }

    public static func urlForV2VehiclesByID(_ id: Int) -> URL {
        return lssBaseURL.appendingPathComponent(v2VehiclesByID(id))
    }

    public static func urlForV2BuildingsVehiclesByID(_ id: Int) -> URL {
        return lssBaseURL.appendingPathComponent(v2BuildingsVehiclesByID(id))
    }
    
    public static func urlForV2BuildingsVehiclesByID(_ id: String) -> URL {
        return lssBaseURL.appendingPathComponent(v2BuildingsVehiclesByID(id))
    }
}
