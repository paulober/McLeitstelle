//
//  AccountView.swift
//  McLeitstelle
//
//  Created by Paul on 31.08.23.
//

import SwiftUI
import LssKit

struct AccountView: View {
    @ObservedObject var model: LssModel
    
    var body: some View {
        ZStack {
            List {
                Label("Username: \(model.getUsername() ?? "N/A")", systemImage: "person.circle")
                
                Picker("MissionSpeed", selection: $model.missionSpeed) {
                    Text("Pause").tag(MissionSpeedValues.pause)
                    
                    Text("Alle 10 min").tag(MissionSpeedValues.per10Minutes)
                    Text("Alle 7 min").tag(MissionSpeedValues.per7Minutes)
                    Text("Alle 5 min").tag(MissionSpeedValues.per5Minutes)
                    Text("Alle 2 min").tag(MissionSpeedValues.per2Minutes)
                    Text("Alle 1 min").tag(MissionSpeedValues.perMinute)
                    Text("Alle 30 sec").tag(MissionSpeedValues.per30Seconds)
                    Text("Alle 20 sec").tag(MissionSpeedValues.per20Seconds)
                }
                
                Button {
                    model.logout()
                } label: {
                    Text("Logout")
                }
            }
        }
        .navigationTitle("Account")
        .onChange(of: model.missionSpeed) {
            Task {
                _ = await model.setMissionSpeed(speed: model.missionSpeed.rawValue)
            }
        }
    }
}

#Preview {
    @StateObject var model = LssModel.preview
    
    return AccountView(model: model)
}
