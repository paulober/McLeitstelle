//
//  VehiclesView.swift
//  McLeitstelle
//
//  Created by Paul on 31.08.23.
//

import SwiftUI
import LssKit

struct VehiclesView: View {
    @ObservedObject var model: LssModel
    
    @State private var sortOrder = [KeyPathComparator(\LssVehicle.id, order: .forward)]
    @State private var searchText = ""
    @State private var vehicleTypeFilter: VehicleType = .all
    @State private var selection: Set<LssVehicle.ID> = []
    
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
    
    var vehicles: [LssVehicle] {
        model.vehicles.filter { (vehicle: LssVehicle) in
            (vehicleTypeFilter == .all || vehicle.vehicleType == vehicleTypeFilter.rawValue)
            && vehicle.matches(searchText: searchText)
        }
        .sorted(using: sortOrder)
    }
    
    var body: some View {
        ZStack {
            if displayAsList {
                list
            } else {
                VehiclesTable(model: model, selection: $selection, searchText: $searchText, vehicleTypeFilter: $vehicleTypeFilter)
                    .tableStyle(.inset)
            }
        }
        .navigationTitle("Vehicles")
        .navigationDestination(for: LssVehicle.ID.self) { id in
            VehicleDetailsView(model: model, vehicle: model.lssVehicleBinding(for: id))
        }
        .toolbar {
            toolbarButtons
        }
        .searchable(text: $searchText)
    }
    
    var list: some View {
        List {
            ForEach(vehicles, id: \.id) { vehicle in
                Text(vehicle.caption)
            }
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
    
    @ViewBuilder
    var toolbarButtons: some View {
        Picker("Type", selection: $vehicleTypeFilter) {
            Text("All").tag(VehicleType.all)
            
            // FD
            Section {
                Text("LF (FW)").tag(VehicleType.lf20)
                Text("DLK (FW)").tag(VehicleType.dlk)
                Text("RW (FW)").tag(VehicleType.rw)
                Text("GW-A (FW)").tag(VehicleType.gwA)
                Text("MLF (RD)").tag(VehicleType.mlf)
            } header: {
                Text("FD")
            }
            
            // RD
            Section {
                Text("RTW (RD)").tag(VehicleType.rtw)
                Text("NEF (RD)").tag(VehicleType.nef)
                Text("KTW (RD)").tag(VehicleType.ktw)
                Text("Kdow-LNA (RD)").tag(VehicleType.kdowLNA)
            } header: {
                Text("RD")
            }
            
            // POL
            Section {
                Text("FuStW (POL)").tag(VehicleType.fuStW)
            } header: {
                Text("Bundespolizei")
            }
            
            // THW
            Section {
                Text("GKW (THW)").tag(VehicleType.gkw)
            } header: {
                Text("THW")
            }
        }
    }
}

#Preview {
    @StateObject var model = LssModel.preview
    
    return VehiclesView(model: model)
}
