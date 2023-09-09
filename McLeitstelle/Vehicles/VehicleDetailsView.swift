//
//  VehicleDetailsView.swift
//  McLeitstelle
//
//  Created by Paul on 05.09.23.
//

import SwiftUI
import LssKit

struct VehicleDetailsView: View {
    @ObservedObject var model: LssModel
    @Binding var vehicle: LssVehicle
    
    var body: some View {
        Text(vehicle.caption)
    }
}

#Preview {
    @StateObject var model = LssModel.preview
    @State var vehicle = LssVehicle.preview
    
    return NavigationStack {
        VehicleDetailsView(model: model, vehicle: $vehicle)
    }
}
