//
//  CredetnialsStore.swift
//
//
//  Created by Paul on 03.09.23.
//

import Foundation
#if os(iOS) || os(macOS)
import Security
#endif

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
        
        #if os(iOS) || os(macOS)
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
        #endif
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
    #if os(iOS) || os(macOS)
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
        } else {
            print("[LssKit, retrieveCredentials] Error decoding data")
        }
    }
    #endif

    return nil
}

internal func deleteCredentials() -> Bool {
    guard let username = UserDefaults.standard.string(forKey: userDefaultsUsernameKey) else { return false }
    
    return deleteCredentials(for: username)
}

internal func deleteCredentials(for username: String) -> Bool {
    #if os(iOS) || os(macOS)
    let query: [String: Any] = [
        kSecClass as String: kSecClassGenericPassword,
        kSecAttrAccount as String: username
    ]
    
    let status = SecItemDelete(query as CFDictionary)
    #endif
    
    return status == noErr
}

internal func saveCredentials(username: String, password: String) -> Bool {
    guard let data = password.data(using: .utf8) else { return false }

    #if os(iOS) || os(macOS)
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
    #endif
    
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
    #if os(iOS) || os(macOS)
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
    #endif

    return nil
}

