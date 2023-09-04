//
//  DashboardView.swift
//  McLeitstelle
//
//  Created by Paul on 31.08.23.
//

import SwiftUI

struct DashboardView: View {
    @Binding var navigationSelection: Panel?
    
    #if os(iOS)
    @Environment(\.horizontalSizeClass) private var sizeClass
    #endif
    
    var body: some View {
        ZStack {
            Text("Overview")
        }
        .navigationTitle("Dashboard")
    }
}

#Preview {
    struct Preview: View {
        @State private var navigationSelection: Panel? = Panel.dashboard
        var body: some View {
            DashboardView(navigationSelection: $navigationSelection)
        }
    }
    
    return Preview()
}
