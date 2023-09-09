//
//  VehicleRowView.swift
//  McLeitstelle
//
//  Created by Paul on 08.09.23.
//

import SwiftUI
import LssKit

struct VehicleRowView: View {
    var vContainer: VehicleContainer
    var imageURL: URL
    
    var body: some View {
        #if os(iOS)
        HStack {
            VStack {
                HStack {
                    //Label(vContainer.vehicle.caption, systemImage: "character.textbox")
                    Text(vContainer.vehicle.caption)
                    Spacer()
                }
                .frame(alignment: .leading)
                .padding(.bottom, 5)
                
                /*Label("FMS: \(vContainer.vehicle.fmsReal.formatted())", systemImage: "antenna.radiowaves.left.and.right.circle")
                    .monospacedDigit()
                    //.padding(.trailing, 2)
                    .padding(.bottom, 2)*/
                HStack {
                    Label("Distance: \(String(format: "%.2f km", vContainer.distanceInKm))", systemImage: "road.lanes")
                        .monospacedDigit()
                        .frame(alignment: .leading)
                    Spacer()
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.trailing)
            
            AsyncImage(url: imageURL, scale: 1.2)
                .padding(2)
                .frame(width: 70, height: 40)
                .padding(.vertical)
                .padding(.trailing, 2)
        }
        #else
        HStack {
            //let iconShape = RoundedRectangle(cornerRadius: 4, style: .continuous)
            AsyncImage(url: imageURL, scale: 1.6)
                .padding(2)
                .frame(width: 50, height: 30)
                .padding(.bottom, 5)
                /*.background(in: iconShape)
                .overlay {
                    iconShape.strokeBorder(.quaternary, lineWidth: 0.5)
                }*/
            
            Text(vContainer.vehicle.caption)
        }
        .padding(.vertical, 5)
        #endif
    }
}

#Preview {
    //URL(string: "https://www.leitstellenspiel.de/images/vehicles/green_car.png")
    VehicleRowView(vContainer: VehicleContainer(vehicle: .preview, distanceInKm: 23.4), imageURL: URL(string: "https://leitstellenspiel.s3.amazonaws.com/vehicle_graphic_images/images/000/029/167/original/LF16FF0.png?1453040639")!)
}
