//
//  RadioMessages.swift
//  
//
//  Created by Paul on 31.08.23.
//

import Foundation
import RegexBuilder

// TODO: maybe /radioMessage\((.*)\);/ because the current regex would not allow if the json contains a object {}
fileprivate let radioMessageRegex = /radioMessage\((\{[^{}]+\})\);/

internal func htmlExtractRadioMessages(from html: String) -> [RadioMessage] {
    let matches = html.matches(of: radioMessageRegex)
    
    let decoder = JSONDecoder()
    let radioMessages: [RadioMessage] = matches.compactMap {
        let jsonData = $0.output.1.data(using: String.Encoding.utf8)
        
        if let data = jsonData {
            do {
                let message = try decoder.decode(RadioMessage.self, from: data)
                return message
            } catch {
                print("[LssKit, htmlExtractRadioMessages] Error decoding RadioMessage.")
            }
        }
        
        return nil
    }
    
    return radioMessages
}
