//
//  LssModel.swift
//
//
//  Created by Paul on 02.09.23.
//

import SwiftUI
import Combine

@MainActor
public class LssModel: ObservableObject {
    private var api: LssAPI?
    private var creds: FayeCredentials = FayeCredentials(stripeMid: "", sessionId: "", mcUniqueClientId: "", rememberUserToken: "")
    
    @Published public var isSignedIn: Bool = false
    @Published public var missionMarkers: [MissionMarker] = []
    @Published public var patientMarkers: [PatientMarker] = []
    @Published public var combinedPatientMarkers: [CombinedPatientMarker] = []
    @Published public var prisonerMarkers: [PrisonerMarker] = []
    @Published public var buildingMarkers: [BuildingMarker] = []
    @Published public var radioMessages: [RadioMessage] = []
    @Published public var chatMessages: [ChatMessage] = []
    @Published public var vehicles: [LssVehicle] = []
    @Published public var buildings: [LssBuilding] = []
    @Published public var credits: LssCredits = LssCredits.preview
    @Published public var missionSpeed: MissionSpeedValues = .pause
    
    private var einsaetze: [UInt16: LssMission] = [:]
    private var cancellables: [AnyCancellable] = []
    private var creditsTimer: Timer?
    private var haltMissionGenerate: Bool = false
    
    public func getUserID() -> Int {
        return Int(creds.userId ?? "0") ?? 0
    }
    
    public func getUsername() -> String? {
        return credits.userName != "" ? credits.userName : creds.userName
    }
    
    public func getCsrfToken() -> String? {
        return creds.csrfToken
    }
    
    public init(isPreview: Bool = false) {
        if !isPreview {
            isSignedIn = self.auth()
            Task {
                einsaetze = (await restEinsaetze()).reduce(into: [UInt16: LssMission]()) { result, mission in
                    if let id = UInt16(mission.id) {
                        result[id] = mission
                    }
                }
            }
        } else {
            chatMessages = [
                ChatMessage.preview2,
                ChatMessage.preview
            ]
            patientMarkers = [
                PatientMarker(missingText: nil, name: "Hans W.", missionId: 1, id: 12, milisecondsByPercent: nil, targetPercent: nil, liveCurrentValue: 14),
                PatientMarker(missingText: "NEF", name: "Lisa W.", missionId: 1, id: 16, milisecondsByPercent: nil, targetPercent: nil, liveCurrentValue: 66),
                PatientMarker(missingText: nil, name: "Thomas L.", missionId: 1, id: 25, milisecondsByPercent: nil, targetPercent: nil, liveCurrentValue: 0)
            ]
            vehicles = [
                LssVehicle.preview,
                LssVehicle.preview2,
                LssVehicle.preview3,
                LssVehicle.preview4
            ]
            missionMarkers = [
                MissionMarker.preview
            ]
            creds = FayeCredentials(stripeMid: "", sessionId: "", mcUniqueClientId: "", rememberUserToken: "")
            creds.userId = String(ChatMessage.preview.userId)
        }
    }
    
    public func isConnected() -> Bool {
        return api?.isConnected() ?? false
    }
    
    /// check if credentials are stored, use them if true
    public func auth() -> Bool {
        // TODO: check if they are still valid
        
        guard let storedCredentials = retrieveCredentials() else { return false }
        
        creds = FayeCredentials(
            stripeMid: storedCredentials.1.stripeMid,
            sessionId: storedCredentials.1.sessionId,
            mcUniqueClientId: storedCredentials.1.mcUniqueClientId,
            rememberUserToken: storedCredentials.1.rememberUserToken
        )
        
        // this may set the user email as username | username will be extracted from html
        //creds?.userName = storedCredentials.0
        api = LssAPI(creds: creds)
        
        return true
    }
    
