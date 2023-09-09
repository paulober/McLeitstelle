//
//  ContentView.swift
//  McLeitstelle
//
//  Created by Paul on 31.08.23.
//

import SwiftUI
import SwiftData
import LssKit

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
    
    @ObservedObject var model: LssModel
    
    @State private var navSelection: Panel? = Panel.dashboard
    @State private var path = NavigationPath()

    var body: some View {
        if !model.isSignedIn {
            LoginView(model: model)
        } else {
            NavigationSplitView {
                Sidebar(model: model, selection: $navSelection)
                    .toolbar {
                        ToolbarItem {
                            Button {
                                
                                if model.isConnected() {
                                    model.disconnect()
                                } else {
                                    if model.isSignedIn {
                                        model.connect()
                                    }
                                }
                            } label: {
                                Label("Connect", systemImage: model.isConnected() ? "link.icloud" : "icloud.slash")
                            }
                        }
                        /*
                        #if os(iOS)
                        ToolbarItem(placement: .navigationBarTrailing) {
                            EditButton()
                        }
                        #endif
                        */
                    }
            } detail: {
                NavigationStack(path: $path) {
                    DetailColumn(selection: $navSelection, model: model)
                }
            }
            .onChange(of: navSelection, initial: false) {
                path.removeLast(path.count)
            }
            #if os(macOS)
            .frame(minWidth: 600, minHeight: 450)
            #elseif os(iOS)
            .tint(.red)
            #endif
        }
    }
    
    private func addItem() {
        withAnimation {
            let newItem = Item(timestamp: Date())
            modelContext.insert(newItem)
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
    }
}

#Preview {
    @StateObject var model = LssModel.preview
    
    return ContentView(model: model)
        .modelContainer(for: Item.self, inMemory: true)
}
