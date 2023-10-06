//
//  FMSStatus.swift
//
//
//  Created by Paul on 09.09.23.
//

public enum FMSStatus: UInt8, CaseIterable {
    /// FMS = 1
    case einsatzbereitFunk = 1
    /// FMS = 2
    case einsatzbereitWache = 2
    /// FMS = 3
    case anfahrtZumEinsatz = 3
    /// FMS = 4
    case ankunftAnEinsatz = 4
    /// FMS = 5
    case sprechwunsch = 5
    /// FMS = 6
    case nichtEinsatzbereit = 6
    /// FMS = 7
    case patientAufgenommen = 7
    /// FMS = 8
    case amTransportziel = 8
}
