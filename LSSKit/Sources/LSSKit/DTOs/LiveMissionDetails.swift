//
//  LiveMissionDetails.swift
//
//
//  Created by Paul on 05.09.23.
//

/// NOTE: not an official DTO used by Lss
public struct LiveMissionDetails {
    public var vehiclesAtIds: [Int] = []
    public var vehiclesDrivingIds: [Int] = []
    // vID: timeInSeconds
    public var vehicleTravelTimes: [Int: Int] = [:]
    public var vehicleNames: [Int: String] = [:]
    public var vehicleTypeIds: [Int: Int] = [:]
    public var vehicleOwners: [Int: String] = [:]
    //public var vehicleBuildings: [Int: String] = [:]
    // Patient name: vehicleId
    public var patientsAtVehicleIds: [String: Int] = [:]
    
    public var vehiclesWithMessages: [Int] = []
    
    public init() {}
}
