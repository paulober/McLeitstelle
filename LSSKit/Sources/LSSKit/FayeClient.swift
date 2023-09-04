//
//  FayeClient.swift
//  
//
//  Created by Paul on 28.08.23.
//

import Foundation
import Combine

internal class FayeClient: NSObject {
    private var webSocket: URLSessionWebSocketTask?
    private var pingTimer: Timer?
    
    public func authenticate(creds: FayeCredentials) {
        constructCookies(for: lssFayeURL, creds: creds)
    }
    
    public func isConnected() -> Bool {
        return webSocket?.state == .running
    }
    
    public func resume() {
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue())
        webSocket = session.webSocketTask(with: lssFayeURL)
        webSocket?.resume()
    }
    
    public func suspend() {
        webSocket?.suspend()
    }
    
    /**
     Must be executed on main thread
     */
    @objc private func doPing() {
        self.webSocket?.send(.string("[]"), completionHandler: { error in
            if let error = error {
                print("Send error: \(error)")
            }
        })
    }
    
    private func ping() {
        /*webSocket?.sendPing { error in
            if let error = error {
                print("Ping error: \(error)")
            }
        }*/
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
            self.doPing()
        }
    }
    
    private var connectClientId: String?
    
    private func startPingTimer() {
        ping()
        DispatchQueue.main.async {
            self.pingTimer = Timer.scheduledTimer(timeInterval: 13.0, target: self, selector: #selector(self.doPing), userInfo: nil, repeats: true)
        }
    }
    
    private func stopPingTimer() {
        pingTimer?.invalidate()
        pingTimer = nil
    }
    
    func receive() -> AnyPublisher<BMessage?, Never> {
        return Future { promise in
            self.webSocket?.receive(completionHandler: { result in
                switch result {
                case .success(let message):
                    switch message {
                    case .data(let data):
                        print("[LssKit, FayeClient] Got message of type Data: \(data)")
                        promise(.success(nil))
                    case .string(let json):
                        //print("Got json: \(json)")
                        do {
                            let decoder = JSONDecoder()
                            guard let jsonData = json.data(using: .utf8) else {
                                throw BError.dataCorrupted
                            }
                            let messages: [BMessage] = try decoder.decode([BMessage].self, from: jsonData)
                            
                            if messages.count > 0 {
                                promise(.success(messages.first))
                            } else {
                                promise(.success(nil))
                            }
                        } catch let error as DecodingError {
                            print("[LssKit, FayeClient] DecodingError: \(error)")
                        } catch {
                            print("[LssKit, FayeClient] Failed to decode response: \(json)")
                        }
                    @unknown default:
                        break
                    }
                case .failure(let error):
                    print("[WebSocketManger] Received error: \(error)")
                }
                promise(.success(nil))
            })
        }
        .eraseToAnyPublisher()
    }
    
    private func doSendMessage(_ message: BMessage) {
        let encoder = JSONEncoder()
        guard let jsonData = try? encoder.encode([message]) else {
            return
        }
        guard let jsonString = String(data: jsonData, encoding: .utf8) else {
            return
        }
        
        self.webSocket?.send(.string(jsonString), completionHandler: { error in
            if let error = error {
                print("Send error: \(error)")
            }
        })
    }
    
    func sendMessage(_ message: BMessage) {
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
            //self.sendMessage(&message)
            
            self.doSendMessage(message)
        }
    }
    
    func sendHandshake() {
        self.sendMessage(BMessage(channel: .Handshake, version: "1.0", supportedConnectionTypes: [.WebSocket]))
    }
    
    func sendConnect(clientId: String) {
        self.sendMessage(BMessage(channel: .Connect, clientId: clientId, connectionType: .WebSocket))
    }
    
    func subscribe(to channel: String, clientId: String, ext: [String: String]? = nil) {
        self.sendMessage(BMessage(channel: .Subscribe, clientId: clientId, subscription: channel, ext: ext))
    }
    
    deinit {
        stopPingTimer()
        webSocket?.cancel(with: .goingAway, reason: "Unknown".data(using: .utf8))
    }
}

extension FayeClient: URLSessionWebSocketDelegate {
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        print("[LssKit, FayeClient] Did connect to socket")
        startPingTimer()
        sendHandshake()
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        print("[LssKit, FayeClient] Did close connection with reason: \(reason!)")
    }
}