    public func auth(emailOrUsername: String, password: String) async -> Bool {
        guard let credentials = await LssAPI.signIn(emailOrUsername: emailOrUsername, password: password) else {
            isSignedIn = false
            return false
        }
        if !saveCredentials(username: emailOrUsername, creds: EssentialCredentials(from: credentials)) {
            print("[LssKit, LssModel, auth] Saving credentials in Keychain failed!")
        }
        creds = credentials
        api = LssAPI(creds: creds)
        DispatchQueue.main.async {
            self.isSignedIn = true
        }
        // auto-connect
        await self.connectAsync()
        return true
    }
    
    public func connect() {
        Task {
            await self.connectAsync()
        }
    }
    
    public func disconnect() {
        haltMissionGenerate = true
        self.creditsTimer?.invalidate()
        self.cancellables.forEach { cancellable in
            cancellable.cancel()
        }
        self.api?.disconnect()
        // TODO: maybe need to wait until canceled
        self.cancellables.removeAll()
    }
    
    private func startCreditsTimer() {
        getCredits()
        DispatchQueue.main.async {
            self.creditsTimer = Timer.scheduledTimer(timeInterval: 20.0, target: self, selector: #selector(self.doGetCredits), userInfo: nil, repeats: true)
        }
    }
    
    public func connectAsync() async {
        let initialData = try? await self.api?.connect(creds: creds)
        if let initData = initialData {
            self.creds = initData.creds
            DispatchQueue.main.async {
                self.missionSpeed = MissionSpeedValues(rawValue: self.creds.missionSpeed) ?? .pause
                self.haltMissionGenerate = false
                Task {
                    self.missionGenerate()
                }
                
                // remove old stuff
                self.missionMarkers.removeAll()
                self.patientMarkers.removeAll()
                self.combinedPatientMarkers.removeAll()
                self.buildingMarkers.removeAll()
                self.radioMessages.removeAll()
                self.chatMessages.removeAll()
                
                // TODO: retrieve vehicleDrives
                self.missionMarkers.append(contentsOf: initData.missionMarkers)
                self.patientMarkers.append(contentsOf: initData.patientMarkers)
                self.combinedPatientMarkers.append(contentsOf: initData.combinedPatientMarkers)
                self.buildingMarkers.append(contentsOf: initData.buildingMarkers)
                self.radioMessages.append(contentsOf: initData.radioMessages)
                self.chatMessages.append(contentsOf: initData.chatMessages)
            }
        }
        subscribeToFayeData()
        let fetchDataStart = DispatchTime.now()
        self.fetchVehicles()
        self.fetchBuildings()
        let fetchDataEnd = DispatchTime.now()
        print("[LssModel] Fetched vehicles and buildings in \(Double(fetchDataEnd.uptimeNanoseconds - fetchDataStart.uptimeNanoseconds) / 1_000_000.0) ms")
        startCreditsTimer()
    }
    
    public func missionBinding(for id: MissionMarker.ID) -> Binding<MissionMarker> {
        Binding<MissionMarker> {
            guard let index = self.missionMarkers.firstIndex(where: { $0.id == id }) else {
                fatalError()
            }
            return self.missionMarkers[index]
        } set: { newValue in
            guard let index = self.missionMarkers.firstIndex(where: { $0.id == id }) else {
                fatalError()
            }
            return self.missionMarkers[index] = newValue
        }
    }
    
    public func chatMessageBinding(for hashValue: Int) -> Binding<ChatMessage> {
        Binding<ChatMessage> {
            guard let index = self.chatMessages.firstIndex(where: { $0.hashValue == hashValue }) else {
                fatalError()
            }
            return self.chatMessages[index]
        } set: { newValue in
            guard let index = self.chatMessages.firstIndex(where: { $0.hashValue == hashValue }) else {
                fatalError()
            }
            return self.chatMessages[index] = newValue
        }
    }
    
    public func buildingBinding(for id: BuildingMarker.ID) -> Binding<BuildingMarker> {
        Binding<BuildingMarker> {
            guard let index = self.buildingMarkers.firstIndex(where: { $0.id == id }) else {
                fatalError()
            }
            return self.buildingMarkers[index]
        } set: { newValue in
            guard let index = self.buildingMarkers.firstIndex(where: { $0.id == id }) else {
                fatalError()
            }
            return self.buildingMarkers[index] = newValue
        }
    }
    
    public func lssVehicleBinding(for id: LssVehicle.ID) -> Binding<LssVehicle> {
        Binding<LssVehicle> {
            guard let index = self.vehicles.firstIndex(where: { $0.id == id }) else {
                fatalError()
            }
            return self.vehicles[index]
        } set: { newValue in
            guard let index = self.vehicles.firstIndex(where: { $0.id == id }) else {
                fatalError()
            }
            return self.vehicles[index] = newValue
        }
    }
    
    public func lssBuildingBinding(for id: LssBuilding.ID) -> Binding<LssBuilding> {
        Binding<LssBuilding> {
            guard let index = self.buildings.firstIndex(where: { $0.id == id }) else {
                fatalError()
            }
            return self.buildings[index]
        } set: { newValue in
            guard let index = self.buildings.firstIndex(where: { $0.id == id }) else {
                fatalError()
            }
            return self.buildings[index] = newValue
        }
    }
    
    public func relativeLssURLString(path: String) -> String {
        return "\(lssBaseURL.absoluteString)\(path)"
    }
    
    public func sendAllianceChatMessageAsync(message: String, missionId: Int? = nil) async -> Bool {
        return await restAllianceChatSend(csrfToken: creds.csrfToken ?? "", message: message, missionId: missionId != nil ? String(missionId ?? -1) : nil)
    }
    
    public func sendMissionChatMessageAsync(message: String, missionId: Int) async -> Bool {
        return await restSendMissionReply(csrfToken: creds.csrfToken ?? "", message: message, missionId: String(missionId))
    }
    
    public func subscribeToFayeData() {
        api?.receivedFayeData
            .receive(on: DispatchQueue.main)
            //.throttle(for: 5, scheduler: DispatchQueue.main, latest: true)
            .sink { fayeData in
                fayeData.newMissionMarkers.forEach { newMissionMarker in
                    withAnimation {
                        if let idx = self.missionMarkers.firstIndex(where: { $0.id == newMissionMarker.id }) {
                            self.missionMarkers[idx].update(newData: newMissionMarker)
                        } else {
                            self.missionMarkers.append(newMissionMarker)
                        }
                    }
                }
                // for faster UI feedback after vehicle alarm
                fayeData.newVehicleDrives.forEach { newVehicleDrive in
                    withAnimation {
                        if let idx = self.vehicles.firstIndex(where: { $0.id == newVehicleDrive.id }) {
                            if let fmsReal = newVehicleDrive.fmsReal {
                                self.vehicles[idx].fmsReal = fmsReal
                            }
                            self.vehicles[idx].fmsShow = newVehicleDrive.fms
                        }
                    }
                }
                fayeData.newPatientMarkers.forEach { newPatientMarker in
                    if let idx = self.patientMarkers.firstIndex(where: { $0.id == newPatientMarker.id }) {
                        self.patientMarkers.remove(at: idx)
                    }
                    self.patientMarkers.append(newPatientMarker)
                }
                fayeData.newCombinedPatientMarkers.forEach { newCombinedPatientMarker in
                    if let idx = self.combinedPatientMarkers.firstIndex(of: newCombinedPatientMarker) {
                        self.combinedPatientMarkers[idx].count = newCombinedPatientMarker.count
                        self.combinedPatientMarkers[idx].errors = newCombinedPatientMarker.errors
                        self.combinedPatientMarkers[idx].untouched = newCombinedPatientMarker.untouched
                    } else {
                        self.combinedPatientMarkers.append(newCombinedPatientMarker)
                    }
                }
                fayeData.newPrisonerMarkers.forEach { newPrisonerMarker in
                    if let idx = self.prisonerMarkers.firstIndex(where: { $0.id == newPrisonerMarker.id }) {
                        self.prisonerMarkers.remove(at: idx)
                    }
                    self.prisonerMarkers.append(newPrisonerMarker)
                }
                fayeData.newRadioMessages.forEach { newRadioMessage in
                    if let idx = self.radioMessages.firstIndex(where: { $0.id == newRadioMessage.id }) {
                        self.radioMessages.remove(at: idx)
                    }
                    
                    withAnimation {
                        self.radioMessages.append(newRadioMessage)
                    }
                }
                if fayeData.newRadioMessages.count > 0 {
                    // only keep a maximum of 100 radio messages
                    if self.radioMessages.count > 200 {
                        self.radioMessages.removeSubrange(200..<self.chatMessages.count)
                    }
                }
                
                if fayeData.newChatMessages.count > 0 {
                    withAnimation {
                        self.chatMessages.append(contentsOf: fayeData.newChatMessages)
                    }
                    
                    // only keep a maximum of 100 chat messages
                    if self.chatMessages.count > 100 {
                        self.chatMessages.removeSubrange(100..<self.chatMessages.count)
                    }
                }
                
                fayeData.missionParticipationAdd.forEach { missionId in
                    if let idx = self.missionMarkers.firstIndex(where: { $0.id == missionId }) {
                        self.missionMarkers[idx].icon.replace("_rot", with: "_gelb")
                    }
                }
                
                fayeData.deletedMissions.forEach { missionId in
                    if let idx = self.missionMarkers.firstIndex(where: { $0.id == missionId }) {
                        _ = withAnimation {
                            self.missionMarkers.remove(at: idx)
                        }
                    }
                }
                fayeData.deletedPatients.forEach { patientId in                    
                    if let idx = self.patientMarkers.firstIndex(where: { $0.id == patientId }) {
                        self.patientMarkers.remove(at: idx)
                    }
                }
                
                fayeData.deletedPrisoners.forEach { prisonerId in
                    if let idx = self.prisonerMarkers.firstIndex(where: { $0.id == prisonerId }) {
                        self.prisonerMarkers.remove(at: idx)
                    }
                }
                
                print("[FayeDataSubscription] Added \(fayeData.newMissionMarkers.count)M, \(fayeData.newPatientMarkers.count)PA, \(fayeData.newPrisonerMarkers.count)PR, \(fayeData.newVehicleDrives.count)VD, \(fayeData.newRadioMessages.count)RM, \(fayeData.newChatMessages.count)CM | \nRemoved: \(fayeData.deletedMissions.count)M, \(fayeData.deletedPatients.count)PA, \(fayeData.deletedPrisoners.count)PR\n")
            }
            .store(in: &cancellables)
    }
    
    public func getStaticMissionDetails(mtId: UInt16) -> LssMission? {
        return einsaetze[mtId]
    }
    
    public func fetchVehicles() {
        fetchData(LssEndpoint.urlForV2Vehicles(), responseType: LssVehiclesResponseData.self)
            //.receive(on: RunLoop.main)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("[LssKit, LssModel, getVehicles] Finished")
                    break
                case .failure(let error):
                    // Handle the error
                    print("[LssKit, LssModel, getVehicles] Error: \(error)")
                }
            }, receiveValue: { responseObject in
                // Handle the responseObject of type [LssVehicle]
                self.vehicles = responseObject.result
            })
            .store(in: &cancellables)
    }
    
    public func fetchBuildings() {
        fetchData(LssEndpoint.urlForBuildings(), responseType: [LssBuilding].self)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("[LssKit, LssModel, getBuildings] Finished")
                case .failure(let error):
                    print("[LssKit, LssModel, getBuildings] Error: \(error)")
                }
            }, receiveValue: { responseObject in
                self.buildings = responseObject
            })
            .store(in: &cancellables)
    }
    
    public func enableAllianceFMS(on: Bool) async {
        _ = await restEnabelAllianceFMS(csrfToken: creds.csrfToken ?? "", on: on)
    }
    
    public nonisolated func missionGenerate() {
        Task {
            let missionSpeed = await missionSpeed
            if missionSpeed == .pause {
                DispatchQueue.main.async {
                    self.haltMissionGenerate = true
                }
                return
            }
            
            if await haltMissionGenerate {
                return
            }
            
            _ = await restMissionGenerate(csrfToken: creds.csrfToken ?? "")
            
            var timeout: Double = 0.0
            
            switch missionSpeed {
            case .perMinute: timeout = Double.random(in: 31_000...120_000)
            case .per2Minutes: timeout = Double.random(in: 120_000...220_000)
            case .per30Seconds: timeout = Double.random(in: 31_000...45_000)
            case .per20Seconds: timeout = Double.random(in: 21_000...25_000)
            case .per5Minutes: timeout = Double.random(in: 250_000...350_000)
            case .per7Minutes: timeout = Double.random(in: 400_000...470_000)
            case .per10Minutes: timeout = Double.random(in: 500_000...700_000)
            default: timeout = Double.random(in: 31_000...120_000)
            }
            
            // Schedule the function to run again after the calculated timeout.
            DispatchQueue.global().asyncAfter(deadline: .now() + timeout) {
                self.missionGenerate()
            }
        }
    }
    
    @objc private func doGetCredits() {
        getCredits()
    }
    
    public func getCredits() {
        fetchData(LssEndpoint.urlForCredits(), responseType: LssCredits.self)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("Finished credits request")
                    break
                case .failure(let error):
                    // Handle the error
                    //print("Error on credits request: \(error)")
                    
                    if case let DecodingError.dataCorrupted(context) = error {
                        print(context)
                    } else if case let DecodingError.keyNotFound(key, context) = error {
                        print("Key '\(key)' not found:", context.debugDescription)
                        print("codingPath:", context.codingPath)
                    } else if case let DecodingError.valueNotFound(value, context) = error {
                        print("Value '\(value)' not found:", context.debugDescription)
                        print("codingPath:", context.codingPath)
                    } else if case let DecodingError.typeMismatch(type, context) = error  {
                        print("Type '\(type)' mismatch:", context.debugDescription)
                        print("codingPath:", context.codingPath)
                    } else {
                        print("error: ", error)
                    }
                }
            }, receiveValue: { result in
                withAnimation {
                    self.credits = result
                }
            })
            .store(in: &cancellables)
    }
    
    /// Send  vehicles to a mission
    public func missionAlarm(missionId: Int, vehicleIds: Set<Int>) async -> Bool {
        if await restMissionAlarm(csrfToken: creds.csrfToken ?? "N/A", missionId: missionId, vehicleIds: vehicleIds) {
            // start delay of vehicle
            // TODO: only fetch vehicles from vehicleIds with vehiclesMap but may be bad because of GKW for NEA50 (vehicles with "Anhänger")
            DispatchQueue.main.asyncAfter(deadline: .now()+1) {
                self.fetchVehicles()
            }
            return true
        }
        return false
    }
    
    public func backalarmVehicle(vehicleId: Int, missionId: Int? = nil) async -> Bool {
        if await restBackalarmVehicle(vehicleId, csrfToken: creds.csrfToken ?? "N/A", missionId: missionId) {
            //maybe not needed because html for vehicles at mission is refreshed imideatly
            /*DispatchQueue.main.asyncAfter(deadline: .now()+1) {
                self.getVehicles()
            }*/
            return true
        }
        
        return false
    }
    
    public func getDailyBonus(day: UInt8) async -> Bool {
        return await restCollectDailyBonuses(csrfToken: creds.csrfToken ?? "", day: day)
    }
    
    public func getHospitals(rtwId: Int) async -> RtwTransportDetails {
        return await scanRtwHTML(csrfToken: creds.csrfToken ?? "", rtwId: rtwId)
    }
    
    public func sendPatientToHospital(vehicleId: Int, hospitalId: Int) async -> Bool {
        return await restSendPatientToHospital(csrfToken: creds.csrfToken ?? "", vehicleId: vehicleId, hospitalId: hospitalId)
    }
    
    public func sendPrisonerToStation(vehicleId: Int, stationId: Int) async -> Bool {
        return await restSendPrisonerToStation(csrfToken: creds.csrfToken ?? "", vehicleId: vehicleId, stationId: stationId)
    }
    
    public func setMissionSpeed(speed: UInt8) async -> Bool {
        if await restSetMissionSpeed(csrfToken: creds.csrfToken ?? "", speed: speed) {
            missionSpeed = MissionSpeedValues(rawValue: speed) ?? .pause
            if missionSpeed != .pause && haltMissionGenerate {
                haltMissionGenerate = false
                Task {
                    missionGenerate()
                }
            }
            return true
        }
        
        return false
    }
    
    public func logout() {
        if deleteCredentials() {
            self.disconnect()
            creds = FayeCredentials(stripeMid: "", sessionId: "", mcUniqueClientId: "", rememberUserToken: "")
            self.missionMarkers.removeAll()
            self.patientMarkers.removeAll()
            self.prisonerMarkers.removeAll()
            self.buildingMarkers.removeAll()
            self.radioMessages.removeAll()
            self.chatMessages.removeAll()
            self.vehicles.removeAll()
            
            self.isSignedIn = false
        }
    }
    
    deinit {
        self.creditsTimer?.invalidate()
        self.cancellables.forEach { cancellable in
            cancellable.cancel()
        }
        self.cancellables.removeAll()
    }
}

