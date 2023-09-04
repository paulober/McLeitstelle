//
//  CredetnialsStore.swift
//
//
//  Created by Paul on 03.09.23.
//

import Foundation
import Security

internal struct EssentialCredentials: Codable {
    let rememberUserToken: String
    let sessionId: String
    let stripeMid: String
    let mcUniqueClientId: String
    
    init(from creds: FayeCredentials) {
        rememberUserToken = creds.rememberUserToken
        sessionId = creds.sessionId
        stripeMid = creds.stripeMid
        mcUniqueClientId = creds.mcUniqueClientId
    }
}

fileprivate let userDefaultsUsernameKey = "LssUsernameOrEmail"

internal func saveCredentials(
    username: String,
    creds: EssentialCredentials
) -> Bool {
    do {
        let data = try JSONEncoder().encode(creds)
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: username,
            kSecValueData as String: data
        ]
        
        SecItemDelete(query as CFDictionary)
        
        let status = SecItemAdd(query as CFDictionary, nil)
        if status == errSecSuccess {
            UserDefaults.standard.set(username, forKey: userDefaultsUsernameKey)
            return true
        }
    } catch {
        return false
    }
    
    return false
}

/**
 Returns username, credentials
 */
internal func retrieveCredentials() -> (String, EssentialCredentials)? {
    guard let username = UserDefaults.standard.string(forKey: userDefaultsUsernameKey) else { return nil }
    
    if let creds = retrieveCredentials(forUsername: username) {
        return (username, creds)
    }
    
    return nil
}

internal func retrieveCredentials(forUsername username: String) -> EssentialCredentials? {
    let query: [String: Any] = [
        kSecClass as String: kSecClassGenericPassword,
        kSecAttrAccount as String: username,
        kSecReturnData as String: true
    ]

    var result: AnyObject?
    let status = SecItemCopyMatching(query as CFDictionary, &result)

    if status == errSecSuccess {
        if let data = result as? Data,
           let credentials = try? JSONDecoder().decode(EssentialCredentials.self, from: data) {
            return credentials
        }
    }

    return nil
}

internal func saveCredentials(username: String, password: String) -> Bool {
    guard let data = password.data(using: .utf8) else { return false }

    let query: [String: Any] = [
        kSecClass as String: kSecClassGenericPassword,
        kSecAttrAccount as String: username,
        kSecValueData as String: data
    ]

    SecItemDelete(query as CFDictionary)

    let status = SecItemAdd(query as CFDictionary, nil)
    if status == errSecSuccess {
        UserDefaults.standard.set(username, forKey: userDefaultsUsernameKey)
        return true
    }
    
    return false
}

internal func retrieveUsernameAndPassword() -> (String, String)? {
    guard let username = UserDefaults.standard.string(forKey: userDefaultsUsernameKey) else { return nil }
    
    if let password = retrievePassword(forUsername: username) {
        return (username, password)
    }
    
    return nil
}

internal func retrievePassword(forUsername username: String) -> String? {
    let query: [String: Any] = [
        kSecClass as String: kSecClassGenericPassword,
        kSecAttrAccount as String: username,
        kSecReturnData as String: true
    ]

    var result: AnyObject?
    let status = SecItemCopyMatching(query as CFDictionary, &result)

    if status == errSecSuccess {
        if let data = result as? Data, let password = String(data: data, encoding: .utf8) {
            return password
        }
    }

    return nil
}
