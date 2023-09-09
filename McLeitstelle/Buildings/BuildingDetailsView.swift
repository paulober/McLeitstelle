//
//  BuildingDetailsView.swift
//  McLeitstelle
//
//  Created by Paul on 04.09.23.
//

import SwiftUI
import LssKit
import Combine
import MapKit
import Foundation

enum BuildingDetailsPage: String, Hashable, CaseIterable, Sendable {
    case vehicles, storage, extensions, specialisations, complex
}

struct BuildingDetailsView: View {
    @ObservedObject var model: LssModel
    @Binding var building: BuildingMarker
    @StateObject private var viewModel: BuildingDetailsViewModel = BuildingDetailsViewModel()
    
    @SceneStorage("buildingDetailsPage") private var page: BuildingDetailsPage = .vehicles
    
    var body: some View {
        #if os(iOS)
        ScrollView {
            leftColumnView
            
            rightColumnView
                .padding(.top)
        }
        .navigationTitle(building.name)
        .onAppear {
            viewModel.fetchBuildingVehicles(for: building.id)
        }
        .onDisappear {
            viewModel.cleanUp()
        }
        #else
        HStack {
            leftColumnView
                .padding(.leading)
                .padding(.vertical)
                .layoutPriority(1)
            
            rightColumnView
                .padding()
                .layoutPriority(2)
        }
        .navigationTitle(building.name)
        .onAppear {
            viewModel.fetchBuildingVehicles(for: building.id)
        }
        .onDisappear {
            viewModel.cleanUp()
        }
        #endif
    }
    
    @ViewBuilder
    var leftColumnView: some View {
        VStack(alignment: .leading) {
            let coordinates = CLLocationCoordinate2D(latitude: building.latitude, longitude: building.longitude)
            Map(bounds: .init(centerCoordinateBounds: MKCoordinateRegion(center: coordinates, span: MKCoordinateSpan(latitudeDelta: 8, longitudeDelta: 8))), interactionModes: .zoom) {
                if let url = URL(string: model.relativeLssURLString(path: building.icon)) {
                    Annotation(building.name, coordinate: coordinates) {
                        AsyncImage(url: url)
                    }
                } else {
                    Marker(building.name, coordinate: coordinates)
                        .tint(.yellow)
                }
            }
            #if os(iOS)
            .frame(minHeight: 220)
            .clipShape(RoundedRectangle(cornerSize: CGSize(width: 8, height: 8)))
            .padding()
            #else
            .frame(minWidth: 300, minHeight: 150)
            #endif
            .cornerRadius(8)
            .mapControlVisibility(.hidden)
            .mapStyle(.standard)
            
            Text("\(building.name)")
                .font(.title)
                #if os(iOS)
                .padding(.horizontal)
                #else
                .padding(.vertical)
                #endif
            
            List {
                #if os(iOS)
                if let level = building.level {
                    HStack {
                        Text("Level")
                        Spacer()
                        Text("\(level)")
                    }
                }
                if let buildingType = LssBuildingType(rawValue: building.buildingType) {
                    HStack {
                        Text("Type")
                        Spacer()
                        Text(buildingType.asGermanString())
                    }
                }
                HStack {
                    Text("Owner")
                    Spacer()
                    Text(building.buildingOwnerType.rawValue)
                }
                HStack {
                    Text("Personal")
                    Spacer()
                    Text("\(building.personalCount)")
                }
                #else
                Section {
                    if let level = building.level {
                        HStack {
                            Text("Level")
                            Spacer()
                            Text("\(level)")
                        }
                    }
                    if let buildingType = LssBuildingType(rawValue: building.buildingType) {
                        HStack {
                            Text("Type")
                            Spacer()
                            Text(buildingType.asGermanString())
                        }
                    }
                    HStack {
                        Text("Owner")
                        Spacer()
                        Text(building.buildingOwnerType.rawValue)
                    }
                    HStack {
                        Text("Personal")
                        Spacer()
                        Text("\(building.personalCount)")
                    }
                } header: {
                    Text("Details")
                }
                #endif
            }
            //.listStyle(.automatic)
            #if os(iOS)
            .frame(minHeight: 200)
            #endif
        }
    }
    
    @ViewBuilder
    var rightColumnView: some View {
        VStack {
            Picker("Page", selection: $page) {
                Label("Vehicles", systemImage: page == .vehicles ? "door.garage.open" :  "door.garage.closed")
                    .tag(BuildingDetailsPage.vehicles)
                
                Label("Storage", systemImage: "tray.2")
                    .tag(BuildingDetailsPage.storage)
                
                Label("Extensions", systemImage: "puzzlepiece.extension")
                    .tag(BuildingDetailsPage.extensions)
                
                Label("Specialisations", systemImage: "brain.head.profile")
                    .tag(BuildingDetailsPage.specialisations)
                
                Label("Complex", systemImage: "building.2.crop.circle")
                    .tag(BuildingDetailsPage.complex)
            }
            
            #if os(iOS)
            .pickerStyle(.palette)
            .padding(.horizontal)
            #else
            .pickerStyle(.segmented)
            .padding(.bottom, 10)
            #endif
            
            List {
                ForEach(viewModel.vehicles, id: \.id) { v in
                    Text("Vehicle: \(v.caption); FMS = \(v.fmsReal)")
                }
            }
            #if os(iOS)
            .frame(minHeight: 300)
            #endif
        }
    }
}

#Preview {
    @StateObject var model = LssModel.preview
    @State var building = BuildingMarker.preview
    
    return BuildingDetailsView(model: model, building: $building)
}
