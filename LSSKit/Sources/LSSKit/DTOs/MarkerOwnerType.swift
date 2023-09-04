//
//  MarkerOwnerType.swift
//  
//
//  Created by Paul on 03.09.23.
//

import SwiftUI

/// Not part of the DTOs
public enum MarkerOwnerType: String, Comparable {
    case user = "User"
    case alliance = "Alliance"
    
    public static func < (lhs: MarkerOwnerType, rhs: MarkerOwnerType) -> Bool {
        if lhs == .user && rhs == .alliance {
            return true
        }
        
        return false
    }
    
    public var iconSystemName: String {
        switch self {
        case .user:
            return "person"
        case .alliance:
            return "person.3"
        }
    }
    
    public var label: some View {
        Label(rawValue, systemImage: iconSystemName)
    }
}
