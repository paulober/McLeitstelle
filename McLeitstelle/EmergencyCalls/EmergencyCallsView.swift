//
//  EmergencyCallsView.swift
//  McLeitstelle
//
//  Created by Paul on 31.08.23.
//

import SwiftUI
import LssKit

struct EmergencyCallsView: View {
    @ObservedObject var model: LssModel
    
    @State private var sortOrder = [KeyPathComparator(\MissionMarker.missionOwnerType, order: .forward)]
    @State private var searchText = ""
    @State private var ownerFilter: OwnerFilter = .user
    @State private var selection: Set<MissionMarker.ID> = []
    
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
    
    var missions: [MissionMarker] {
        model.missionMarkers.filter { mission in
            (ownerFilter == .all || (ownerFilter == .user
             ? mission.missionOwnerType == .user
             : mission.missionOwnerType == .alliance))
            && mission.matches(searchText: searchText)
        }
        .sorted(using: sortOrder)
    }
    
    var body: some View {
        ZStack {
            if displayAsList {
                list
            } else {
                EmergencyCallsTable(model: model, selection: $selection, searchText: $searchText, ownerFilter: $ownerFilter)
                    .tableStyle(.inset)
            }
        }
        .navigationTitle("Emergency Calls")
        .navigationDestination(for: MissionMarker.ID.self) { id in
            EmergencyCallDetailsView(model: model, mission: model.missionBinding(for: id))
        }
        .toolbar {
            toolbarButtons
        }
        .searchable(text: $searchText)
        .onChange(of: searchText, initial: false) {
            selection.removeAll()
        }
    }
    
    var list: some View {
        List {
            // TODO: sort in sections
            emergencyCallRows(missions)
            /*if let orders = orderSections[.placed] {
             Section("New") {
             orderRows(orders)
             }
             }
             
             if let orders = orderSections[.preparing] {
             Section("Preparing") {
             orderRows(orders)
             }
             }
             
             if let orders = orderSections[.ready] {
             Section("Ready") {
             orderRows(orders)
             }
             }
             
             if let orders = orderSections[.completed] {
             Section("Completed") {
             orderRows(orders)
             }
             }*/
        }
        .headerProminence(.increased)
    }
    
    func emergencyCallRows(_ missions: [MissionMarker]) -> some View {
        let userId = model.getUserID()
        
        return ForEach(missions) { mission in
            NavigationLink(value: mission.id) {
                EmergencyCallRow(missionMarker: mission, imageURL: URL(string: model.relativeLssURLString(path: "/images/\(mission.icon).png"))!)
                    .badge(model.radioMessages.filter { if let mId = $0.missionId { return mId == mission.id && $0.userId == userId && $0.fms == FMSStatus.sprechwunsch.rawValue } else { return false }}.count)
                    .badgeProminence(.increased)
                    .badge((mission.patientsCount ?? 0) + (mission.prisonersCount ?? 0))
                    
            }
        }
    }

    @ViewBuilder
    var toolbarButtons: some View {
        #if os(macOS)
        NavigationLink(value: selection.first) {
            Label("View Details", systemImage: "list.bullet.below.rectangle")
        }
        .disabled(selection.isEmpty)
        #endif
        
        Picker("Owner", selection: $ownerFilter) {
            Text("All").tag(OwnerFilter.all)
            Text("User").tag(OwnerFilter.user)
            Text("Alliance").tag(OwnerFilter.alliance)
        }
    }
}

#Preview {
    @StateObject var model = LssModel.preview
    
    return EmergencyCallsView(model: model)
}
