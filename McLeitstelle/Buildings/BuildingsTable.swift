//
//  BuildingsTable.swift
//  McLeitstelle
//
//  Created by Paul on 03.09.23.
//

import SwiftUI
import LssKit

struct BuildingsTable: View {
    @ObservedObject var model: LssModel
    @State private var sortOrder = [KeyPathComparator(\BuildingMarker.id, order: .forward)]
    @Binding var selection: Set<BuildingMarker.ID>
    @Binding var searchText: String
    @Binding var ownerFilter: OwnerFilter
    
    var buildings: [BuildingMarker] {
        model.buildingMarkers.filter { (building: BuildingMarker) in
            (ownerFilter == .all || (ownerFilter == .user
             ? building.buildingOwnerType == .user
             : building.buildingOwnerType == .alliance))
            && building.matches(searchText: searchText)
        }
        .sorted(using: sortOrder)
    }
    
    var body: some View {
        Table(selection: $selection, sortOrder: $sortOrder) {
            TableColumn("Name") { (building: BuildingMarker) in
                Text(building.name)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .layoutPriority(1)
            }
            
            TableColumn("Personal", value: \.personalCount) { building in
                Text(building.personalCount.formatted())
                    .monospacedDigit()
                    #if os(macOS)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .foregroundStyle(.secondary)
                    #endif
            }
            
            TableColumn("Type", value: \.buildingType) { building in
                Text(building.buildingTypeString)
                    #if os(macOS)
                    .foregroundStyle(.secondary)
                    #endif
            }
            
            TableColumn("Owner", value: \.buildingOwnerType) { building in
                building.buildingOwnerType.label
                    #if os(macOS)
                    .foregroundStyle(.secondary)
                    #endif
            }
        } rows: {
            Section {
                ForEach(buildings) { building in
                    TableRow(building)
                }
            }
        }
    }
}

#Preview {
    @State var sortOrder = [KeyPathComparator(\BuildingMarker.id, order: .forward)]
    @StateObject var model = LssModel.preview
    
    return BuildingsTable(
        model: model,
        selection: .constant([]),
        searchText: .constant(""),
        ownerFilter: .constant(.all)
    )
}
