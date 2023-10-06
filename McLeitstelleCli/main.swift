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

func pMission(mid: Int, additionalText: String) {
    print("[Mission] ID: \(mid), \(additionalText)")
}

let model = LssModelBasic()
var cancelables: [AnyCancellable] = []
var missionMarkersInProcess: [MissionMarker] = []

func alarm(mid: Int, vid: Int) async -> Bool {
    return await alarm(mid: mid, vids: [vid])
}

func alarm(mid: Int, vids: Set<Int>) async -> Bool {
    return await model.missionAlarm(missionId: mid, vehicleIds: vids)
}

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
    print("[ == Connecting == ]")
    await model.connectAsync()
    if !model.isConnected() {
        print("[ERROR] Failed to connect")
        return
    }
    print("Connected")
    
    print("[ == Options: s = scanAndAutoAlarm  == ]")
    
    model.missionMarkers.publisher.sink { m in
        if m.userId != model.getUserID() {
            return
        }
        
        // check if it is already in
        guard let liveValue = m.liveCurrentValue, liveValue < 100 else {
            return
        }
        // TODO: caled to often
        model.fetchVehicles()
        
        if m.caption.lowercased() == "krankentransport" {
            pMission(mid: m.id, additionalText: m.caption)
            let ktws = model.vehicles.filter {
                $0.vehicleType == VehicleType.ktw.rawValue
                && ($0.fmsShow == FMSStatus.einsatzbereitWache.rawValue
                    || ($0.fmsShow == FMSStatus.ankunftAnEinsatz.rawValue
                        && $0.queuedMissionId == nil)
                )
            }
            
            if let first = ktws.first {
                Task {
                    let success = await alarm(mid: m.id, vid: first.id)
                    print("Alarmed KTW with following status: \(success)")
                }
            }
            return
        }
        
        guard let mtId = m.missionTypeId else {
            print("[ERROR] No mission type id!")
            return
        }
        
        let einsatzDetails = await scanMissionEinsatzHTML(csrfToken: model.getCsrfToken() ?? "", missionTypeId: mtId, missionId: m.id)
        
        let missionUnitsRequirement = einsatzDetails.scan()
        
        var canNotAlarmAll = false
        var vehiclesToAlarm: Set<Int> = []
        
        // TODO: does not work; filter nearest diestance and not ofer 100km
        for vt in VehicleType.allCases {
            let howMany = missionUnitsRequirement.howMany(of: vt)
            let availableVehicles = model.vehicles.filter {$0.fmsShow == FMSStatus.einsatzbereitWache.rawValue}
            if availableVehicles.count >= howMany {
                for vid in availableVehicles.prefix(Int(howMany)).map({ $0.id }) {
                    vehiclesToAlarm.insert(vid)
                }
            } else {
                print("Not enought vehicles for mission: \(m.id) with \(vt) amount: \(howMany)")
                canNotAlarmAll = true
            }
        }
        
        if canNotAlarmAll {
            print("Can not alarm all")
            return
        }
        
        if await alarm(mid: m.id, vids: vehiclesToAlarm) {
            pMission(mid: m.id, additionalText: "\(m.caption); Alarmed sucessfully")
        }
    }
    .store(in: &cancelables)
}

RunLoop.main.run()
model.disconnect()
print("Disconnected")
