//
//  FMSStatus.swift
//
//
//  Created by Paul on 09.09.23.
//

public enum FMSStatus: UInt8 {
    case einsatzbereitFunk = 1
    case einsatzbereitWache = 2
    case anfahrtZumEinsatz = 3
    case ankunftAnEinsatz = 4
    case sprechwunsch = 5
    case nichtEinsatzbereit = 6
    case patientAufgenommen = 7
    case amTransportziel = 8
}
