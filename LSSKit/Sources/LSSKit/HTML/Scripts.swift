//
//  Scripts.swift
//  
//
//  Created by Paul on 31.08.23.
//

import Foundation
import RegexBuilder

fileprivate let scriptRegex = Regex {
    "<script"
    Anchor.wordBoundary
    ZeroOrMore(CharacterClass.anyOf("<").inverted)
    ZeroOrMore {
        Regex {
            NegativeLookahead {
                "</script>"
            }
            "<"
            ZeroOrMore(CharacterClass.anyOf("<").inverted)
        }
    }
    "</script>"
}

/**
    VERY SLOW!!!
 */
internal func htmlReduceToScripts(from html: String) -> String {
    let matches = html.matches(of: scriptRegex)
    
    var extractedScripts = ""
    
    for match in matches {
        let scriptBlock = String(html[match.range])
        extractedScripts += scriptBlock
    }
    
    return extractedScripts
}
