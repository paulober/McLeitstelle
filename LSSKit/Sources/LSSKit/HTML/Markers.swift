//
// Markers.swift
//
//
//  Created by Paul on 31.08.23.
//

import Foundation

fileprivate let missionMarkerRegex = /missionMarkerAdd\((\s*{[^}]+}\s*)\);/
fileprivate let patientMarkerRegex = /patientMarkerAdd\((\{[^{}]+\})\);/
fileprivate let patientMarkerAddCombinedRegex = /patientMarkerAddCombined\(\s*({[^;]+})\s*\);/
fileprivate let buildingMarkerRegex = /buildingMarkerAdd\((\{[^{}]*\})\);/

/*internal func htmlExtractMarkers(from html: String) -> ([MissionMarker], [PatientMarker], [CombinedPatientMarker], [BuildingMarker]) {
    let missionMarkers = htmlExtractMissionMarkers(from: html)
    let patientMarkers = htmlExtractPatientMarkers(from: html)
    let combinedPatientMarkers = htmlExtractCombinedPatientMarkers(from: html)
    let buildingMarkers = htmlExtractBuildingMarkers(from: html)
    
    return (missionMarkers, patientMarkers, combinedPatientMarkers, buildingMarkers)
}*/

internal func htmlExtractMissionMarkers(from html: String) async -> [MissionMarker] {
    let matches = html.matches(of: missionMarkerRegex)
    
    let decoder = JSONDecoder()
    let missionMarkers: [MissionMarker] = matches.compactMap {
        let jsonData = $0.output.1.data(using: String.Encoding.utf8)
        
        if let data = jsonData {
            do {
                let marker = try decoder.decode(MissionMarker.self, from: data)
                return marker
            } catch let error as DecodingError  {
                print("[LssKit, htmlExtractMissionMarkers] Error decoding MissionMarker: \(error)")
            } catch {}
        }
        
        return nil
    }
    
    return missionMarkers
}

internal func htmlExtractPatientMarkers(from html: String) async -> [PatientMarker] {
    let matches = html.matches(of: patientMarkerRegex)
    
    let decoder = JSONDecoder()
    let patientMarkers: [PatientMarker] = matches.compactMap {
        let jsonData = $0.output.1.data(using: String.Encoding.utf8)
        
        if let data = jsonData {
            do {
                let marker = try decoder.decode(PatientMarker.self, from: data)
                return marker
            } catch {
                print("[LssKit, htmlExtractPatientMarkers] Error decoding PatientMarker.")
            }
        }
        
        return nil
    }
    
    return patientMarkers
}

internal func htmlExtractCombinedPatientMarkers(from html: String) async -> [CombinedPatientMarker] {
    let matches = html.matches(of: patientMarkerAddCombinedRegex)
    
    let decoder = JSONDecoder()
    let combinedPatientMarkers: [CombinedPatientMarker] = matches.compactMap {
        let jsonData = $0.output.1.data(using: String.Encoding.utf8)
        
        if let data = jsonData {
            do {
                let marker = try decoder.decode(CombinedPatientMarker.self, from: data)
                return marker
            } catch {
                print("[LssKit, htmlExtractPatientMarkers] Error decoding CombinedPatientMarker.")
            }
        }
        
        return nil
    }
    
    return combinedPatientMarkers
}

internal func htmlExtractBuildingMarkers(from html: String) async -> [BuildingMarker] {
    let matches = html.matches(of: buildingMarkerRegex)
    
    let decoder = JSONDecoder()
    let buildingMarkers: [BuildingMarker] = matches.compactMap {
        let jsonData = $0.output.1.data(using: String.Encoding.utf8)
        
        if let data = jsonData {
            do {
                let marker = try decoder.decode(BuildingMarker.self, from: data)
                return marker
            } catch let error as DecodingError {
                print("[LssKit, htmlExtractBuildingMarkers] Error decoding BuildingMarker: \(error)")
            } catch {}
        }
        
        return nil
    }
    
    return buildingMarkers
}
