//
//  DetailColumn.swift
//  McLeitstelle
//
//  Created by Paul on 31.08.23.
//

import SwiftUI
import LssKit

struct DetailColumn: View {
    @Binding var selection: Panel?
    /// The app's model the superview must pass in
    @ObservedObject var model: LssModel
    
    var body: some View {
        switch selection {
        case .dashboard:
            #if os(iOS)
            DashboardView(model: model, navigationSelection: $selection)
            #else
            MassiveDashboardView(model: model, navigationSelection: $selection)
            #endif
        case .emergencyCalls:
            EmergencyCallsView(model: model)
        case .allianceChat:
            AllianceChatView(model: model)
        case .buildings:
            BuildingsView(model: model)
        case .vehicles:
            VehiclesView(model: model)
        case .alliance:
            AllianceView()
        case .finances:
            FinancesView(model: model)
        case .account:
            AccountView(model: model)
        case nil:
            Text("No page selected")
        }
    }
}

#Preview {
    @State var selection: Panel? = .dashboard
    @StateObject var model = LssModel.preview
    
    return DetailColumn(selection: $selection, model: model)
}
