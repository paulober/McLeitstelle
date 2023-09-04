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
        model.getUserID()
    }
    
    var body: some View {
        VStack {
            ScrollView {
                ForEach(model.chatMessages, id: \.hashValue) { message in
                    ChatMessageRow(userId: userId, chatMessage: model.chatMessageBinding(for: message.hashValue))
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
    }
    
    private func sendMessage() {
        Task {
            let result = await model.sendAllianceChatMessageAsync(message: newMessageText, missionId: nil)
            if result {
                print("Message send successfully")
            }
        }
    }
}

#Preview {
    @StateObject var model = LssModel.preview
    
    return AllianceChatView(model: model)
}
