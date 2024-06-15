//
//  LssAPI.swift
//
//
//  Created by Paul on 29.08.23.
//

import Foundation
import Combine

enum LssAPIError: Error {
    case downloadIndexHTMLFailed
}

/*
 import Foundation
 let startTime = DispatchTime.now()
 function()
 let endTime = DispatchTime.now()
 let miliseconds = Double(endTime.uptimeNanoseconds - startTime.uptimeNanoseconds) / 1_000_000
 print("Download time-span: \(miliseconds)ms")
 */

/**
 A communication wrapper for the Leistellenspiel.de
 */
public class LssAPI {
    private let client: FayeClient
    private var clientId: String?
    private var cancellableReceiver: AnyCancellable?
    public var credentials: FayeCredentials
    
    private var fayeDataSubject = PassthroughSubject<FayeData, Never>()
    
    public init(creds: FayeCredentials) {
        // TODO: maybe start without unique client id then sever creates new
        self.credentials = creds
        // TODO: implement /level_upgrade and
        client = FayeClient()
    }
    
    public static func signIn(emailOrUsername: String, password: String) async -> FayeCredentials? {
        guard var creds = await scanSignUpHTML(),
            let csrfToken = creds.csrfToken else {
            return nil
        }
        
        let result = await restUsersSignIn(creds: &creds, csrfToken: csrfToken, emailOrUsername: emailOrUsername, password: password)
        
        return result ? creds : nil
    }
    
    /**
     Connects to websocket, refreshes credentials and loads initital data.
     */
    public func connect(creds: FayeCredentials) async throws -> LssDTOCollection {
        var initialData: LssDTOCollection = LssDTOCollection(creds: creds)
        
        #if DEBUG
        var startTime = DispatchTime.now()
        #endif
        // set initial cookies for index request
        constructCookies(for: lssBaseURL, creds: initialData.creds)
        
        // needed for ext values for faye
        guard let indexHTML = await downloadIndexHTML(from: lssBaseURL, creds: &initialData.creds) else { throw LssAPIError.downloadIndexHTMLFailed }
        #if DEBUG
        var endTime = DispatchTime.now()
        print("Downloaded index.html in \(Double(endTime.uptimeNanoseconds - startTime.uptimeNanoseconds) / 1_000_000.0)ms")
        startTime = DispatchTime.now()
        #endif
        // reducing into html contianing only the scripts doesn't save time in scaning but takes about 5 seconds
        /*startTime = DispatchTime.now()
        let scriptsHTML = htmlReduceToScripts(from: indexHTML)
        endTime = DispatchTime.now()
        print("Reduced scriptsHTML in \(Double(endTime.uptimeNanoseconds - startTime.uptimeNanoseconds) / 1_000_000.0)ms")*/
    
        async let userDetailsTask = htmlExtractUserDetails(from: indexHTML, indexHTML: indexHTML)
        
        async let radioMessagesTask = htmlExtractRadioMessages(from: indexHTML)
        async let chatMessagesTask = htmlExtractAllianceChats(from: indexHTML)
        async let missionMarkersTask = htmlExtractMissionMarkers(from: indexHTML)
        async let patientMarkersTask = htmlExtractPatientMarkers(from: indexHTML)
        async let combinedPatientMarkersTask = htmlExtractCombinedPatientMarkers(from: indexHTML)
        async let buildingMarkersTask = htmlExtractBuildingMarkers(from: indexHTML)
        async let vehicleDrivesTask = htmlExtractVehicleDrives(from: indexHTML)
        
        var userDetails: [UserDetailsResult]
        (userDetails, initialData.radioMessages, initialData.chatMessages, initialData.missionMarkers, initialData.patientMarkers, initialData.combinedPatientMarkers, initialData.buildingMarkers, initialData.vehicleDrives) = await (userDetailsTask, radioMessagesTask, chatMessagesTask, missionMarkersTask, patientMarkersTask, combinedPatientMarkersTask, buildingMarkersTask, vehicleDrivesTask)
        
        for detail in userDetails {
            switch detail {
            case .userID(let userID):
                initialData.creds.userId = userID
            case .userName(let userName):
                initialData.creds.userName = userName
            case .allianceId(let allianceId):
                initialData.creds.allianceId = allianceId
            case .extensions(let extensions, let allianceGuid):
                initialData.creds.exts = extensions
                if let allianceGuid = allianceGuid {
                    initialData.creds.allianceGuid = allianceGuid
                }
            case .csrfToken(let csrfToken):
                initialData.creds.csrfToken = csrfToken
            case .missionSpeed(let missionSpeed):
                initialData.creds.missionSpeed = missionSpeed
            case .latLong(let lat, let long):
                initialData.creds.mapView = (lat, long)
            }
        }
        #if DEBUG
        endTime = DispatchTime.now()
        print("Extracted details in \(Double(endTime.uptimeNanoseconds - startTime.uptimeNanoseconds) / 1_000_000.0)ms")
        startTime = DispatchTime.now()
        #endif
        
        self.credentials = initialData.creds
        // reconstruct cookies with updated creds
        constructCookies(for: lssBaseURL, creds: initialData.creds)
        // TODO: find better solution cause this is also done in FayeClient.init
        client.authenticate(creds: initialData.creds)
        
        client.resume()
        startReceivingMessages()
        
        #if DEBUG
        endTime = DispatchTime.now()
        print("Resumed client in \(Double(endTime.uptimeNanoseconds - startTime.uptimeNanoseconds) / 1_000_000.0)ms")
        #endif
        
        return initialData
    }
    
