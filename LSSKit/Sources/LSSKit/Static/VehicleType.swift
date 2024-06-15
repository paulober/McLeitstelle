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
    case lf20 = 0, lf10 = 1, dlk = 2, elw1 = 3, rw = 4, gwA = 5, gwOil = 10, gwL2Wasser = 11, gwMess = 12, gwGefahrgut = 27, rtw = 28, nef = 29, hlf20 = 30, fuStW = 32, gwHoehe = 33, elw2 = 34, tsfW = 37, ktw = 38, gkw = 39, mtwTz = 40, mzGw = 41, lkwK9 = 42, brmgr = 43, anhDle = 44, mlw = 45, wlf = 46, dekonP = 53, kdowLNA = 55, kdowOrgL = 56, fwk = 57, gwWasserrettung = 64, lkw7Lkr19Tm = 65, anhMzB = 66, anhSchlB = 67, anhMzAB = 68, tkw = 69, naw = 74, flf = 75 , tlf4000 = 87, mlf = 89, hlf10 = 90, anhHund = 92, mtwO = 93, dhuUFueKw = 94, polMotorrad = 95, zivilstreifenwagen = 98, mlw4 = 100, thwAnhSwPu = 101, thwAnh7 = 102, mzGwSB = 109, nea50 = 110, tankwagen = 120, gtlf = 121, lkw7LbmFGrWP = 123, mtwOv = 124, all = 65535
    public var id: Self { self }
    
    public func asGermanString() -> String {
        switch self {
        case .lf20:
            return "Loeschfahrzeug 20"
        case .lf10:
            return "Loeschfahrzeug 10"
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
        case .tsfW:
            return "TSF-W"
        case .ktw:
            return "Krankentransportwagen"
        case .gkw:
            return "Geraetekraftwagen"
        case .mtwTz:
            return "Mannschaftstransportwagen Technischer Zug"
        case .mzGw:
            return "Mehrzweck Gerätewagen (Fachgruppe Notversorgung)"
        case .mlw:
            return "MLW 5"
        case .dekonP:
            return "Dekon-P"
        case .kdowLNA:
            return "Komandowagen Leitung Notartz"
        case .kdowOrgL:
            return "Komandowagen Organisatorischer Leiter"
        case .fwk:
            return "Feuerwehrkran"
        case .lkw7Lkr19Tm:
            return "LKW 7 Lkr 19 tm"
        case .anhMzB:
            return "Mehrzweckboot (MzB) auf Transporthänger (Ben. LKW 7)"
        case .anhSchlB:
            return "Schlauchboot 1 t auf Transporthänger (Ben. LKW 7)"
        case .anhMzAB:
            return "Mehrzweckarbeitsboot mit Bugklappe auf Transport-Anhänger (Ben. LKW 7)"
        case .tkw:
            return "Tauchkraftwagen"
        case .naw:
            return "Notarztwagen"
        case .tlf4000:
            return "TLF 4000"
        case .mlf:
            return "Mitleres Loeschfahrzeug"
        case .hlf10:
            return "Hilfeleistungsloeschfahrzeug 10"
        case .dhuUFueKw:
            return "DHuFüKw"
        case .nea50:
            return "NEA50 (Netzersatz)"
        case .gtlf:
            return "Großes Tankloeschfahrzeug"
        case .mtwOv:
            return "Manschaftstransportwagen des Ortsverbands"
        case .all:
            return "Alles"
        case .brmgr:
            return "Radlader groß"
        case .lkwK9:
            return "Lastkraftwagen-Kipper 9t"
        case .anhHund:
            return "Hunde Anhänger (Ben. MTW-O)"
        case .mtwO:
            return "MTW-O"
        case .flf:
            return "Flugfeldlöschfahrzeug"
        case .zivilstreifenwagen:
            return "Zivilstreifenwagen"
        case .tankwagen:
            return "Tankwagen"
        case .anhDle:
            return "Anhänger Drucklufterzeugung"
        case .gwWasserrettung:
            return "GW-Wasserrettung"
        case .mlw4:
            return "Mannschaftslastwagen Typ IV mit Ladebordwand"
        case .thwAnhSwPu:
            return "Anhänger mit Schmutzwasserkreiselpumpe"
        case .thwAnh7:
            return "Anhänger Plane/Spriegel für Nutzlast, 7t"
        case .mzGwSB:
            return "Mehrzweck-Gerätewagen (SB)"
        case .lkw7LbmFGrWP:
            return "Lastkraftwagen Plane/Spriegel mit Ladebordwand, 7t, Fachgruppe Wasserschaden/Pumpen"
        case .polMotorrad:
            return "Polizeimotorrad"
        case .wlf:
            return "Wechselladerfahrzeug"
        }
    }
    
    public func asGermanStringShort() -> String {
        switch self {
        case .lf20:
            return "LF 20"
        case .lf10:
            return "LF 10"
        case .dlk:
            return "DLK 25"
        case .elw1:
            return "ELW 1"
        case .rw:
            return "RW"
        case .gwA:
            // GW = Geraetwagen
            return "GW-A"
        case .gwOil:
            return "GW-Öl"
        case .gwL2Wasser:
            return "GW-L2-Wasser"
        case .gwMess:
            return "GW-Mess"
        case .gwGefahrgut:
            return "GW-Gefahr"
        case .rtw:
            return "RTW"
        case .nef:
            return "NEF"
        case .hlf20:
            return "HLF-20"
        case .fuStW:
            return "FuStW"
        case .gwHoehe:
            return "GW-Höhe"
        case .elw2:
            return "ELW 2"
        case .tsfW:
            return "TSF-W"
        case .ktw:
            return "KTW"
        case .gkw:
            return "GKW"
        case .mtwTz:
            return "MTW-TZ"
        case .mzGw:
            return "MzGw (Fgr N)"
        case .mlw:
            return "MLW 5"
        case .dekonP:
            return "Dekon-P"
        case .kdowLNA:
            return "KdoW-LNA"
        case .kdowOrgL:
            return "KdoW-OrgL"
        case .fwk:
            return "FWK"
        case .lkw7Lkr19Tm:
            return "LKW 7 Lkr 19 tm"
        case .anhMzB:
            return "AnhMzB"
        case .anhSchlB:
            return "AnhSchlB"
        case .anhMzAB:
            return "AnhMzAB"
        case .tkw:
            return "Tauchkraftwagen"
        case .naw:
            return "NAW"
        case .tlf4000:
            return "TLF-4000"
        case .mlf:
            return "MLF"
        case .hlf10:
            return "HLF-10"
        case .dhuUFueKw:
            return "DHuFüKw"
        case .nea50:
            return "NEA50"
        case .gtlf:
            return "GTLF"
        case .mtwOv:
            return "MTW-OV"
        case .all:
            return "Alles"
        case .brmgr:
            return "BRmGr"
        case .lkwK9:
            return "LKW K9"
        case .anhHund:
            return "AnhHund"
        case .mtwO:
            return "MTW-O"
        case .flf:
            return "FLF"
        case .zivilstreifenwagen:
            return "Zivilstreifenwagen"
        case .tankwagen:
            return "Tankwagen"
        case .anhDle:
            return "Anh DLE"
        case .gwWasserrettung:
            return "GW-Wasser"
        case .mlw4:
            return "MLW 4"
        case .thwAnhSwPu:
            return "Anh SwPu"
        case .thwAnh7:
            return "Anh 7"
        case .mzGwSB:
            return "MzGW SB"
        case .lkw7LbmFGrWP:
            return "LKW 7 Lbw (FGr WP)"
        case .polMotorrad:
            return "Pol Motorrad"
        case .wlf:
            return "WLF"
        }
    }
}

