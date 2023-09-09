//
//  MissionEinsatzDetails.swift
//
//
//  Created by Paul on 08.09.23.
//

/// NOTE: not an official DTO used by Lss
public struct MissionEinsatzDetails {
    public var rewardAndPrerequisites: [String: String] = [:]
    public var requiredAssets: [String: UInt8] = [:]
    public var additionalDetails: [String: String] = [:]
}
