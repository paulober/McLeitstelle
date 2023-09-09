//
//  AllianceChatView.swift
//  McLeitstelle
//
//  Created by Paul on 04.09.23.
//

import SwiftUI
import LssKit

struct AllianceChatView: View {
    @ObservedObject var model: LssModel
    @State var newMessageText: String = ""
    
    var userId: Int {
        return model.getUserID()
    }
    
    var username: String {
        return model.getUsername() ?? ""
    }
    
    var body: some View {
        VStack {
            ScrollView {
                ForEach(model.chatMessages, id: \.hashValue) { message in
                    ChatMessageRow(missionMarkers: $model.missionMarkers, userId: userId, chatMessage: model.chatMessageBinding(for: message.hashValue))
                }
                .rotationEffect(.degrees(180))
            }
            .rotationEffect(.degrees(180))
            
            HStack(alignment: .center) {
                TextField("Type something", text: $newMessageText)
                    .textFieldStyle(.plain)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    // TODO: deprecated use clipshape
                    .cornerRadius(10)
                    .onSubmit {
                        sendMessage()
                    }
                
                Button {
                    sendMessage()
                } label: {
                    Image(systemName: "paperplane.fill")
                }
                .buttonStyle(.plain)
                .foregroundStyle(.green)
                .font(.system(size: 26))
                .padding(.horizontal, 10)
            }
            .padding()
        }
        .navigationTitle("Alliance (ger. Verband) Chat")
        .navigationDestination(for: MissionMarker.ID.self) { id in
            EmergencyCallDetailsView(model: model, mission: model.missionBinding(for: id))
        }
    }
    
    private func sendMessage() {
        Task {
            let result = await model.sendAllianceChatMessageAsync(message: newMessageText, missionId: nil)
            if result {
                newMessageText = ""
                print("Message send successfully")
            }
        }
    }
}

#Preview {
    @StateObject var model = LssModel.preview
    
    return AllianceChatView(model: model)
}
