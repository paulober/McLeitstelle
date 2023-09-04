//
//  Coordinate.swift
//  McLeitstelle
//
//  Created by Paul on 03.09.23.
//

import Foundation

struct Coordinate {
    let latitude: Double
    let longitude: Double
}

extension Coordinate {
    func distance(to destination: Coordinate) -> Double {
        let earthRadius: Double = 6371 // Earth's radius in kilometers

        // Convert latitude and longitude from degrees to radians
        let lat1 = self.latitude * .pi / 180
        let lon1 = self.longitude * .pi / 180
        let lat2 = destination.latitude * .pi / 180
        let lon2 = destination.longitude * .pi / 180

        // Haversine formula
        let dlat = lat2 - lat1
        let dlon = lon2 - lon1

        let a = sin(dlat / 2) * sin(dlat / 2) + cos(lat1) * cos(lat2) * sin(dlon / 2) * sin(dlon / 2)
        let c = 2 * atan2(sqrt(a), sqrt(1 - a))
        let distance = earthRadius * c

        return distance // Distance in kilometers
    }
}
