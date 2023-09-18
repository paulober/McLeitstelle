//
//  Briefing.swift
//  McLeitstelle
//
//  Created by Paul on 02.09.23.
//

import SwiftUI
import LssKit
import MapKit

struct VehicleContainer: Identifiable {
    var id: Int {
        vehicle.id
    }
    let vehicle: LssVehicle
    let distanceInKm: Double
}

struct EmergencyCallDetailsView: View {
    @ObservedObject var model: LssModel
    @Binding var mission: MissionMarker
    @Environment(\.dismiss) var dismissAction
    
    var missionCord: Coordinate {
        return Coordinate(latitude: mission.latitude, longitude: mission.longitude)
    }
    
    var missionLoc: CLLocation {
        return CLLocation(latitude: mission.latitude, longitude: mission.longitude)
    }
    
    var staticMissionDetails: LssMission? {
        if let missionTypeId = mission.missionTypeId {
            return model.getStaticMissionDetails(mtId: missionTypeId)
        }
        return nil
    }
    
    @State private var sortOrder = [KeyPathComparator(\VehicleContainer.distanceInKm, order: .forward)]
    @State private var selection: Set<VehicleContainer.ID> = []
    @State private var searchText: String = ""
    @State private var vehicleTypeFilter: VehicleType = .all
    @State private var vehicleCategoryFilter: VehicleCategory = .all
    @State private var liveMissionDetails: LiveMissionDetails?
    @State private var rtwTransportDetails: RtwTransportDetails?
    @State private var prisonerTransportVehicleId: Int?
    @State private var showMissionDetailsSheet: Bool = false
    
    @State private var showRtwTransportDialog: Bool = false
    @State private var showMassPatientManagementSheet: Bool = false
    
    @State private var showPrisonerTransportDialog: Bool = false
    @State private var showPrisonerManagementSheet: Bool = false
    
    @State private var einsatzDetails: MissionEinsatzDetails?
    @State private var isAdditionalDetailsExpanded: Bool = false
    
    var vehicles: [VehicleContainer] {
        model.vehicles.filter { v in
            ((vehicleTypeFilter == .all && (vehicleCategoryFilter == .all || vehicleCategoryFilter == .onMission))
             // TODO: unexpectely found nil
             || (vehicleTypeFilter == .all && isVehicleTypeInCategory(v.vehicleType, category: vehicleCategoryFilter))
             || (vehicleTypeFilter.rawValue == v.vehicleType)
            )
            && v.matches(searchText: searchText)
        }
        .compactMap {
            if $0.fmsReal == 2 && vehicleCategoryFilter != .onMission {
                let bId = $0.buildingId
                if let building = model.buildingMarkers.first(where: { $0.id == bId } ) {
                    return VehicleContainer(
                        vehicle: $0,
                        distanceInKm: Coordinate(latitude: building.latitude, longitude: building.longitude).distance(to: missionCord)
                        // mine is more precise and what the Lss website displays
                        //distanceInKm: missionLoc.distance(from: CLLocation(latitude: building.latitude, longitude: building.longitude)) / 1000
                    )
                }
            } // TODO: das bedeutet weiter allarmieren (todo anzeigen das weiteralarmieren)
            else if $0.fmsReal == 4 && vehicleCategoryFilter == .onMission,
                      let mId = $0.targetId {
                
                if let mission = model.missionMarkers.first(where: { $0.id == mId } ) {
                    return VehicleContainer(
                        vehicle: $0,
                        distanceInKm: Coordinate(latitude: mission.latitude, longitude: mission.longitude).distance(to: missionCord)
                        // mine is more precise and what the Lss website displays
                        //distanceInKm: missionLoc.distance(from: CLLocation(latitude: mission.latitude, longitude: mission.longitude)) / 1000
                    )
                }
            }
            
            return nil
        }
        .sorted(using: sortOrder)
    }
    
