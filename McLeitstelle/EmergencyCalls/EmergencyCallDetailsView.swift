//
//  Briefing.swift
//  McLeitstelle
//
//  Created by Paul on 02.09.23.
//

import SwiftUI
import LssKit

struct VehicleContainer: Identifiable {
    var id: Int {
        vehicle.id
    }
    let vehicle: LssVehicle
    let distanceInKm: Double
}

enum VehicleType: Int, CaseIterable, Identifiable {
    case lf = 0, dlk = 2, rw = 4, gwA = 5, rtw = 28, nef = 29, fuStW = 32, ktw = 38, gkw = 39, kdowLNA = 55, mlf = 89, all = -1
    var id: Self { self }
}

struct EmergencyCallDetailsView: View {
    @ObservedObject var model: LssModel
    @Binding var mission: MissionMarker
    
    var missionCord: Coordinate {
        return Coordinate(latitude: mission.latitude, longitude: mission.longitude)
    }
    
    @State private var sortOrder = [KeyPathComparator(\VehicleContainer.id, order: .forward)]
    @State private var selection: Set<VehicleContainer.ID> = []
    @State private var searchText: String = ""
    @State private var vehicleTypeFilter: VehicleType = .all
    @State private var liveMissionDetails: LiveMissionDetails = LiveMissionDetails()
    
    var vehicles: [VehicleContainer] {
        model.vehicles.filter { v in
            (vehicleTypeFilter == .all || v.vehicleType == vehicleTypeFilter.rawValue) && v.matches(searchText: searchText)
        }
        .map {
            if $0.fmsReal == 2 {
                let bId = $0.buildingId
                if let building = model.buildingMarkers.first(where: { $0.id == bId } ) {
                    return VehicleContainer(
                        vehicle: $0,
                        distanceInKm: Coordinate(latitude: building.latitude, longitude: building.longitude).distance(to: missionCord)
                    )
                }
            } else if $0.fmsReal == 4,
                      let mId = $0.targetId {
                
                if let mission = model.missionMarkers.first(where: { $0.id == mId } ) {
                    return VehicleContainer(
                        vehicle: $0,
                        distanceInKm: Coordinate(latitude: mission.latitude, longitude: mission.longitude).distance(to: missionCord)
                    )
                }
            }
            return VehicleContainer(vehicle: $0, distanceInKm: 0)
        }
        .sorted(using: sortOrder)
    }
    
    var body: some View {
        VStack {
            Text(mission.missingText ?? "")
            
            Grid(horizontalSpacing: 5) {
                GridRow {
                    VStack {
                        List {
                            ForEach(liveMissionDetails.vehiclesAtIds, id: \.self) { vehicleId in
                                Text("\(liveMissionDetails.vehicleNames[vehicleId] ?? "N/A")")
                            }
                        }.task {
                            // TODO: move into LssModel
                            let liveDetails = await scanMissionHTML(csrfToken: model.getCsrfToken() ?? "", missionId: String(mission.id))
                            DispatchQueue.main.async {
                                liveMissionDetails = liveDetails
                            }
                        }
                    }
                    .layoutPriority(1)
                    
                    VStack {
                        Table(selection: $selection, sortOrder: $sortOrder) {
                            TableColumn("Name", value: \.vehicle.caption) { v in
                                Text(v.vehicle.caption)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .layoutPriority(1)
                            }
                            
                            TableColumn("FMS", value: \.vehicle.fmsReal) { v in
                                Text(v.vehicle.fmsReal.formatted())
                                    #if os(macOS)
                                    .foregroundStyle(.secondary)
                                    #endif
                            }
                            
                            TableColumn("Distance (km)", value: \.distanceInKm) { v in
                                Text("\(String(format: "%.2f", v.distanceInKm)) km")
                                    #if os(macOS)
                                    .foregroundStyle(.secondary)
                                    #endif
                            }
                            
                            TableColumn("Type", value: \.vehicle.vehicleType) { v in
                                Text(v.vehicle.vehicleTypeCaption ?? "N/A")
                                    #if os(macOS)
                                    .foregroundStyle(.secondary)
                                    #endif
                            }
                        } rows: {
                            Section {
                                ForEach(vehicles) { vehicle in
                                    TableRow(vehicle)
                                }
                            }
                        }
                    }
                    .layoutPriority(2)
                }
            }
        }
        .navigationTitle(mission.caption)
        .toolbar {
            toolbarButtons
        }
        .searchable(text: $searchText)
    }
    
    @ViewBuilder
    var toolbarButtons: some View {
        Button {
            Task {
                if selection.count > 0 {
                    let result = await model.missionAlarm(missionId: mission.id, vehicleIds: selection)
                    print("Alarmed with status: \(result)")
                    if result {
                        for v in selection {
                            if let idx = model.vehicles.firstIndex(where: { $0.id == v }) {
                                DispatchQueue.main.async {
                                    model.vehicles[idx].fmsReal = 4
                                }
                            }
                        }
                    }
                }
            }
        } label: {
            Label("Alarm", systemImage: "bell.and.waves.left.and.right")
        }
        
        Picker("Typ", selection: $vehicleTypeFilter) {
            Text("All").tag(VehicleType.all)
            Text("LF (FW)").tag(VehicleType.lf)
            Text("DLK (FW)").tag(VehicleType.dlk)
            Text("RW (FW)").tag(VehicleType.rw)
            Text("GW-A (FW)").tag(VehicleType.gwA)
            Text("MLF (RD)").tag(VehicleType.mlf)
            
            // RD
            Text("RTW (RD)").tag(VehicleType.rtw)
            Text("NEF (RD)").tag(VehicleType.nef)
            Text("KTW (RD)").tag(VehicleType.ktw)
            Text("Kdow-LNA (RD)").tag(VehicleType.kdowLNA)
            
            // POL
            Text("FuStW (POL)").tag(VehicleType.fuStW)
            
            // THW
            Text("GKW (THW)").tag(VehicleType.gkw)
        }
    }
}



#Preview {
    @StateObject var model = LssModel.preview
    @State var mission = MissionMarker.preview
    
    return NavigationStack {
        EmergencyCallDetailsView(model: model, mission: $mission)
    }
}
