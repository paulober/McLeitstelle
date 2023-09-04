//
//  VehicleDrives.swift
//  
//
//  Created by Paul on 31.08.23.
//

import Foundation

//vehicleDrive\((\{[^{}]+\})\);
fileprivate let vehicleDriveRegex = /vehicleDrive\((\{.*?\})\);/

internal func htmlExtractVehicleDrives(from html: String) -> [VehicleDrive] {
    let matches = html.matches(of: vehicleDriveRegex)
    
    let decoder = JSONDecoder()
    let vehicleDrives: [VehicleDrive] = matches.compactMap {
        let jsonData = $0.output.1.data(using: String.Encoding.utf8)
        
        if let data = jsonData {
            do {
                let vehicleDrive = try decoder.decode(VehicleDrive.self, from: data)
                return vehicleDrive
            } catch let error as DecodingError {
                Swift.print("[LssKit, htmlVehicleDriveExtraction] Error decoding VehicleDrive: \(error)")
            } catch {}
        }
        
        return nil
    }
    
    return vehicleDrives
}