public let vehicleTypesPerCategory: [VehicleCategory: [VehicleType]] = [
    VehicleCategory.fd: [.lf10, .lf20, .dlk, .rw, .elw1, .gtlf, .mlf, .hlf10, .hlf20, .tsfW, .tlf4000, .wlf],
    VehicleCategory.fdSpecial: [.gwL2Wasser, .gwA, .gwMess, .gwOil, .gwGefahrgut, .gwHoehe, .elw2, .fwk, .dekonP, .flf, .gwWasserrettung, .tankwagen],
    VehicleCategory.rs: [.rtw, .nef, .ktw, .kdowLNA, .kdowOrgL, .naw],
    VehicleCategory.pol: [.fuStW, .dhuUFueKw, .zivilstreifenwagen, .polMotorrad],
    VehicleCategory.bPol: [.fuStW, .dhuUFueKw],
    VehicleCategory.thw: [.gkw, .mtwTz, .mtwOv, .mzGw, .nea50, .tkw, .lkw7Lkr19Tm, .anhMzB, .anhSchlB, .anhMzAB, .anhDle, .lkwK9, .brmgr, .mtwO, .anhHund, .mlw, .mlw4, .thwAnh7, .thwAnhSwPu, .lkw7LbmFGrWP, .mzGwSB]
]

public func isVehicleTypeInCategory(_ rawType: UInt16, category: VehicleCategory) -> Bool {
    if let type = VehicleType(rawValue: rawType),
        let vehiclesInCategory = vehicleTypesPerCategory[category] {
        return category == .all || category == .onMission || vehiclesInCategory.contains(type)
    }
    
    return category == .all || category == .onMission
}