    /*func calculateDrivingTime(vehicleId: Int, from sourceLoc: CLLocation, to destinationLoc: CLLocation) {
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: sourceLoc.coordinate))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destinationLoc.coordinate))
        request.transportType = .automobile
        
        let directions = MKDirections(request: request)
        directions.calculate { (response, error) in
            guard let route = response?.routes.first else {
                // handle error route not found
                return
            }
            
            let travelTimeInMinutes = route.expectedTravelTime / 60
            
            // TODO: return
        }
    }*/
    
    func getVehiclesInMotion() async {
        let result = await scanMissionHTML(csrfToken: model.getCsrfToken() ?? "", missionId: String(mission.id))
        
        DispatchQueue.main.async {
            liveMissionDetails = result
        }
    }
    
    func getEinsatzDetails() async {
        let result = await scanMissionEinsatzHTML(csrfToken: model.getCsrfToken() ?? "", missionTypeId: mission.missionTypeId ?? 0, missionId: mission.id)
        
        DispatchQueue.main.async {
            einsatzDetails = result
        }
    }
    
    var patientMarkers: [PatientMarker] {
        model.patientMarkers.filter { $0.missionId == mission.id }
    }
    
    // TODO: should only be 0 or 1 length
    var combinedPatientMarkers: [CombinedPatientMarker] {
        model.combinedPatientMarkers.filter { $0.missionId == mission.id }
    }
    
    private func updateStaticDetails() {
        let startTime = Date()
        Task {
            await getEinsatzDetails()
            await getVehiclesInMotion()
            
            let endTime = Date()
            let formattedElapsedTime = String(format: "%.2f", endTime.timeIntervalSince(startTime)*1000)
            print("[EmergencyCallDetailsView] Loaded html stuff in: \(formattedElapsedTime)ms")
        }
    }
    
    
    var body: some View {
        VStack {
            if let missingText = mission.missingText {
                Text(missingText)
                    .multilineTextAlignment(.leading)
                    .padding(.vertical, 2)
                    .padding(.horizontal)
            }
            
            #if os(iOS)
            assetsListView
                .environment(\.editMode, .constant(.active))
                .padding(.bottom, 2)
            
            Spacer()
            
            if patientMarkers.count > 0 {
                patientsView
                    .padding(.horizontal)
            } else if combinedPatientMarkers.count > 0 {
                combinedPatientsView
                    .padding(.horizontal)
            }
            #endif
            
            // TODO: better cross-platform structuring
            // TODO: put on sheet for iOS
            #if os(macOS)
            HStack(spacing: 5) {
                missionDetailsView
                .frame(minWidth: 400, maxWidth: 800)
                
                VStack {
                    assetsTableView
                }
                .layoutPriority(2)
                
            }
            .onAppear {
                updateStaticDetails()
            }
            #endif
        }
        .background(Color.gray.opacity(0.1).edgesIgnoringSafeArea(.all))
        .navigationTitle(mission.caption)
        .toolbar {
            toolbarButtons
        }
        .searchable(text: $searchText)
        .onChange(of: vehicleCategoryFilter, initial: false) {
            selection.removeAll()
            vehicleTypeFilter = .all
        }
        .onChange(of: vehicleTypeFilter, initial: false) {
            selection.removeAll()
        }
        #if os(iOS)
        // can't be loaded on missionDetailView sheet appear because rtwTransportSheet
        // needs this data or does not open
        .onAppear {
            updateStaticDetails()
        }
        #endif
        .sheet(isPresented: $showRtwTransportDialog) {
            rtwTransportSheet
        }
        .sheet(isPresented: $showPrisonerTransportDialog) {
            prisonerTransportSheet
        }
        .sheet(isPresented: $showMissionDetailsSheet) {
            missionDetailsView
        }
        .sheet(isPresented: $showMassPatientManagementSheet) {
            massPatientManagementView
        }
        .sheet(isPresented: $showPrisonerManagementSheet) {
            prisonerManagementSheet
        }
    }
    
