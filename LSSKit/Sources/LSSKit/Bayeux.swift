//
//  File.swift
//  
//
//  Created by Paul on 29.08.23.
//

import Foundation

public enum BayeuxChannel: String, Codable {
    case Handshake = "/meta/handshake"
    case Connect = "/meta/connect"
    case Disconnect = "/meta/disconnect"
    case Subscribe = "/meta/subscribe"
    case Unsubscibe = "/meta/unsubscribe"
    
    // custom
    static func userChannel(userId: String) -> String {
        return "/private-user\(userId)de_DE"
    }
    
    static func allianceChannel(allianceId: String) -> String {
        return "/private-alliance/\(allianceId)/de_DE"
    }
    
    case AllDE = "/allde_DE"
}

/**
 Connection-tpes in kebab-case
 */
public enum BConnectionType: String, Codable {
    case WebSocket = "websocket"
    case LongPolling = "long-polling"
    case CrossOriginLongPolling = "cross-origin-long-polling"
    case CallbackPolling = "callback-polling"
    case Eventsource = "eventsource"
    case InProcess = "in-process"
}

enum BError: Error {
    case dataCorrupted
}

public struct BMessage: Codable {
    var channel: String
    var clientId: String?
    var version: String?
    var connectionType: BConnectionType?
    var data: String?
    var subscription: String?
    var id: String?
    var supportedConnectionTypes: [BConnectionType]?
    var successful: Bool?
    var ext: [String: String]?
    
    static var idCounter: UInt32 = 1
    
    internal init(channel: BayeuxChannel, clientId: String? = nil, version: String? = nil, connectionType: BConnectionType? = nil, data: String? = nil, subscription: String? = nil, id: String, supportedConnectionTypes: [BConnectionType]? = nil, successful: Bool? = nil, ext: [String: String]? = nil) {
        self.channel = channel.rawValue
        self.clientId = clientId
        self.version = version
        self.connectionType = connectionType
        self.data = data
        self.subscription = subscription
        self.id = id
        self.supportedConnectionTypes = supportedConnectionTypes
        self.successful = successful
        self.ext = ext
    }
    
    init(channel: BayeuxChannel, clientId: String? = nil, version: String? = nil, connectionType: BConnectionType? = nil, data: String? = nil, subscription: String? = nil, supportedConnectionTypes: [BConnectionType]? = nil, successful: Bool? = nil, ext: [String: String]? = nil) {
        self.channel = channel.rawValue
        self.clientId = clientId
        self.version = version
        self.connectionType = connectionType
        self.data = data
        self.subscription = subscription
        
        self.id = String(BMessage.idCounter)
        BMessage.idCounter += 1
        
        self.supportedConnectionTypes = supportedConnectionTypes
        self.successful = successful
        self.ext = ext
    }
    
    internal init(channel: String, clientId: String? = nil, version: String? = nil, connectionType: BConnectionType? = nil, data: String? = nil, subscription: String? = nil, id: String, supportedConnectionTypes: [BConnectionType]? = nil, successful: Bool? = nil, ext: [String: String]? = nil) {
        self.channel = channel
        self.clientId = clientId
        self.version = version
        self.connectionType = connectionType
        self.data = data
        self.subscription = subscription
        self.id = id
        self.supportedConnectionTypes = supportedConnectionTypes
        self.successful = successful
        self.ext = ext
    }
    
    init(channel: String, clientId: String? = nil, version: String? = nil, connectionType: BConnectionType? = nil, data: String? = nil, subscription: String? = nil, supportedConnectionTypes: [BConnectionType]? = nil, successful: Bool? = nil, ext: [String: String]? = nil) {
        self.channel = channel
        self.clientId = clientId
        self.version = version
        self.connectionType = connectionType
        self.data = data
        self.subscription = subscription
        
        self.id = String(BMessage.idCounter)
        BMessage.idCounter += 1
        
        self.supportedConnectionTypes = supportedConnectionTypes
        self.successful = successful
        self.ext = ext
    }
}
