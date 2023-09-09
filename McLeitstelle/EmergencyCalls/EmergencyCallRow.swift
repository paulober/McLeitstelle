//
//  EmergencyCallRow.swift
//  McLeitstelle
//
//  Created by Paul on 08.09.23.
//

import SwiftUI
import LssKit

struct EmergencyCallRow: View {
    var missionMarker: MissionMarker
    var imageURL: URL
    
    var body: some View {
        HStack {
            let iconShape = RoundedRectangle(cornerRadius: 4, style: .continuous)
            AsyncImage(url: imageURL, scale: 1.1)
                .padding(2)
                #if os(iOS)
                .frame(width: 40, height: 40)
                #else
                .frame(width: 35, height: 34)
                #endif
                .background(in: iconShape)
                .overlay {
                    iconShape.strokeBorder(.quaternary, lineWidth: 1.5)
                }
            
            Text(missionMarker.caption)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    EmergencyCallRow(missionMarker: .preview, imageURL: URL(string: "https://www.leitstellenspiel.de/images/\(MissionMarker.preview.icon).png")!)
}