    @ViewBuilder
    var missionDetailsView: some View {
        #if os(iOS)
        HStack {
            Spacer()
            Button {
                showMissionDetailsSheet = false
            } label: {
                Text("Close")
            }
            .buttonStyle(.borderedProminent)
            #if os(iOS)
            .padding(.top)
            .padding(.trailing)
            #endif
        }
        #endif
        
        VStack {
            #if os(macOS)
            if patientMarkers.count > 0 {
                patientsView
            }
            #endif
            
            List {
                einsatzDetailsView
                
                if let liveMissionDetails = liveMissionDetails {
                    if liveMissionDetails.vehiclesDrivingIds.count > 0 {
                        Section {
                            ForEach(liveMissionDetails.vehiclesDrivingIds, id: \.self) { vehicleId in
                                Text("\(liveMissionDetails.vehicleNames[vehicleId] ?? "N/A") by \(liveMissionDetails.vehicleOwners[vehicleId] ?? "N/A")")
                            }
                        } header: {
                            Text("Vehicles on their way")
                        }
                    }
                    
                    if liveMissionDetails.vehiclesAtIds.count > 0 {
                        Section {
                            ForEach(liveMissionDetails.vehiclesAtIds, id: \.self) { vehicleId in
                                Text("\(liveMissionDetails.vehicleNames[vehicleId] ?? "N/A") by \(liveMissionDetails.vehicleOwners[vehicleId] ?? "N/A")")
                            }
                        } header: {
                            Text("Vehicles at location")
                        }
                    } else {
                        Text("No vehicles at location")
                    }
                } else {
                    Text("Loading...")
                }
            }
            #if os(macOS)
            .layoutPriority(2)
            .listStyle(.sidebar)
            #endif
        }
    }
    
    @ViewBuilder
    var combinedPatientsView: some View {
        ForEach(combinedPatientMarkers, id: \.hashValue) { marker in
            VStack {
                ForEach(Array(marker.errors), id: \.key) { error, count in
                    Text("\(error): \(count)x")
                }
            }
        }
    }
    
