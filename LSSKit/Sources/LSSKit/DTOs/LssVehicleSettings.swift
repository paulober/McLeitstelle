//
//  LssVehicleSettings.swift
//
//
//  Created by Paul on 13.09.23.
//

import Foundation

public struct LssVehicleSettings {
    /// Required
    public var callSign: String = ""
    public var maxPersonsCount: UInt8 = 2
    /// Delay (in seconds) a vehicle waits befor leaving the station on alarm
    public var disengagementDelay: UInt16 = 0
    public var ignoreAao: Bool = false
    /// 0 - 23 (0 = 00:00, 1 = 01:00, 23 = 23:00)
    public var workingHoursBegin: UInt8 = 0
    /// 0 - 23 (0 = 00:00, 1 = 01:00, 23 = 23:00)
    public var workingHoursEnd: UInt8 = 0
    /// Max length = 50
    public var ownVehicleClass: String = ""
    /// Nur die eigene Fahrzeugklasse in der AAO verwenden. (Beispiel: Ein LF 20 wird mit diesem Haken nicht mehr als LF ausgewählt - sondern kann nur über die eigene Fahrzeugklasse angesprochen werden)
    public var onlyUseOwnVehicleClass: Bool = false
    
    public init(from vehicle: LssVehicle) {
        callSign = vehicle.caption
        maxPersonsCount = vehicle.maxPersonnelOverride ?? 0
        disengagementDelay = vehicle.alarmDelay
        ignoreAao = vehicle.ignoreAao
        workingHoursBegin = vehicle.workingHourStart
        workingHoursEnd = vehicle.workingHourEnd
        ownVehicleClass = vehicle.vehicleTypeCaption ?? ""
    }
    
    public func getAsQueryItems() -> [URLQueryItem] {
        return [
            URLQueryItem(name: "_method", value: "put"),
            URLQueryItem(name: "vehicle[caption]", value: callSign),
            URLQueryItem(name: "vehicle[personal_max]", value: String(maxPersonsCount)),
            URLQueryItem(name: "vehicle[start_delay]", value: String(disengagementDelay)),
            URLQueryItem(name: "vehicle[ignore_aao]", value: String(ignoreAao ? 1 : 0)),
            URLQueryItem(name: "vehicle[working_hour_start]", value: String(workingHoursBegin)),
            URLQueryItem(name: "vehicle[working_hour_end]", value: String(workingHoursEnd)),
            URLQueryItem(name: "vehicle[vehicle_type_caption]", value: String(ownVehicleClass)),
            URLQueryItem(name: "vehicle[vehicle_type_ignore_default_aao]", value: String(ignoreAao ? 1 : 0)),
            // unsupported settings
            URLQueryItem(name: "vehicle[image_to_all]", value: String(0)),
        ]
    }
}
