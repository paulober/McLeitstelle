//
//  ChatMessageRow.swift
//  McLeitstelle
//
//  Created by Paul on 04.09.23.
//

import SwiftUI
import LssKit

struct ChatMessageRow: View {
    @State var userId: Int
    @Binding var chatMessage: ChatMessage
    
    var isOwnMessage: Bool {
        return chatMessage.userId == userId
    }
    
    var body: some View {
        HStack {
            if isOwnMessage {
                Spacer()
            }
            
            VStack(alignment: .trailing) {
                VStack(alignment: .leading) {
                    Text("From: \(chatMessage.username)\n")
                        .foregroundStyle(.secondary)
                    Text(chatMessage.message)
                }
                .padding()
                .foregroundStyle(isOwnMessage ? .white : .black)
                .background(isOwnMessage ? .blue.opacity(0.8) : .gray.opacity(0.15))
                // TODO: deprecated use clipShape
                .cornerRadius(10)
                
                Text("\(chatMessage.date)")
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 10)
            
            if !isOwnMessage {
                Spacer()
            }
        }
    }
}

#Preview {
    @State var message: ChatMessage = ChatMessage.preview
    @State var message2: ChatMessage = ChatMessage.preview2
    
    return ChatMessageRow(userId: message.userId, chatMessage: $message2)
}
