//
//  main.swift
//  McLeitstelleCli
//
//  Created by Paul on 04.10.23.
//

import Foundation
import Combine
import LssKit

// private get password
func getPassword() -> String {
    var password = ""
    while true {
        var keyPress = getchar()
        while keyPress != 10 && keyPress != 13 {
            let character = String(UnicodeScalar(UInt8(keyPress)))
            password.append(character)
            keyPress = getchar()
        }
        print() // Print a newline to simulate password masking
        return password
    }
}

let model = LssModelBasic()

print("[ == Login == ]")
print("Enter your username: ", terminator: "")
guard let username = readLine() else {
    print("Invalid input")
    exit(1)
}
print("Enter your password: ", terminator: "")
guard let password = readLine() else {
    print("Invalid input")
    exit(1)
}
print("\nLogging in...")

Task {
    _ = await model.auth(emailOrUsername: username, password: password)
    if !model.isSignedIn {
        print("Login failed!")
        exit(2)
    }
    print("Successfully logged in!")
    
    print("[ == Options: s = scanAndAutoAlarm  == ]")
    
    
}

RunLoop.main.run()
