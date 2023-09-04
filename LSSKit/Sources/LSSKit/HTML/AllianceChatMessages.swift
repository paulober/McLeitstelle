//
//  AllianceChatMessages.swift
//  
//
//  Created by Paul on 04.09.23.
//

import Foundation

fileprivate let allianceChatRegex = /allianceChat\((\{.*?\})\);/

internal func htmlExtractAllianceChats(from html: String) -> [ChatMessage] {
    let matches = html.matches(of: allianceChatRegex)
    
    let decoder = JSONDecoder()
    let chatMessages: [ChatMessage] = matches.compactMap {
        let jsonData = $0.output.1.data(using: String.Encoding.utf8)
        
        if let data = jsonData {
            do {
                let chatMessage = try decoder.decode(ChatMessage.self, from: data)
                return chatMessage
            } catch let error as DecodingError {
                Swift.print("[LssKit, htmlExtractAllianceChats] Error decoding ChatMessage: \(error)")
            } catch {}
        }
        
        return nil
    }
    
    return chatMessages
}