    // TODO: make better!!
    @ViewBuilder
    var patientsView: some View {
        LazyVGrid(columns: {
            #if os(iOS)
            return [GridItem(), GridItem(), GridItem()]
            #else
            return [GridItem(), GridItem(), GridItem(), GridItem()]
            #endif
        }()) {
            //person.circle
            ForEach(patientMarkers, id: \.id) { patient in
                if let missingText = patient.missingText {
                    Button {
                        if patient.liveCurrentValue != 0 {
                            return
                        }
                        
                        if let rtwId = liveMissionDetails?.patientsAtVehicleIds[patient.name],
                           let vOwner = liveMissionDetails?.vehicleOwners[rtwId], vOwner == model.getUsername() {
                            
                            // show transport dialog
                            Task {
                                let transportDetails = await model.getHospitals(rtwId: rtwId)
                                
                                DispatchQueue.main.async {
                                    rtwTransportDetails = transportDetails
                                    showRtwTransportDialog = true
                                }
                            }
                        }
                    } label: {
                        VStack {
                            ZStack {
                                /* For a progress circle background
                                Circle()
                                    .stroke(Color.gray, lineWidth: 5)
                                    .frame(width: 50, height: 50)*/
                                
                                Circle()
                                    .trim(from: 0, to: CGFloat(1 - (Float(patient.liveCurrentValue)/100)))
                                    .stroke(Color.red, style: StrokeStyle(lineWidth:2, lineCap: .round))
                                    .rotationEffect(.degrees(-90))
                                    .frame(width: 50, height: 50)
                                
                                Image(systemName: "person")
                                    .resizable()
                                    .frame(width: 25, height: 25)
                            }
                            .padding()
                            
                            Text(patient.name)
                            
                            if let missingText = patient.missingText, !missingText.isEmpty {
                                Text(missingText)
                                    .foregroundStyle(Color.orange.opacity(0.7))
                            }
                        }
                    }
                    .buttonStyle(.plain)
                    .padding()
                    .help(missingText)
                } else if patient.liveCurrentValue == 0 {
                    Button {
                        if patient.liveCurrentValue != 0 {
                            return
                        }
                        
                        if let rtwId = liveMissionDetails?.patientsAtVehicleIds[patient.name],
                           let vOwner = liveMissionDetails?.vehicleOwners[rtwId], vOwner == model.getUsername() {
                            
                            // show transport dialog
                            Task {
                                let transportDetails = await model.getHospitals(rtwId: rtwId)
                                
                                DispatchQueue.main.async {
                                    rtwTransportDetails = transportDetails
                                    showRtwTransportDialog = true
                                }
                            }
                        }
                    } label: {
                        VStack {
                            ZStack {
                                /* For a progress circle background
                                Circle()
                                    .stroke(Color.gray, lineWidth: 5)
                                    .frame(width: 50, height: 50)*/
                                
                                Circle()
                                    .trim(from: 0, to: CGFloat(1 - (Float(patient.liveCurrentValue)/100)))
                                    .stroke(Color.green, style: StrokeStyle(lineWidth:2, lineCap: .round))
                                    .rotationEffect(.degrees(-90))
                                    .frame(width: 50, height: 50)
                                
                                Image(systemName: "person")
                                    .resizable()
                                    .frame(width: 25, height: 25)
                            }
                            .padding()
                            
                            Text(patient.name)
                        }
                    }
                    .buttonStyle(.plain)
                    .padding()
                } else {
                    Button {
                        if patient.liveCurrentValue != 0 {
                            return
                        }
                        
                        if let rtwId = liveMissionDetails?.patientsAtVehicleIds[patient.name],
                           let vOwner = liveMissionDetails?.vehicleOwners[rtwId], vOwner == model.getUsername() {
                            
                            // show transport dialog
                            Task {
                                let transportDetails = await model.getHospitals(rtwId: rtwId)
                                
                                DispatchQueue.main.async {
                                    rtwTransportDetails = transportDetails
                                    showRtwTransportDialog = true
                                }
                            }
                        }
                    } label: {
                        VStack {
                            ZStack {
                                /* For a progress circle background
                                Circle()
                                    .stroke(Color.gray, lineWidth: 5)
                                    .frame(width: 50, height: 50)*/
                                
                                Circle()
                                    .trim(from: 0, to: CGFloat(1 - (Float(patient.liveCurrentValue)/100)))
                                    .stroke(Color.blue, style: StrokeStyle(lineWidth:2, lineCap: .round))
                                    .rotationEffect(.degrees(-90))
                                    .frame(width: 50, height: 50)
                                
                                Image(systemName: "person")
                                    .resizable()
                                    .frame(width: 25, height: 25)
                            }
                            .padding()
                            
                            Text(patient.name)
                        }
                    }
                    .buttonStyle(.plain)
                    .padding()
                }
            }
        }
    }
    
    private func imageUrl(for vehicle: LssVehicle) -> String {
        let idx = Int(vehicle.vehicleType)
        if vehicleImageUrlStrings.count > idx {
            return vehicleImageUrlStrings[Int(vehicle.vehicleType)]?[0] ?? model.relativeLssURLString(path: vehicle.imageUrlStatic)
        } else {
            return model.relativeLssURLString(path: vehicle.imageUrlStatic)
        }
    }
    
