//
//  MassiveDashboardView.swift
//  McLeitstelle
//
//  Created by Paul on 11.10.23.
//

import Foundation
import SwiftUI
import LssKit
import MapKit


struct MassiveDashboardView: View {
    @ObservedObject var model: LssModel
    @Binding var navigationSelection: Panel?
    
    @State private var sortOrder = [KeyPathComparator(\RadioMessage.id, order: .forward)]
    @State private var selection: Set<RadioMessage.ID> = []
    @State private var mapMarkerFilter: MarkerFilter = .missions
    @State private var isRadioSheetPresented: Bool = false
    
    var missionMarkers: [MissionMarker] {
        model.missionMarkers.filter { (mission: MissionMarker) in
            (mapMarkerFilter == .all || mapMarkerFilter == .missions)
            && mission.missionOwnerType == .user
        }
    }
    
    var buildingMarkers: [BuildingMarker] {
        model.buildingMarkers.filter { (building: BuildingMarker) in
            (mapMarkerFilter == .all || mapMarkerFilter == .buildings)
            && building.buildingOwnerType == .user
        }
    }
    
    @ViewBuilder
    var body: some View {
        GeometryReader { metrics in
            HStack(spacing: 0) {
                NavigationStack {
                    ZStack(alignment: .leading) {
                        // left pane
                        VStack(alignment: .leading) {
                            Spacer()
                            
                            radioPane
                                .frame(minWidth: 100, maxWidth: 400, minHeight: 200, maxHeight: 500)
                                .background(.thinMaterial)
                                .clipShape(RoundedRectangle(cornerRadius: 5))
                                .padding()
                        }
                        .background(.clear)
                        .zIndex(1)
                        
                        // Map
                        Map {
                            ForEach(missionMarkers, id: \.id) { mission in
                                let coordinates = CLLocationCoordinate2D(latitude: mission.latitude, longitude: mission.longitude)
                                if let url = URL(string: model.relativeLssURLString(path: "/images/\(mission.icon).png")) {
                                    Annotation(mission.caption, coordinate: coordinates) {
                                        NavigationLink(value: mission.id as MissionMarker.ID) {
                                            AsyncImage(url: url)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                    .annotationTitles(.hidden)
                                } else {
                                    Marker(mission.caption, coordinate: coordinates)
                                        .tint(.red)
                                }
                            }
                            
                            ForEach(buildingMarkers, id: \.id) { building in
                                let coordinates = CLLocationCoordinate2D(latitude: building.latitude, longitude: building.longitude)
                                if let url = URL(string: model.relativeLssURLString(path: building.icon)) {
                                    Annotation(building.name, coordinate: coordinates) {
                                        AsyncImage(url: url)
                                    }
                                    .annotationTitles(.hidden)
                                } else {
                                    Marker(building.name, coordinate: coordinates)
                                        .tint(.blue)
                                }
                            }
                        }
                        .mapStyle(.standard)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .frame(width: metrics.size.width * 2/3)
                    .navigationDestination(for: MissionMarker.ID.self) { id in
                        EmergencyCallDetailsView(model: model, mission: model.missionBinding(for: id))
                    }
                    .zIndex(0)
                }
                
                // right pane
                rightPane
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
    
    @ViewBuilder
    var radioPane: some View {
        Table(selection: $selection, sortOrder: $sortOrder) {
            TableColumn("Sender", value: \.caption) { radioMessage in
                Text(radioMessage.caption)
                    .frame(alignment: .leading)
                    .layoutPriority(1)
            }
            
            TableColumn("Content", value: \.fmsText) { radioMessage in
                if radioMessage.fms == FMSStatus.sprechwunsch.rawValue {
                    Text(radioMessage.fmsText)
                        .font(.callout.italic())
                        .foregroundStyle(.red)
                } else {
                    Text(radioMessage.fmsText)
                        .foregroundStyle(.secondary)
                }
            }
            
            TableColumn("Mission", value: \.optionalMissionId) { radioMessage in
                if let missionId = radioMessage.missionId {
                    if model.missionMarkers.contains(where: { $0.id == missionId }) {
                        NavigationLink(value: missionId as MissionMarker.ID) {
                            Label("Goto Mission", systemImage: "number.square")
                        }
                    } else {
                        Text("[Completed]")
                    }
                } else {
                    Text("N/A")
                        #if os(macOS)
                        .foregroundStyle(.secondary)
                        #endif
                }
            }
        } rows: {
            Section {
                // TODO: maybe enable alliance FMS from the beginning and disable on close and only control this filter with the toggle button
                ForEach(model.radioMessages.filter { $0.userId == model.getUserID() } .sorted(using: sortOrder)) { radioMessage in
                        TableRow(radioMessage)
                }
            }
        }
        .tableStyle(.inset)
    }
    
    @ViewBuilder
    var rightPane: some View {
        VStack {
            // Picker
            
            List {
                ForEach(missionMarkers, id: \.id) { m in
                    MissionRow(model: model, mission: m)
                }
            }
            .background(.green)
        }
        .background(.red)
    }
}

#Preview {
    @StateObject var model = LssModel.preview
    
    return MassiveDashboardView(model: model, navigationSelection: .constant(.dashboard))
        .frame(minWidth: 900, minHeight: 700)
}
