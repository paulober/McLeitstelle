//
//  LssCredits.swift
//
//
//  Created by Paul on 02.09.23.
//

public struct LssCredits: Codable {
    public let creditsUserCurrent: Int
    public let creditsUserTotal: Int
    public let creditsAllianceCurrent: Int
    public let creditsAllianceTotal: Int
    public let creditsAllianceActive: Bool
    public let userName: String
    public let userId: Int
    public let userToplistPosition: Int
    public let userDirectplayRegistered: Bool
    public let userEmailRegistered: Bool
    public let userFacebookRegistered: Bool
    public let userAppleRegistered: Bool
    public let userLevel: Int
    public let userLevelTitle: String
    
    private enum CodingKeys: String, CodingKey {
        case creditsUserCurrent = "credits_user_current"
        case creditsUserTotal = "credits_user_total"
        case creditsAllianceCurrent = "credits_alliance_current"
        case creditsAllianceTotal = "credits_alliance_total"
        case creditsAllianceActive = "credits_alliance_active"
        case userName = "user_name"
        case userId = "user_id"
        case userToplistPosition = "user_toplist_position"
        case userDirectplayRegistered = "user_directplay_registered"
        case userEmailRegistered = "user_email_registered"
        case userFacebookRegistered = "user_facebook_registered"
        case userAppleRegistered = "user_apple_registered"
        case userLevel = "user_level"
        case userLevelTitle = "user_level_title"
    }
}

