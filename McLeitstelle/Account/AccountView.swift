//
//  AccountView.swift
//  McLeitstelle
//
//  Created by Paul on 31.08.23.
//

import SwiftUI
import LssKit

struct AccountView: View {
    @ObservedObject var model: LssModel
    
    var body: some View {
        ZStack {
            List {
                Label("Username: \(model.getUsername() ?? "N/A")", systemImage: "person.circle")
            }
        }
        .navigationTitle("Account")
    }
}

#Preview {
    @StateObject var model = LssModel.preview
    
    return AccountView(model: model)
}