    @ViewBuilder
    var assetsTableView: some View {
        Table(selection: $selection, sortOrder: $sortOrder) {
            TableColumn("Name", value: \.vehicle.caption) { v in
                if let staticMissionDetails = staticMissionDetails, staticMissionDetails.requirements.doesNeedMe(caption: v.vehicle.caption, type: v.vehicle.vehicleType) {
                    VehicleRowView(vContainer: v, imageURL: URL(string: vehicleImageUrlStrings[v.vehicle.vehicleType < vehicleImageUrlStrings.count ? Int(v.vehicle.vehicleType) : 0]?[0] ?? model.relativeLssURLString(path: v.vehicle.imageUrlStatic))!)
                        #if os(macOS)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        #endif
                        .background(.orange.opacity(0.1))
                        .cornerRadius(8)
                } else {
                    VehicleRowView(vContainer: v, imageURL: URL(string: imageUrl(for: v.vehicle))!)
                        #if os(macOS)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        #endif
                }
            }
            
            TableColumn("FMS", value: \.vehicle.fmsReal) { v in
                Text(v.vehicle.fmsReal.formatted())
                    .monospacedDigit()
                    #if os(macOS)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .foregroundStyle(.secondary)
                    #endif
            }
            
            TableColumn("Distance (km)", value: \.distanceInKm) { v in
                Text("\(String(format: "%.2f", v.distanceInKm)) km")
                    .monospacedDigit()
                    #if os(macOS)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .foregroundStyle(.secondary)
                    #endif
            }
            
            TableColumn("Type", value: \.vehicle.vehicleType) { v in
                Text(VehicleType(rawValue: v.vehicle.vehicleType)?.asGermanString() ?? "N/A")
                    #if os(macOS)
                    .foregroundStyle(.secondary)
                    #endif
            }
        } rows: {
            Section {
                ForEach(vehicles) { vContainer in
                    TableRow(vContainer)
                }
            }
        }
    }
    
    @ViewBuilder
    var assetsListView: some View {
        List(vehicles, id: \.id, selection: $selection) { vContainer in
            VehicleRowView(vContainer: vContainer, imageURL: URL(string: vehicleImageUrlStrings[vContainer.vehicle.vehicleType < vehicleImageUrlStrings.count ? Int(vContainer.vehicle.vehicleType) : 0]?[0] ?? model.relativeLssURLString(path: vContainer.vehicle.imageUrlStatic))!)
        }
    }
    
    @ViewBuilder
    var einsatzDetailsView: some View {
        if let einsatz = self.einsatzDetails {
            if einsatz.rewardAndPrerequisites.count > 0 {
                Section {
                    ForEach(Array(einsatz.rewardAndPrerequisites), id: \.key) { key, value in
                        HStack {
                            Text(key)
                            Spacer()
                            Text(value)
                                .monospacedDigit()
                        }
                    }
                } header: {
                    Text("Details")
                }
            }
            
            if einsatz.requiredAssets.count > 0 {
                Section {
                    ForEach(Array(einsatz.requiredAssets), id: \.key) { assetName, amount in
                        HStack {
                            Text(assetName)
                            Spacer()
                            Text(amount.formatted())
                                .monospacedDigit()
                        }
                    }
                } header: {
                    Text("Requirements")
                }
            }
            
            if einsatz.additionalDetails.count > 0 {
                Section(isExpanded: $isAdditionalDetailsExpanded) {
                    ForEach(Array(einsatz.additionalDetails), id: \.key) { key, value in
                        HStack {
                            Text(key)
                            Spacer()
                            Text(value)
                                .monospacedDigit()
                        }
                    }
                } header: {
                    Text("Additional")
                }
                .onAppear {
                    isAdditionalDetailsExpanded = einsatz.requiredAssets.count == 0
                }
            }
        }
    }
    
