//
//  DashboardView.swift
//  McLeitstelle
//
//  Created by Paul on 31.08.23.
//

import SwiftUI
import LssKit
import MapKit

struct DashboardView: View {
    @ObservedObject var model: LssModel
    @Binding var navigationSelection: Panel?
    @State private var sortOrder = [KeyPathComparator(\RadioMessage.id, order: .forward)]
    @State private var selection: Set<RadioMessage.ID> = []
    @State private var enableAllianceFMS: Bool = false
    @State private var isRadioSheetPresented: Bool = false
    
    @State private var mapMarkerFilter: MarkerFilter = .all
    
    #if os(iOS)
    @Environment(\.horizontalSizeClass) private var sizeClass
    #endif
    
    var body: some View {
        GeometryReader { metrics in
            #if os(iOS)
            VStack(spacing: 0) {
                // TODO: toolbar spliting is only possible at the root of the NavigationSplitView or with the content, detail parameters of it
                mapView
                    .frame(maxHeight: .infinity)
                    #if os(iOS)
                    .ignoresSafeArea(edges: [.horizontal])
                    #else
                    .ignoresSafeArea(edges: [.bottom, .horizontal])
                    #endif
                
                // TODO: put as list with a toolbar or overlay button as sheet maybe so full screen map
                /*theTable
                    .overlay(
                        Rectangle()
                            .frame(width: 2, height: nil, alignment: .leading)
                            .foregroundColor(Color.gray.opacity(0.5)),
                        alignment: .leading
                    )
                    .toolbar {
                        ToolbarItem {
                            Toggle("Alliance FMS", isOn: $enableAllianceFMS)
                                .toggleStyle(ButtonToggleStyle())
                                .padding(.leading, metrics.size.width * 1/3 - 100)
                        }
                    }*/
            }
            #else
            HStack(spacing: 0) {
                // TODO: toolbar spliting is only possible at the root of the NavigationSplitView or with the content, detail parameters of it
                mapView
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .frame(width: metrics.size.width * 2/3)
                    /*.toolbar {
                        ToolbarItem {
                            Picker("View", selection: $mapMarkerFilter) {
                                Text("All").tag(MarkerFilter.all)
                                Text("Missions").tag(MarkerFilter.missions)
                                Text("Buildings").tag(MarkerFilter.buildings)
                            }
                            .pickerStyle(.segmented)
                        }
                    }*/
                
                theTable
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .overlay(
                        Rectangle()
                            .frame(width: 2, height: nil, alignment: .leading)
                            .foregroundColor(Color.gray.opacity(0.5)),
                        alignment: .leading
                    )
                    .toolbar {
                        ToolbarItem {
                            Toggle("Alliance FMS", isOn: $enableAllianceFMS)
                                .toggleStyle(ButtonToggleStyle())
                                .padding(.leading, metrics.size.width * 1/3 - 100)
                        }
                    }
            }
            #endif
                
        }
        .navigationTitle("Dashboard")
        .navigationDestination(for: MissionMarker.ID.self) { id in
            EmergencyCallDetailsView(model: model, mission: model.missionBinding(for: id))
        }
        .toolbar {
            ToolbarItem {
                Picker("View", selection: $mapMarkerFilter) {
                    Text("All").tag(MarkerFilter.all)
                    Text("Missions").tag(MarkerFilter.missions)
                    Text("Buildings").tag(MarkerFilter.buildings)
                }
                .pickerStyle(.segmented)
            }
            
            #if os(iOS)
            ToolbarItem(placement: .bottomBar) {
                Button {
                    isRadioSheetPresented = true
                } label: {
                    Label("Radio", systemImage: "phone.arrow.down.left")
                        .symbolRenderingMode(.hierarchical)
                }
            }
            #endif
        }
        .onChange(of: enableAllianceFMS, initial: false) {
            Task {
                await model.enableAllianceFMS(on: enableAllianceFMS)
            }
        }
        .sheet(isPresented: $isRadioSheetPresented) {
            theList
        }
    }
    
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
    var mapView: some View {
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
    
    @ViewBuilder
    var theTable: some View {
        Table(selection: $selection, sortOrder: $sortOrder) {
            TableColumn("Sender", value: \.caption) { radioMessage in
                Text(radioMessage.caption)
                    .frame(alignment: .leading)
                    .layoutPriority(1)
            }
            
            TableColumn("Content", value: \.fmsText) { radioMessage in
                Text(radioMessage.fmsText)
                    #if os(macOS)
                    .foregroundStyle(.secondary)
                    #endif
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
                ForEach(model.radioMessages.filter { enableAllianceFMS || $0.userId == model.getUserID() } .sorted(using: sortOrder)) { radioMessage in
                        TableRow(radioMessage)
                }
            }
        }
        .tableStyle(.inset)
    }
    
    @ViewBuilder
    var theList: some View {
        VStack {
            HStack {
                Spacer()
                
                Button {
                    isRadioSheetPresented = false
                } label: {
                    Text("Dismiss")
                }
            }
            .frame(alignment: .topTrailing)
            .padding(.vertical)
            .padding(.trailing)
            
            NavigationStack {
                List(model.radioMessages.filter { enableAllianceFMS || $0.userId == model.getUserID() }, id: \.id) { message in
                    
                    if let missionId = message.missionId, model.missionMarkers.contains(where: { $0.id == missionId }) {
                        NavigationLink(value: missionId as MissionMarker.ID) {
                            RadioMessageRow(message: message)
                        }
                    } else {
                        RadioMessageRow(message: message)
                    }
                }
                .navigationDestination(for: MissionMarker.ID.self) { id in
                    EmergencyCallDetailsView(model: model, mission: model.missionBinding(for: id))
                }
            }
        }
    }
}


#Preview {
    @StateObject var model = LssModel.preview
    @State var navigationSelection: Panel? = Panel.dashboard
    
    return DashboardView(model: model, navigationSelection: $navigationSelection)
}
