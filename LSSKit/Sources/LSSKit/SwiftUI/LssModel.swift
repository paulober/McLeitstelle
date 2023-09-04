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
    private var creds: FayeCredentials?
    
    @Published public var isSignedIn: Bool = false
    @Published public var missionMarkers: [MissionMarker] = []
    @Published public var patientMarkers: [PatientMarker] = []
    @Published public var prisonerMarkers: [PrisonerMarker] = []
    @Published public var buildingMarkers: [BuildingMarker] = []
    @Published public var radioMessages: [RadioMessage] = []
    @Published public var chatMessages: [ChatMessage] = []
    @Published public var vehicles: [LssVehicle] = []
    @Published public var credits: Int = -1
    
    private var einsaetze: [UInt16: LssMission] = [:]
    private var cancellables: [AnyCancellable] = []
    private var creditsTimer: Timer?
    
    public func getUserID() -> Int {
        return Int(creds?.userId ?? "0") ?? 0
    }
    
    public func getUsername() -> String? {
        return creds?.userName
    }
    
    public func getCsrfToken() -> String? {
        return creds?.csrfToken
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
            creds = FayeCredentials(stripeMid: "", sessionId: "", mcUniqueClientId: "", rememberUserToken: "")
            creds?.userId = String(ChatMessage.preview.userId)
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
        creds?.userName = storedCredentials.0
        api = LssAPI(creds: &creds!)
        
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
        api = LssAPI(creds: &creds!)
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
        let initialData = await self.api?.connect()
        if let initData = initialData {
            // remove old stuff
            missionMarkers.removeAll()
            patientMarkers.removeAll()
            buildingMarkers.removeAll()
            radioMessages.removeAll()
            chatMessages.removeAll()
            
            // TODO: retrieve vehicleDrives
            missionMarkers.append(contentsOf: initData.missionMarkers)
            patientMarkers.append(contentsOf: initData.patientMarkers)
            buildingMarkers.append(contentsOf: initData.buildingMarkers)
            radioMessages.append(contentsOf: initData.radioMessages)
            chatMessages.append(contentsOf: initData.chatMessages)
        }
        subscribeToFayeData()
        getVehicles()
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
    
    public func sendAllianceChatMessageAsync(message: String, missionId: Int? = nil) async -> Bool {
        return await restAllianceChatSend(csrfToken: creds?.csrfToken ?? "", message: message, missionId: missionId != nil ? String(missionId ?? -1) : nil)
    }
    
    public func sendMissionChatMessageAsync(message: String, missionId: Int) async -> Bool {
        return await restSendMissionReply(csrfToken: creds?.csrfToken ?? "", message: message, missionId: String(missionId))
    }
    
    public func subscribeToFayeData() {
        api?.receivedFayeData
            .receive(on: DispatchQueue.main)
            .sink { fayeData in
                self.missionMarkers.append(contentsOf: fayeData.newMissionMarkers)
                self.patientMarkers.append(contentsOf: fayeData.newPatientMarkers)
                self.prisonerMarkers.append(contentsOf: fayeData.newPrisonerMarkers)
                if fayeData.newRadioMessages.count > 0 {
                    self.radioMessages.append(contentsOf: fayeData.newRadioMessages)
                    
                    // only keep a maximum of 100 radio messages
                    if self.radioMessages.count > 200 {
                        self.radioMessages.removeSubrange(200..<self.chatMessages.count)
                    }
                }
                if fayeData.newChatMessages.count > 0 {
                    self.chatMessages.append(contentsOf: fayeData.newChatMessages)
                    
                    // only keep a maximum of 100 chat messages
                    if self.chatMessages.count > 100 {
                        self.chatMessages.removeSubrange(100..<self.chatMessages.count)
                    }
                }
                
                fayeData.deletedMissions.forEach { missionId in
                    if let idx = self.missionMarkers.firstIndex(where: { $0.id == missionId }) {
                        self.missionMarkers.remove(at: idx)
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
    
    public func getVehicles() {
        fetchData(LssEndpoint.urlForV2Vehicles(), responseType: LssVehiclesResponseData.self)
            //.receive(on: RunLoop.main)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("Finished")
                    break
                case .failure(let error):
                    // Handle the error
                    print("Error: \(error)")
                }
            }, receiveValue: { responseObject in
                // Handle the responseObject of type [LssVehicle]
                self.vehicles = responseObject.result
            })
            .store(in: &cancellables)
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
                    print("Error on credits request: \(error)")
                }
            }, receiveValue: { result in
                self.credits = result.creditsUserCurrent
            })
            .store(in: &cancellables)
    }
    
    /// Send  vehicles to a mission
    public func missionAlarm(missionId: Int, vehicleIds: Set<Int>) async -> Bool {
        return await restMissionAlarm(csrfToken: api!.credentials.csrfToken!, missionId: missionId, vehicleIds: vehicleIds)
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
