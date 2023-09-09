//
//  FinancesView.swift
//  McLeitstelle
//
//  Created by Paul on 31.08.23.
//

import SwiftUI
import LssKit

struct FinancesView: View {
    @ObservedObject var model: LssModel
    
    var body: some View {
        ZStack {
            List {
                Button {
                    Task {
                        await model.getDailyBonus(day: 1)
                    }
                } label: {
                    Label("Day 1", systemImage: "dollarsign.arrow.circlepath")
                }
                Button {
                    Task {
                        await model.getDailyBonus(day: 2)
                    }
                } label: {
                    Label("Day 2", systemImage: "dollarsign.arrow.circlepath")
                }
                Button {
                    Task {
                        await model.getDailyBonus(day: 3)
                    }
                } label: {
                    Label("Day 3", systemImage: "dollarsign.arrow.circlepath")
                }
                Button {
                    Task {
                        await model.getDailyBonus(day: 4)
                    }
                } label: {
                    Label("Day 4", systemImage: "dollarsign.arrow.circlepath")
                }
                
                Button {
                    Task {
                        await model.getDailyBonus(day: 5)
                    }
                } label: {
                    Label("Day 5", systemImage: "dollarsign.arrow.circlepath")
                }
                
                Button {
                    Task {
                        await model.getDailyBonus(day: 6)
                    }
                } label: {
                    Label("Day 6", systemImage: "dollarsign.arrow.circlepath")
                }
                
                Button {
                    Task {
                        await model.getDailyBonus(day: 7)
                    }
                } label: {
                    Label("Day 7", systemImage: "dollarsign.arrow.circlepath")
                }
            }
        }
        .navigationTitle("Finances")
    }
}

#Preview {
    @StateObject var model = LssModel.preview
    
    return FinancesView(model: model)
}
