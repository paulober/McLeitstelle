//
//  RadioMessageRow.swift
//  McLeitstelle
//
//  Created by Paul on 09.09.23.
//

import SwiftUI
import LssKit

fileprivate let fmsTextSprechwunsch = "Sprechwunsch"

struct RadioMessageRow: View {
    @State var message: RadioMessage
    
    var body: some View {
        HStack(alignment: .center) {
            VStack {
                Image(systemName: "light.beacon.max.fill")
                    .padding(.top)
                    .symbolRenderingMode(.multicolor)
                Spacer()
            }
            
            VStack {
                if message.fms == FMSStatus.sprechwunsch.rawValue {
                    Text(message.caption)
                        .font(.callout.italic())
                        .foregroundStyle(.red)
                } else {
                    Text(message.caption)
                        .font(.callout)
                }
                
                Text(message.fmsText)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
    }
}

#Preview {
    RadioMessageRow(message: .preview)
}
