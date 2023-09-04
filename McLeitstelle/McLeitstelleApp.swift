//
//  McLeitstelleApp.swift
//  McLeitstelle
//
//  Created by Paul on 31.08.23.
//

import SwiftUI
import SwiftData
import LssKit

@main
struct McLeitstelleApp: App {
    @StateObject private var model = LssModel()
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView(model: model)
        }
        .modelContainer(sharedModelContainer)
    #if os(macOS)
        .defaultSize(width: 1000, height: 650)
    #endif
        
    #if os(macOS)
        MenuBarExtra {
            ScrollView {
                VStack(spacing: 0) {
                    Text("Zustaendige Notrufe: \(model.missionMarkers.count )\nVerband Notrufe: \(model.missionMarkers.count)")
                }
            }
        } label: {
            Label("Leistelle", systemImage: "sos.circle")
        }
        .menuBarExtraStyle(.menu)
    #endif
    }
}