public extension LssModel {
    static let preview = LssModel(isPreview: true)
}

fileprivate extension Set {
    mutating func insertRange(items: [Element]) {
        items.forEach { self.insert($0) }
    }
}

// automation
public extension LssModel {
    private func missionCoord(mid: Int) -> Coordinate? {
        if let mission = self.missionMarkers.first(where: { $0.id == mid }) {
            return Coordinate(latitude: mission.latitude, longitude: mission.longitude)
        }
        return nil
    }
    
    private func vehicleCord(missionCoord: Coordinate, vehicle: LssVehicle) -> Double? {
        if vehicle.fmsShow == FMSStatus.einsatzbereitWache.rawValue,
           let building = self.buildingMarkers.first(where: { $0.id == vehicle.buildingId } ) {
            return Coordinate(latitude: building.latitude, longitude: building.longitude).distance(to: missionCoord)
        } else if vehicle.fmsShow == FMSStatus.ankunftAnEinsatz.rawValue && vehicle.queuedMissionId == nil,
                  let targetId = vehicle.targetId,
                  let currentMission = self.missionMarkers.first(where: {$0.id == targetId}){
            return Coordinate(latitude: currentMission.latitude, longitude: currentMission.longitude).distance(to: missionCoord)
        }
        return nil
    }
    