    // TODO: merge with rtwTransportSheet
    // TODO: put into seperate file with own state for holding cells
    @ViewBuilder
    var prisonerTransportSheet: some View {
        VStack {
            if let transportVehicleId = prisonerTransportVehicleId {
                HStack {
                    Spacer()
                    Button {
                        showPrisonerTransportDialog = false
                    } label: {
                        Text("Close")
                    }
                    .buttonStyle(.borderedProminent)
                    #if os(iOS)
                    .padding(.top)
                    .padding(.trailing)
                    #endif
                }
                
                List {
                    ForEach(model.buildings.filter { $0.buildingType == 6 && $0.freeCells > 0 }.sorted(by: {
                        Coordinate(latitude: $0.latitude, longitude: $0.longitude).distance(to: missionCord) < Coordinate(latitude: $1.latitude, longitude: $1.longitude).distance(to: missionCord)
                    }), id: \.id) { station in
                        Button(action: {
                            // Handle station selection here
                            
                            Task {
                                DispatchQueue.main.async {
                                    showPrisonerTransportDialog = false // Close the sheet
                                    dismissAction.callAsFunction()
                                }
                                _ = await model.sendPrisonerToStation(vehicleId: transportVehicleId, stationId: station.id)
                            }
                        }) {
                            HStack {
                                Text("Name: \(station.caption); Distance: \(Coordinate(latitude: station.latitude, longitude: station.longitude).distance(to: missionCord).formatted()); Free Holding-Cells: \(String(station.freeCells)); IsMine: true")
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
            } else {
                Text("No transport selected!")
            }
        }
        #if os(macOS)
        .frame(minWidth: 300, maxWidth: 500, minHeight: 400, maxHeight: 600)
        #endif
    }
    
    @ViewBuilder
    var rtwTransportSheet: some View {
        VStack {
            if let transportDetails = rtwTransportDetails {
                HStack {
                    Spacer()
                    Button {
                        showRtwTransportDialog = false
                    } label: {
                        Text("Close")
                    }
                    .buttonStyle(.borderedProminent)
                    #if os(iOS)
                    .padding(.top)
                    .padding(.trailing)
                    #endif
                }
                List {
                    ForEach(transportDetails.hospitals, id: \.id) { hospital in
                        Button(action: {
                            // Handle hospital selection here
                            
                            Task {
                                DispatchQueue.main.async {
                                    showRtwTransportDialog = false // Close the sheet
                                    dismissAction.callAsFunction()
                                }
                                _ = await model.sendPatientToHospital(vehicleId: transportDetails.rtwId, hospitalId: hospital.id)
                            }
                        }) {
                            HStack {
                                Text("Name: \(hospital.name); Distance: \(hospital.distance.formatted()); IsMine: \(String(hospital.isMine)); HasRequiredSpecs: \(String(hospital.hasRequiredSpecialisation))")
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
            } else {
                Text("No hospitals found!")
            }
        }
        #if os(macOS)
        .frame(minWidth: 300, maxWidth: 500, minHeight: 400, maxHeight: 600)
        #endif
    }
    
    @ViewBuilder
    var prisonerManagementSheet: some View {
        VStack {
            HStack {
                Spacer()
                Button {
                    showPrisonerManagementSheet = false
                } label: {
                    Label("Close", systemImage: "xmark")
                }
            }
            .frame(alignment: .topTrailing)
            .padding(.trailing)
            .padding(.vertical)
            
            let userId = model.getUserID()
            
            // TODO: extract into computed property
            List(model.radioMessages.filter {
                if let missionId = $0.missionId {
                    return mission.id == missionId && $0.fms == FMSStatus.sprechwunsch.rawValue && $0.type == "vehicle_fms" && $0.userId == userId
                } else {
                    return false
                }
            }, id: \.self) { message in
                Button {
                    // show transport dialog
                    prisonerTransportVehicleId = message.id
                    showPrisonerManagementSheet = false
                    showPrisonerTransportDialog = true
                } label: {
                    Text(message.caption)
                }
            }
            .frame(alignment: .top)
        }
        .onAppear {
            // refresh to get current holding-cells occupancies
            model.fetchBuildings()
        }
        #if os(macOS)
        .frame(minWidth: 300, maxWidth: 500, minHeight: 400, maxHeight: 600)
        #endif
    }
    
    @ViewBuilder
    var massPatientManagementView: some View {
        VStack {
            HStack {
                Spacer()
                Button {
                    showMassPatientManagementSheet = false
                } label: {
                    Label("Close", systemImage: "xmark")
                }
            }
            .frame(alignment: .topTrailing)
            .padding(.trailing)
            .padding(.vertical)
            
            let userId = model.getUserID()
            
            //ForEach(liveMissionDetails.vehiclesWithMessages, id: \.self) { vehicleId in
            // TODO: extract into computed property
            List(model.radioMessages.filter {
                if let missionId = $0.missionId {
                    return mission.id == missionId && $0.fmsText == "Sprechwunsch" && $0.type == "vehicle_fms" && $0.userId == userId
                } else {
                    return false
                }
            }, id: \.self) { message in
                Button {
                    // show transport dialog
                    Task {
                        let transportDetails = await model.getHospitals(rtwId: message.id)
                        
                        DispatchQueue.main.async {
                            rtwTransportDetails = transportDetails
                            showMassPatientManagementSheet = false
                            showRtwTransportDialog = true
                        }
                    }
                } label: {
                    //Text(model.vehicles.first(where: { $0.id == vehicleId })?.caption ?? "\(vehicleId)")
                    Text(message.caption)
                }
            }
            .frame(alignment: .top)
        }
        #if os(macOS)
        .frame(minWidth: 300, maxWidth: 500, minHeight: 400, maxHeight: 600)
        #endif
    }
    
    @ViewBuilder
    var toolbarButtons: some View {
        Button {
            Task {
                if selection.count > 0 {
                    let result = await model.missionAlarm(missionId: mission.id, vehicleIds: selection)
                    print("[EmergencyCallDetailsView] Alarmed with status: \(result)")
                    if result {
                        // does forexample not work with anhanger like NEA50
                        /*for v in selection {
                            if let idx = model.vehicles.firstIndex(where: { $0.id == v }) {
                                DispatchQueue.main.async {
                                    model.vehicles[idx].fmsReal = 3
                                }
                            }
                        }*/
                        updateStaticDetails()
                    }
                }
            }
        } label: {
            Label("Alarm", systemImage: "bell.and.waves.left.and.right")
        }
        
        Button {
            showMassPatientManagementSheet = true
        } label: {
            Label("Patients Radio", systemImage: "phone.arrow.up.right")
        }
        .disabled(combinedPatientMarkers.isEmpty)
        
        Button {
            showPrisonerManagementSheet = true
        } label: {
            Label("Prisoner Radio", systemImage: "door.left.hand.open")
        }
        //.disabled(model.prisonerMarkers.isEmpty)
        .disabled(!model.radioMessages.contains(where: { ($0.missionId ?? 0) == mission.id && $0.fms == FMSStatus.sprechwunsch.rawValue }))
        
        #if os(iOS)
        Button {
            showMissionDetailsSheet = true
        } label: {
            Label("Info", systemImage: "info.circle")
        }
        #endif
        
        Picker("Category", selection: $vehicleCategoryFilter){
            Text("All").tag(VehicleCategory.all)
            Text("On Mission").tag(VehicleCategory.onMission)
            
            Section {
                Text("Feuerwehr (Standard)").tag(VehicleCategory.fd)
                Text("Feuerwehr (Spezial)").tag(VehicleCategory.fdSpecial)
                Text("Rettungsdienst").tag(VehicleCategory.rs)
                Text("Polizei").tag(VehicleCategory.pol)
                Text("Bereitschaftspolizei").tag(VehicleCategory.bPol)
                Text("THW").tag(VehicleCategory.thw)
            } header: {
                Text("Departments")
            }
        }
        // TODO: can't make both segmented on ios to move into menu button, cause then it not opens
        
        Picker("Type", selection: $vehicleTypeFilter) {
            Text("All").tag(VehicleType.all)
            
            // FD
            if vehicleCategoryFilter == .all || vehicleCategoryFilter == .onMission || vehicleCategoryFilter == .fd {
                Section {
                    Text("LF-10").tag(VehicleType.lf10)
                    Text("LF-20").tag(VehicleType.lf20)
                    Text("DLK").tag(VehicleType.dlk)
                    Text("RW").tag(VehicleType.rw)
                    Text("ELW 1").tag(VehicleType.elw1)
                    Text("GTLF").tag(VehicleType.gtlf)
                    Text("MLF").tag(VehicleType.mlf)
                    Text("HLF-10").tag(VehicleType.hlf10)
                    Text("HLF-20").tag(VehicleType.hlf20)
                    Text("TLF-4000").tag(VehicleType.tlf4000)
                    Text("TSF-W").tag(VehicleType.tsfW)
                } header: {
                    Text("Feuerwehr")
                }
            }
            
            if vehicleCategoryFilter == .all || vehicleCategoryFilter == .onMission || vehicleCategoryFilter == .fdSpecial {
                Section {
                    Text("GW-L2-Wasser").tag(VehicleType.gwL2Wasser)
                    Text("GW-Atemschutz").tag(VehicleType.gwA)
                    Text("GW-Mess").tag(VehicleType.gwMess)
                    Text("GW-Oil").tag(VehicleType.gwOil)
                    Text("GW-Gefahrgut").tag(VehicleType.gwGefahrgut)
                    Text("GW-Hoehenrettung").tag(VehicleType.gwHoehe)
                    Text("ELW 2").tag(VehicleType.elw2)
                    Text("Feuerwehrkran (FwK)").tag(VehicleType.fwk)
                    Text("Dekon-P").tag(VehicleType.dekonP)
                } header: {
                    Text("Feuerwehr")
                }
            }
            
            // rs
            if vehicleCategoryFilter == .all || vehicleCategoryFilter == .onMission || vehicleCategoryFilter == .rs {
                Section {
                    Text("RTW").tag(VehicleType.rtw)
                    Text("NEF").tag(VehicleType.nef)
                    Text("NAW").tag(VehicleType.naw)
                    Text("KTW").tag(VehicleType.ktw)
                    Text("Kdow-LNA").tag(VehicleType.kdowLNA)
                    Text("Kdow-OrgL").tag(VehicleType.kdowOrgL)
                } header: {
                    Text("Rettungsdienst")
                }
            }
            
            // POL
            if vehicleCategoryFilter == .all || vehicleCategoryFilter == .onMission || vehicleCategoryFilter == .pol || vehicleCategoryFilter == .bPol {
                Section {
                    Text("FuStW").tag(VehicleType.fuStW)
                    Text("DHuFüKw").tag(VehicleType.dhuUFueKw)
                } header: {
                    Text("Polizei")
                }
            }
            
            // THW
            if vehicleCategoryFilter == .all || vehicleCategoryFilter == .onMission || vehicleCategoryFilter == .thw {
                Section {
                    Text("GKW").tag(VehicleType.gkw)
                    Text("MTW-TZ").tag(VehicleType.mtwTz)
                    Text("MTW-OV").tag(VehicleType.mtwOv)
                    Text("MzGw (Fr N)").tag(VehicleType.mzGw)
                    Text("NEA50 [A-MzGw]").tag(VehicleType.nea50)
                    Text("Tauchkraftwagen").tag(VehicleType.tkw)
                    Text("LKW 7 Lkr 19 tm").tag(VehicleType.lkw7Lkr19Tm)
                    Text("Anh MzB [A-LKW7]").tag(VehicleType.anhMzB)
                    Text("Anh MzAB [A-LKW7]").tag(VehicleType.anhMzAB)
                    Text("Anh SchlB [A-LKW7]").tag(VehicleType.anhSchlB)
                } header: {
                    Text("THW")
                }
            }
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
