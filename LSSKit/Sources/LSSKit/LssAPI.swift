//
//  LssAPI.swift
//
//
//  Created by Paul on 29.08.23.
//

import Combine
import Darwin

/**
 A communication wrapper for the Leistellenspiel.de
 */
public class LssAPI {
    private let client: FayeClient
    private var clientId: String?
    private var cancellableReceiver: AnyCancellable?
    public var credentials: FayeCredentials
    
    private var fayeDataSubject = PassthroughSubject<FayeData, Never>()
    
    public init(creds: inout FayeCredentials) {
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
    public func connect() async -> LssDTOCollection {
        var initialData: LssDTOCollection = LssDTOCollection()
        
        // set initial cookies for index request
        constructCookies(for: lssBaseURL, creds: credentials)
        let indexHTML = await downloadIndexHTML(from: lssBaseURL, creds: &credentials)
        if let indexHTML = indexHTML {
            let scriptsHTML = htmlReduceToScripts(from: indexHTML)
            htmlExtractUserDetails(from: scriptsHTML, creds: &credentials)
            // reconstruct cookies with updated creds
            constructCookies(for: lssBaseURL, creds: credentials)
            // TODO: find better solution cause this is also done in FayeClient.init
            client.authenticate(creds: credentials)
            
            initialData.radioMessages = htmlExtractRadioMessages(from: scriptsHTML)
            initialData.chatMessages = htmlExtractAllianceChats(from: scriptsHTML)
            (initialData.missionMarkers, initialData.patientMarkers, initialData.buildingMarkers) = htmlExtractMarkers(from: scriptsHTML)
            initialData.vehicleDrives = htmlExtractVehicleDrives(from: scriptsHTML)
        } else {
            // TODO: better handling of this case because then creds.exts are not filled
            print("[LssKit] Error, unable to retrieve Lss WebApp!")
        }
        
        client.resume()
        startReceivingMessages()
        
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
