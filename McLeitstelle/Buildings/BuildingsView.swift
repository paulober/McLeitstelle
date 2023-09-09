//
//  BuildingsView.swift
//  McLeitstelle
//
//  Created by Paul on 31.08.23.
//

import SwiftUI
import LssKit

struct BuildingsView: View {
    @ObservedObject var model: LssModel
    
    @State private var sortOrder = [KeyPathComparator(\BuildingMarker.id, order: .forward)]
    @State private var searchText = ""
    @State private var ownerFilter: OwnerFilter = .user
    @State private var selection: Set<BuildingMarker.ID> = []
    
    #if os(iOS)
    @Environment(\.horizontalSizeClass) private var sizeClass
    #endif
    
    var displayAsList: Bool {
    #if os(iOS)
        return sizeClass == .compact
    #else
        return false
    #endif
    }
    
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
        ZStack {
            if displayAsList {
                list
            } else {
                BuildingsTable(model: model, selection: $selection, searchText: $searchText, ownerFilter: $ownerFilter)
                    .tableStyle(.inset)
            }
        }
        .navigationTitle("Buildings")
        .navigationDestination(for: BuildingMarker.ID.self) { id in
            BuildingDetailsView(model: model, building: model.buildingBinding(for: id))
        }
        .toolbar {
            toolbarButtons
        }
        .searchable(text: $searchText)
    }
    
    var list: some View {
        List(buildings, id: \.id) { building in
            NavigationLink(value: building.id) {
                HStack {
                    Text(building.name)
                    Spacer()
                    Label("is Owner", systemImage: building.buildingOwnerType.iconSystemName)
                }
            }
        }
        .headerProminence(.increased)
    }
    
    @ViewBuilder
    var toolbarButtons: some View {
        if !displayAsList {
            NavigationLink(value: selection.first) {
                Label("View Details", systemImage: "list.bullet.below.rectangle")
            }
            .disabled(selection.isEmpty)
        }
        
        Picker("Owner", selection: $ownerFilter) {
            Text("All").tag(OwnerFilter.all)
            Text("User").tag(OwnerFilter.user)
            Text("Alliance").tag(OwnerFilter.alliance)
        }
        #if os(iOS)
        .pickerStyle(.segmented)
        #endif
    }
}

#Preview {
    @StateObject var model = LssModel.preview
    
    return BuildingsView(model: model)
}
