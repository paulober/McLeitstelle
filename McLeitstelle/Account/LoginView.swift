//
//  AccountLoginView.swift
//  McLeitstelle
//
//  Created by Paul on 03.09.23.
//

import SwiftUI
import LssKit

struct LoginView: View {
    @ObservedObject var model: LssModel
    
    @State private var emailOrUsername: String = ""
    @State private var password: String = ""
    
    var signInBlocked: Bool {
        return emailOrUsername.count < 6 || password.count < 5
    }
    
    var body: some View {
        VStack {
            Text("McLeitstelle")
                .foregroundStyle(.indigo)
                .font(.title)
                .fontWeight(.bold)
            
            Spacer()
            
            VStack(spacing: 15) {
                TextField("E-Mail or Username", text: $emailOrUsername)
                    .autocorrectionDisabled()
                    .textContentType(.emailAddress)
                
                Divider()
                    .padding(.horizontal, -15)
                
                SecureField("Password", text: $password)
                    .autocorrectionDisabled()
                    .textContentType(.password)
            }
            .padding()
            .textFieldStyle(.plain)
            .overlay(RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray, lineWidth: 0.3)
            )
            
            // TODO: E-Mail/Username max length 50 and Password max length 50
            
            Spacer()
            
            Button {
                Task {
                    await signIn()
                }
            } label: {
                Label("Login...", systemImage: "key")
                    .font(.system(size: 24, weight: .semibold, design: .default))
            }
            #if os(macOS)
            .buttonStyle(.link)
            #else
            .buttonStyle(.plain)
            #endif
            .disabled(signInBlocked)
        }
        .frame(minWidth: 300, maxWidth: 300, minHeight: 250, maxHeight: 250)
        .padding()
    }
    
    func signIn() async {
        if await model.auth(emailOrUsername: emailOrUsername, password: password) {
            print("SignIn was successfull")
        } else {
            print("SignIn failed")
        }
    }
}

#Preview {
    @StateObject var model = LssModel.preview
    
    return LoginView(model: model)
}
