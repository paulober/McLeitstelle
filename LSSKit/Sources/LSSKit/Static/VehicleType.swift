//
//  VehicleType.swift
//
//
//  Created by Paul on 05.09.23.
//

public enum VehicleCategory: UInt16, CaseIterable, Identifiable {
    case fd, fdSpecial, rs, pol, bPol, thw, water, all, onMission
    public var id: Self { self }
}

public enum VehicleType: UInt16, CaseIterable, Identifiable {
    case lf = 0, dlk = 2, elw1 = 3, rw = 4, gwA = 5, gwOil = 10, gwL2Wasser = 11, gwMess = 12, gwGefahrgut = 27, rtw = 28, nef = 29, hlf20 = 30, fuStW = 32, gwHoehe = 33, elw2 = 34, ktw = 38, gkw = 39, mtwTz = 40, mzGw = 41, dekonP = 53, kdowLNA = 55, fwk = 57, mlf = 89, nea50 = 110, gtlf = 121, all = 65535
    public var id: Self { self }
    
    public func asGermanString() -> String {
        switch self {
        case .lf:
            return "Loeschfahrzeug"
        case .dlk:
            return "Drehleiter 25"
        case .elw1:
            return "Einsatzleitwagen Typ 1"
        case .rw:
            return "Ruestwagen"
        case .gwA:
            // GW = Geraetwagen
            return "GW-Atemschutz"
        case .gwOil:
            return "GW-Öl"
        case .gwL2Wasser:
            return "GW-L2-Wasser"
        case .gwMess:
            return "GW-Messtechnik"
        case .gwGefahrgut:
            return "GW-Gefahrgut"
        case .rtw:
            return "Rettungswagen"
        case .nef:
            return "Notarzteinsatzfahrzeug"
        case .hlf20:
            return "HLF-20"
        case .fuStW:
            return "Funkstreifenwagen"
        case .gwHoehe:
            return "GW-Hoehenrettung"
        case .elw2:
            return "ELW 2"
        case .ktw:
            return "Krankentransportwagen"
        case .gkw:
            return "Geraetekraftwagen"
        case .mtwTz:
            return "Mannschaftstransportwagen Technischer Zug"
        case .mzGw:
            return "Mehrzweck Gerätewagen (Fachgruppe Notversorgung)"
        case .dekonP:
            return "Dekon-P"
        case .kdowLNA:
            return "Komandowagen Leitung Notartz"
        case .fwk:
            return "Feuerwehrkran"
        case .mlf:
            return "Mitleres Loeschfahrzeug"
        case .nea50:
            return "NEA50 (Netzersatz)"
        case .gtlf:
            return "Großes Tankloeschfahrzeug"
        case .all:
            return "Alles"
        }
    }
}

public let vehicleTypesPerCategory: [VehicleCategory: [VehicleType]] = [
    VehicleCategory.fd: [.lf, .dlk, .rw, .elw1, .gtlf, .mlf, .hlf20],
    VehicleCategory.fdSpecial: [.gwA, .gwMess, .gwOil, .gwGefahrgut, .gwHoehe, .elw2, .fwk, .dekonP],
    VehicleCategory.rs: [.rtw, .nef, .ktw, .kdowLNA],
    VehicleCategory.pol: [.fuStW],
    VehicleCategory.bPol: [.fuStW],
    VehicleCategory.thw: [.gkw, .mtwTz, .mzGw, .nea50]
]