//
//  VehicleTypeRow.swift
//  McLeitstelle
//
//  Created by Paul on 28.09.23.
//

import SwiftUI
import LssKit

struct VehicleTypeRow: View {
    @ObservedObject var model: LssModel
    @State var vehicleType: VehicleType
    
    var imageURL: URL {
        if let urlString = vehicleImageUrlStrings[vehicleType.rawValue < vehicleImageUrlStrings.count ? Int(vehicleType.rawValue) : 0]?[0],
            let url = URL(string: urlString) {
            return url
        } else {
            return URL(string: "https://leitstellenspiel.s3.amazonaws.com/vehicle_graphic_images/images/000/029/167/original/LF16FF0.png?1453040639")!
        }
    }
    
    var vehiclesCount: Int {
        model.vehicles.filter { v in
            v.vehicleType == vehicleType.rawValue && (v.fmsShow == 2 || (v.fmsShow == 4 && v.queuedMissionId == nil))
        }.count
    }
    
    var body: some View {
        HStack(alignment: .center) {
            AsyncImage(url: imageURL, scale: 1.3)
                .frame(maxHeight: 40)
                .scaledToFit()
                .padding(.top, 2)
                .padding(.bottom, 10)
                
            /**
             .padding(2)
             .frame(width: 65, height: 40)
             .padding(.vertical)
             .padding(.leading, 25)
             */
            
            VStack {
                #if os(iOS)
                Text(vehicleType.asGermanStringShort())
                    .typesettingLanguage(Locale.Language(languageCode: Locale.LanguageCode.german), isEnabled: true)
                    .font(.title3)
                #else
                Text(vehicleType.asGermanString())
                    .typesettingLanguage(Locale.Language(languageCode: Locale.LanguageCode.german), isEnabled: true)
                    .font(.title3)
                #endif
                
                Spacer()
            }
            .padding(.vertical)
            
            Spacer()
            
            VStack(alignment: .center) {
                Text("\(vehiclesCount)")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Available Units")
                    .font(.caption2)
            }
            .padding(3)
            .background(.thickMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 4))
            .padding(.vertical, 5)
        }
        .frame(maxHeight: 70)
    }
}

#Preview {
    @StateObject var model = LssModel.preview
    
    return VehicleTypeRow(model: model, vehicleType: .brmgr)
        .background(Color.green)
}
