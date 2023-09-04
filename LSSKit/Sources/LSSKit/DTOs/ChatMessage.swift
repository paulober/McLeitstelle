//
//  ChatMessage.swift
//
//
//  Created by Paul on 03.09.23.
//

import Foundation

public struct ChatMessage: Codable, Hashable {
    public let ignoreAudio: Bool?
    /// When it's a message inside a mission
    public let missionId: Int?
    /// If it's a private message
    public let whisper: Int
    /// When a mission is linked
    public let missionCaption: String?
    /// The content of the message
    public let message: String
    /// If sender is allianceAdmin
    public let allianceAdmin: Bool
    /// If sender is allianceCoadmin
    public let allianceCoadmin: Bool
    /// The sender's user-ID
    public let userId: Int
    /// Username of the sender
    public let username: String
    /// The time in 24h format from when the message was created
    public let date: String
    /// The full German date representation from when the message was created
    public let dateHidden: String
    /// ISO timestamp from when the message was created
    public let isoTimestamp: String

    enum CodingKeys: String, CodingKey {
        case ignoreAudio = "ignore_audio"
        case missionId = "mission_id"
        case whisper
        case missionCaption = "mission_caption"
        case message
        case allianceAdmin = "alliance_admin"
        case allianceCoadmin = "alliance_coadmin"
        case userId = "user_id"
        case username
        case date
        case dateHidden = "date_hidden"
        case isoTimestamp = "iso_timestamp"
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(userId)
        hasher.combine(isoTimestamp)
    }
    
    public init(ignoreAudio: Bool?,
                    missionId: Int?,
                    whisper: Int,
                    missionCaption: String?,
                    message: String,
                    allianceAdmin: Bool,
                    allianceCoadmin: Bool,
                    userId: Int,
                    username: String,
                    date: String,
                    dateHidden: String,
                    isoTimestamp: String) {
            
        self.ignoreAudio = ignoreAudio
        self.missionId = missionId
        self.whisper = whisper
        self.missionCaption = missionCaption
        self.message = message
        self.allianceAdmin = allianceAdmin
        self.allianceCoadmin = allianceCoadmin
        self.userId = userId
        self.username = username
        self.date = date
        self.dateHidden = dateHidden
        self.isoTimestamp = isoTimestamp
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        ignoreAudio = try container.decodeIfPresent(Bool.self, forKey: .ignoreAudio)
        missionId = try container.decodeIfPresent(Int.self, forKey: .missionId)
        whisper = try container.decode(Int.self, forKey: .whisper)
        missionCaption = try container.decodeIfPresent(String.self, forKey: .missionCaption)
        message = try container.decode(String.self, forKey: .message)
        allianceAdmin = Bool(try container.decode(String.self, forKey: .allianceAdmin)) ?? false
        allianceCoadmin = Bool(try container.decode(String.self, forKey: .allianceCoadmin)) ?? false
        userId = try container.decode(Int.self, forKey: .userId)
        username = try container.decode(String.self, forKey: .username)
        date = try container.decode(String.self, forKey: .date)
        dateHidden = try container.decode(String.self, forKey: .dateHidden)
        isoTimestamp = try container.decode(String.self, forKey: .isoTimestamp)
    }
}

public extension ChatMessage {
    static let preview = ChatMessage(ignoreAudio: true, missionId: 1, whisper: 0, missionCaption: "Mission Caption", message: "Hallo Vorschau", allianceAdmin: false, allianceCoadmin: false, userId: 1234, username: "Test_User", date: "12:14", dateHidden: "14. August 2023, 12:14", isoTimestamp: String(Date().timeIntervalSince1970))
    
    static let preview2 = ChatMessage(ignoreAudio: true, missionId: 1, whisper: 0, missionCaption: "Mission Caption", message: "Hallo Vorschau", allianceAdmin: false, allianceCoadmin: false, userId: 1235, username: "Test_User22", date: "12:19", dateHidden: "14. August 2023, 12:194", isoTimestamp: String(Date().timeIntervalSince1970))
}