    public func disconnect() {
        client.suspend()
    }
    
    public func isConnected() -> Bool {
        return client.isConnected()
    }
    
    private func startReceivingMessages() {
        cancellableReceiver = client.receive().sink (receiveCompletion: { completion in
            switch completion {
            case .finished:
                print("[LssKit] Stop receiving messages.")
            case .failure(let error):
                print("[LssKit] An error occured: \(error)")
                // Start the loop by subscribing again
                self.startReceivingMessages()
            }
        }, receiveValue: { [weak self] message in
            guard let message = message else {
                // Continue the loop by subscribing again
                self?.startReceivingMessages()
                return
            }
            
            switch message.channel {
            case BayeuxChannel.Handshake.rawValue:
                if let clientId = message.clientId {
                    #if DEBUG
                    print("[LssKit] Received new client ID: \(clientId)")
                    #endif
                    self?.clientId = clientId
                    
                    assert(message.supportedConnectionTypes != nil && message.supportedConnectionTypes!.contains(.WebSocket))
                    
                    self?.client.sendConnect(clientId: clientId)
                    self?.subscribe()
                }
            case BayeuxChannel.Connect.rawValue:
                if let clientId = self?.clientId {
                    // or send this in advice.interval
                    self?.client.sendConnect(clientId: clientId)
                }
            case BayeuxChannel.Subscribe.rawValue:
                if let result = message.successful {
                    #if DEBUG
                    if result {
                        print("Successfully subscribed to channel: \(message.subscription ?? "N/A")")
                    } else {
                        print("Failed to subscribe to channel: \(message.subscription ?? "N/A")")
                    }
                    #endif
                }
            case BayeuxChannel.AllDE.rawValue:
                print("Message in channel allde: \(message.data ?? "N/A")")
            default:
                if let data = message.data {
                    if message.channel.starts(with: "/private-user") {
                        let fayeData = scanFayeData(data: data)
                        #if DEBUG && LSS_LOG_FAYE_DATA
                        for missionMarker in fayeData.newMissionMarkers {
                            print("Private mission: \(missionMarker.caption) (Category: \(missionMarker.filterId ?? "N/A"))", terminator: "; ")
                        }
                        for patientMarker in fayeData.newPatientMarkers {
                            print("\n\t... with patient: \(patientMarker.name)", terminator: "")
                        }
                        for prisonerMarker in fayeData.newPrisonerMarkers {
                            print("\n\t... with prisoner: \(prisonerMarker.name)", terminator: "")
                        }
                        for vehicleDrive in fayeData.newVehicleDrives {
                            print("\n\t... with vehicle: \(vehicleDrive.caption)", terminator: "")
                        }
                        print()
                        #endif
                        self?.fayeDataSubject.send(fayeData)
                        break
                    } else if message.channel.starts(with: "/private-alliance") {
                        let fayeData = scanFayeData(data: data)
                        #if DEBUG && LSS_LOG_FAYE_DATA
                        for missionMarker in fayeData.newMissionMarkers {
                            print("Alliance Mission: \(missionMarker.caption) (Category: \(missionMarker.filterId ?? "N/A"))", terminator: "; ")
                        }
                        for patientMarker in fayeData.newPatientMarkers {
                            print("\n\t... with patient: \(patientMarker.name)", terminator: "")
                        }
                        for prisonerMarker in fayeData.newPrisonerMarkers {
                            print("\n\t... with prisoner: \(prisonerMarker.name)", terminator: "")
                        }
                        for vehicleDrive in fayeData.newVehicleDrives {
                            print("\n\t... with vehicle: \(vehicleDrive.caption)", terminator: "")
                        }
                        print()
                        #endif
                        self?.fayeDataSubject.send(fayeData)
                        break
                    }
                }
               
                print("[LssKit] Unknown messsage type: \(message.channel)")
            }
            
            // Continue the loop by subscribing again
            self?.startReceivingMessages()
        })
    }
    
    private func subscribe() {
        guard let clientId = clientId, 
            let userId = credentials.userId,
            let allianceGuid = credentials.allianceGuid else {
            return
        }
        
        self.client.subscribe(to: BayeuxChannel.allianceChannel(allianceId: allianceGuid), clientId: clientId, ext: credentials.exts)
        self.client.subscribe(to: BayeuxChannel.AllDE.rawValue, clientId: clientId, ext: credentials.exts)
        self.client.subscribe(to: BayeuxChannel.userChannel(userId: userId), clientId: clientId, ext: credentials.exts)
    }
    
    // Publisher for received fayeData
    public var receivedFayeData: AnyPublisher<FayeData, Never> {
        return fayeDataSubject.eraseToAnyPublisher()
    }
    
    deinit {
        cancellableReceiver?.cancel()
    }
}
