//
//  FayeCredentials.swift
//  
//
//  Created by Paul on 29.08.23.
//

public struct FayeCredentials {
    public var stripeMid: String
    public var sessionId: String
    public var mcUniqueClientId: String
    public var rememberUserToken: String
    
    // temp vars
    public var userId: String?
    public var userName: String?
    public var allianceId: String?
    public var allianceGuid: String?
    public var csrfToken: String?
    
    public var exts: [String: String] = [:]
    public var mapView: (Double, Double)?
    
    public init(stripeMid: String, sessionId: String, mcUniqueClientId: String, rememberUserToken: String, userId: String? = nil, userName: String? = nil, allianceId: String? = nil, allianceGuid: String? = nil, csrfToken: String? = nil, exts: [String : String] = [:], mapView: (Double, Double)? = nil) {
        self.stripeMid = stripeMid
        self.sessionId = sessionId
        self.mcUniqueClientId = mcUniqueClientId
        self.rememberUserToken = rememberUserToken
        self.userId = userId
        self.userName = userName
        self.allianceId = allianceId
        self.allianceGuid = allianceGuid
        self.csrfToken = csrfToken
        self.exts = exts
        self.mapView = mapView
    }
}
