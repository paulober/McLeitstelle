//
//  Sidebar.swift
//  McLeistelle
//
//  Created by Paul on 31.08.23.
//

import SwiftUI
import LssKit

enum Panel: Hashable {
    /// The value for the ``DashboardView``
    case dashboard
    /// The value for the ``EmergencyCallsView``
    case emergencyCalls
    /// The value for the ``AllianceChatView``
    case allianceChat
    /// The value for the ``BuildingsView``
    case buildings
    /// The value for the ``VehiclesView``
    case vehicles
    /// The value for the ``AllianceView``
    case alliance
    /// The value for the ``FinancesView``
    case finances
    /// The value for the ``AccountView``
    case account
}


struct Sidebar: View {
    @ObservedObject var model: LssModel
    
    /// The user's selection in the sidebar
    ///
    /// This value is a binding, and the vsuperview must pass in its value.
    @Binding var selection: Panel?
    
    var body: some View {
        List(selection: $selection) {
            NavigationLink(value: Panel.dashboard) {
                Label("Dashboard", systemImage: "magnifyingglass")
            }
            .badge(model.radioMessages.filter { $0.userId == model.getUserID() && $0.fms == FMSStatus.sprechwunsch.rawValue }.count)
            
            NavigationLink(value: Panel.emergencyCalls) {
                Label("Emergency Calls", systemImage: "phone.down.waves.left.and.right")
            }
            
            NavigationLink(value: Panel.allianceChat) {
                Label("Alliance Chat", systemImage: "bubble.left")
            }
            
            Section("Assets") {
                NavigationLink(value: Panel.buildings) {
                    Label("Buildings", systemImage: "building.2")
                }
                
                NavigationLink(value: Panel.vehicles) {
                    Label("Vehicles", systemImage: "car")
                }
            }
            
            Section("Management") {
                NavigationLink(value: Panel.alliance) {
                    Label("Alliance", systemImage: "person.2")
                }
                
                NavigationLink(value: Panel.finances) {
                    // or bank symbol / library
                    Label("Finances", systemImage: "chart.line.uptrend.xyaxis")
                }
            }
            
            #if os(macOS)
            Spacer()
            #endif
            
            #if os(iOS)
            Section {
                Label("\(model.credits.creditsUserCurrent.formatted())", systemImage: "eurosign.circle")
                    .monospacedDigit()
                
                NavigationLink(value: Panel.account) {
                    Label(model.getUsername() ?? "Account", systemImage: "person.crop.circle")
                }
            } header: {
                Text("Settings")
            }
            #else
            Section {
                Label("\(model.credits.creditsUserCurrent.formatted())", systemImage: "eurosign.circle")
                    .monospacedDigit()
                
                NavigationLink(value: Panel.account) {
                    Label(model.getUsername() ?? "Account", systemImage: "person.crop.circle")
                }
            }
            #endif
        }
        .navigationTitle("McLeitstelle")
        #if os(macOS)
        .navigationSplitViewColumnWidth(min: 180, ideal: 200)
        #endif
    }
}

#Preview {
    @State var selection: Panel? = Panel.dashboard
    @StateObject var model = LssModel.preview
    
    return NavigationSplitView {
        Sidebar(model: model, selection: $selection)
    } detail: {
        Text("Detail!")
    }
}
