//
//  EmergencyCallsTable.swift
//  McLeitstelle
//
//  Created by Paul on 02.09.23.
//

import SwiftUI
import LssKit

struct EmergencyCallsTable: View {
    @ObservedObject var model: LssModel
    @State private var sortOrder = [KeyPathComparator(\MissionMarker.missionOwnerType, order: .forward)]
    @Binding var selection: Set<MissionMarker.ID>
    @Binding var searchText: String
    @Binding var ownerFilter: OwnerFilter
    
    /*
    var missions: [MissionMarker] {
     model.missionMarkers.filter { mission in
         (ownerFilter == .all || (ownerFilter == .user
          ? mission.missionOwnerType == .user
          : mission.missionOwnerType == .alliance))
         && mission.matches(searchText: searchText)
     }
     .sorted(using: sortOrder)
    }*/
    
    var body: some View {
        Table(selection: $selection, sortOrder: $sortOrder) {
            TableColumn("Mission") { (mission: MissionMarker) in                
                EmergencyCallRow(missionMarker: mission, imageURL: URL(string: model.relativeLssURLString(path: "/images/\(mission.icon).png"))!)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .layoutPriority(1)
            }
            
            TableColumn("Owner", value: \.missionOwnerType) { mission in
                mission.missionOwnerType.label
                    #if os(macOS)
                    .foregroundStyle(.secondary)
                    #endif
                    .layoutPriority(0)
            }
            
            TableColumn("Missing") { (mission: MissionMarker) in
                Text(mission.missingText ?? "N/A")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        } rows: {
            Section {
                ForEach(model.missionMarkers.filter { mission in
                    (ownerFilter == .all || (ownerFilter == .user
                     ? mission.missionOwnerType == .user
                     : mission.missionOwnerType == .alliance))
                    && mission.matches(searchText: searchText)
                }
                .sorted(using: sortOrder)) { mission in
                    TableRow(mission)
                }
            }
        }
    }
}

#Preview {
    @State var sortOrder = [KeyPathComparator(\MissionMarker.dateNow, order: .forward)]
    @StateObject var model = LssModel.preview
    
    return EmergencyCallsTable(
        model: model,
        selection: .constant([]),
        searchText: .constant(""),
        ownerFilter: .constant(.all)
    )
}
