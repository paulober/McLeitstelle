//
//  VehiclesTable.swift
//  McLeitstelle
//
//  Created by Paul on 05.09.23.
//

import SwiftUI
import LssKit

struct VehiclesTable: View {
    @ObservedObject var model: LssModel
    @State private var sortOrder = [KeyPathComparator(\LssVehicle.id, order: .forward)]
    @Binding var selection: Set<LssVehicle.ID>
    @Binding var searchText: String
    @Binding var vehicleTypeFilter: VehicleType
    
    var vehicles: [LssVehicle] {
        model.vehicles.filter { (vehicle: LssVehicle) in
            (vehicleTypeFilter == .all || vehicle.vehicleType == vehicleTypeFilter.rawValue)
            && vehicle.matches(searchText: searchText)
        }
        .sorted(using: sortOrder)
    }
    
    var body: some View {
        Table(selection: $selection, sortOrder: $sortOrder) {
            TableColumn("Name") { (vehicle: LssVehicle) in
                Text(vehicle.caption)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .layoutPriority(1)
            }
            
            TableColumn("Assigned Personal Count", value: \.assignedPersonnelCount) { vehicle in
                Text(vehicle.assignedPersonnelCount.formatted())
                    .monospacedDigit()
                    #if os(macOS)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .foregroundStyle(.secondary)
                    #endif
            }
            
            TableColumn("Type", value: \.vehicleType) { vehicle in
                Text(vehicle.vehicleTypeCaption ?? "N/A")
                    #if os(macOS)
                    .foregroundStyle(.secondary)
                    #endif
            }
            
            TableColumn("FMS", value: \.fmsReal) { vehicle in
                Text(vehicle.fmsReal.formatted())
                    .monospacedDigit()
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
}

#Preview {
    @State var sortOrder = [KeyPathComparator(\LssVehicle.id, order: .forward)]
    @StateObject var model = LssModel.preview
    
    return VehiclesTable(
        model: model,
        selection: .constant([]),
        searchText: .constant(""),
        vehicleTypeFilter: .constant(.all)
    )
}
