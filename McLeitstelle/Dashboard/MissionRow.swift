//
//  MissionRow.swift
//  McLeitstelle
//
//  Created by Paul on 11.10.23.
//

import SwiftUI
import LssKit

struct MissionRow: View {
    @ObservedObject var model: LssModel
    @State var mission: MissionMarker
    @State private var missionUnitsRequirement: MissionUinitsRequirement?
    
    @ViewBuilder
    var body: some View {
        HStack {
            if let url = URL(string: model.relativeLssURLString(path: "/images/\(mission.icon).png")) {
                AsyncImage(url: url)
                    .scaledToFit()
            } else {
                Text("Unable to load icon")
            }
            
            VStack(alignment: .leading) {
                Text(mission.caption)
                    .font(.headline)
                    .padding(.leading)
                    .padding(.top)
                
                HStack {
                    NavigationLink(value: mission.id) {
                        Text("Details")
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    
                    Spacer()
                    
                    Button {
                        if let unitReq = missionUnitsRequirement {
                            Task {
                                _ = await model.autoAlarm(mid: mission.id, caption: mission.caption, unitRequirements: unitReq)
                            }
                        }
                    } label: {
                        Label("Auto-Alarm", systemImage: "clock")
                            .foregroundStyle(model.areEnoughVehiclesForMission(mid: mission.id, unitRequirements: missionUnitsRequirement) ? Color.green : Color.red)
                    }
                }
                .padding()
            }
        }
        .frame(height: 80)
        .clipShape(RoundedRectangle(cornerRadius: 4))
        .task {
            await getMissionDetails()
        }
    }
    
    func getMissionDetails() async {
        let result = await scanMissionEinsatzHTML(csrfToken: model.getCsrfToken() ?? "", missionTypeId: mission.missionTypeId ?? 0, missionId: mission.id)
        
        DispatchQueue.main.async {
            missionUnitsRequirement = result.scan()
        }
    }
}

#Preview {
    @StateObject var model = LssModel.preview
    @State var marker = MissionMarker.preview
    
    return NavigationStack {
        MissionRow(model: model, mission: marker)
    }
}