    func autoAlarm(mid: Int, caption: String, unitRequirements: MissionUinitsRequirement) async -> Bool {
        var vids: Set<Int> = []
        guard let missionCoord = self.missionCoord(mid: mid) else {
            return false
        }
        let myVehicles: [(VehicleType, Int, Double, UInt8)] = self.vehicles.compactMap {
            if let vt = VehicleType(rawValue: $0.vehicleType),
               // this makes sure only fms 2 or 4 is returned
               let c = self.vehicleCord(missionCoord: missionCoord, vehicle: $0),
               // max driving distance == 100km
               c <= 100.0 {
                // optional + 100km so only directly available vehicles are alarmed
                return (vt, $0.id, c + ($0.fmsShow == FMSStatus.ankunftAnEinsatz.rawValue ? 100.0 : 0.0), $0.fmsShow)
            }
            return nil
        }
        
        if caption == "Krankentransport" {
            if let ktwId = myVehicles.first(where: { $0.0 == .ktw })?.1 {
                vids.insert(ktwId)
                return await self.missionAlarm(missionId: mid, vehicleIds: vids)
            }
            return false
        }
        
        // calculate required LFs
        // TODO: also check required Feuerwehrleute
        // TODO: support HLFs
        let waterRequired = unitRequirements.rWater
        var requiredLfsCount = Int(unitRequirements.rLF)
        if let waterRequired = waterRequired {
            var waterLeft = Int(waterRequired) - (requiredLfsCount * 2000)
            // TODO: currently max 1 GTLF supported (pre mission)
            if waterLeft > 10_000,
               let gtlfId = myVehicles.first(where: { $0.0 == .gtlf })?.1  {
                vids.insert(gtlfId)
                // because a GTLF also counts as LF
                if requiredLfsCount > 0 {
                    requiredLfsCount -= 1
                }
                waterLeft -= 10_000
            }
            
            // TODO: support TLF4000
            if waterLeft > 0 {
                // send one additional unit if not enoguht water but less than 2000 extra required
                requiredLfsCount += waterLeft / 2000 + ((waterLeft % 2000) > 0 ? 1 : 0)
            }
        }
        var selectedLfs = myVehicles.filter { $0.0 == VehicleType.lf20 && $0.3 == FMSStatus.einsatzbereitWache.rawValue }.sorted(by: { $0.2 < $1.2 }).prefix(requiredLfsCount).map { $0.1 }
        if selectedLfs.count == 0 && requiredLfsCount > 0 {
            selectedLfs = myVehicles.filter { $0.0 == VehicleType.hlf20 && $0.3 == FMSStatus.einsatzbereitWache.rawValue }.sorted(by: { $0.2 < $1.2 }).prefix(requiredLfsCount).map { $0.1 }
            
            if selectedLfs.count == 0 {
                // with "weiteralarmieren" allowed
                selectedLfs = myVehicles.filter { $0.0 == VehicleType.lf20 }.sorted(by: { $0.2 < $1.2 }).prefix(requiredLfsCount).map { $0.1 }
                
                if selectedLfs.count == 0 {
                    // with "weiteralarmieren" allowed
                    selectedLfs = myVehicles.filter { $0.0 == VehicleType.hlf20 }.sorted(by: { $0.2 < $1.2 }).prefix(requiredLfsCount).map { $0.1 }
                }
            }
        }
        
        vids.insertRange(items: selectedLfs)
        
        vids.insertRange(items: myVehicles.filter { $0.0 == VehicleType.rw }.sorted(by: { $0.2 < $1.2 }).prefix(Int(unitRequirements.rRW)).map { $0.1 })
        vids.insertRange(items: myVehicles.filter { $0.0 == VehicleType.dlk }.sorted(by: { $0.2 < $1.2 }).prefix(Int(unitRequirements.rDLK)).map { $0.1 })
        vids.insertRange(items: myVehicles.filter { $0.0 == VehicleType.elw1 }.sorted(by: { $0.2 < $1.2 }).prefix(Int(unitRequirements.rELW1)).map { $0.1 })
        vids.insertRange(items: myVehicles.filter { $0.0 == VehicleType.elw2 }.sorted(by: { $0.2 < $1.2 }).prefix(Int(unitRequirements.rELW2)).map { $0.1 })
        vids.insertRange(items: myVehicles.filter { $0.0 == VehicleType.gwA }.sorted(by: { $0.2 < $1.2 }).prefix(Int(unitRequirements.rGWa)).map { $0.1 })
        vids.insertRange(items: myVehicles.filter { $0.0 == VehicleType.fuStW }.sorted(by: { $0.2 < $1.2 }).prefix(Int(unitRequirements.rPol)).map { $0.1 })
        vids.insertRange(items: myVehicles.filter { $0.0 == VehicleType.fwk }.sorted(by: { $0.2 < $1.2 }).prefix(Int(unitRequirements.rFWK)).map { $0.1 })
        
        // TODO: optimized for different posibilities, counts and transport options
        vids.insertRange(items: myVehicles.filter { $0.0 == VehicleType.rtw }.sorted(by: { $0.2 < $1.2 }).prefix(Int(unitRequirements.possiblePatients)).map { $0.1 })
        
        vids.insertRange(items: myVehicles.filter { $0.0 == VehicleType.gwMess }.sorted(by: { $0.2 < $1.2 }).prefix(Int(unitRequirements.rGWm)).map { $0.1 })
        vids.insertRange(items: myVehicles.filter { $0.0 == VehicleType.gkw }.sorted(by: { $0.2 < $1.2 }).prefix(Int(unitRequirements.rTHW_GKW)).map { $0.1 })
        vids.insertRange(items: myVehicles.filter { $0.0 == VehicleType.mtwTz }.sorted(by: { $0.2 < $1.2 }).prefix(Int(unitRequirements.rTHW_MtwTz)).map { $0.1 })
        vids.insertRange(items: myVehicles.filter { $0.0 == VehicleType.mzGw }.sorted(by: { $0.2 < $1.2 }).prefix(Int(unitRequirements.rTHW_MzGwFGrN)).map { $0.1 })
        vids.insertRange(items: myVehicles.filter { $0.0 == VehicleType.gwOil }.sorted(by: { $0.2 < $1.2 }).prefix(Int(unitRequirements.rGWo)).map { $0.1 })
        vids.insertRange(items: myVehicles.filter { $0.0 == VehicleType.gwHoehe }.sorted(by: { $0.2 < $1.2 }).prefix(Int(unitRequirements.rGWh)).map { $0.1 })
        vids.insertRange(items: myVehicles.filter { $0.0 == VehicleType.tkw }.sorted(by: { $0.2 < $1.2 }).prefix(Int(unitRequirements.rGWtaucher)).map { $0.1 })
        vids.insertRange(items: myVehicles.filter { $0.0 == VehicleType.dekonP }.sorted(by: { $0.2 < $1.2 }).prefix(Int(unitRequirements.rDekonP)).map { $0.1 })
        vids.insertRange(items: myVehicles.filter { $0.0 == VehicleType.gwL2Wasser }.sorted(by: { $0.2 < $1.2 }).prefix(Int(unitRequirements.rSchlauchwagen)).map { $0.1 })
        vids.insertRange(items: myVehicles.filter { $0.0 == VehicleType.gwGefahrgut}.sorted(by: { $0.2 < $1.2 }).prefix(Int(unitRequirements.rGWg)).map { $0.1 })
        
        // TODO: do for all "Anhänger"
        let brmgrs = myVehicles.filter { $0.0 == VehicleType.brmgr}.sorted(by: { $0.2 < $1.2 }).prefix(Int(unitRequirements.rTHW_BRmGr)).map { $0.1 }
        if brmgrs.count == 0 {
            vids.insertRange(items: myVehicles.filter { $0.0 == VehicleType.lkwK9}.sorted(by: { $0.2 < $1.2 }).prefix(Int(unitRequirements.rTHW_LKWk9)).map { $0.1 })
        } else {
            vids.insertRange(items: brmgrs)
        }
        
        vids.insertRange(items: myVehicles.filter { $0.0 == VehicleType.nef}.sorted(by: { $0.2 < $1.2 }).prefix(unitRequirements.nefPosibility != nil && unitRequirements.nefPosibility! > 90 ? Int(unitRequirements.nefPosibility!) : 0).map { $0.1 })
        vids.insertRange(items: myVehicles.filter { $0.0 == VehicleType.dhuUFueKw}.sorted(by: { $0.2 < $1.2 }).prefix(Int(unitRequirements.rDhufukw)).map { $0.1 })
        vids.insertRange(items: myVehicles.filter { $0.0 == VehicleType.nea50}.sorted(by: { $0.2 < $1.2 }).prefix(Int(unitRequirements.rNEA50)).map { $0.1 })
        
        // vehicles are automatically updated by missionAlarm after alarming vehicles + delay
        return await self.missionAlarm(missionId: mid, vehicleIds: vids)
    }
}
