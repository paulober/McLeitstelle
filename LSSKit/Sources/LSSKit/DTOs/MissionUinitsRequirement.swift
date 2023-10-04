//
//  File.swift
//  
//
//  Created by Paul on 25.09.23.
//

/// NO official DTO used by LSS
/// r = prefix for required
public struct MissionUinitsRequirement {
    public var rLF: UInt16 = 0
    public var minFirefighters: UInt16 = 0
    public var rWater: UInt32?
    public var waterToDrain: UInt32?
    public var rDLK: UInt16 = 0
    public var rELW1: UInt8 = 0
    public var rELW2: UInt8 = 0
    public var rFWK: UInt16 = 0
    public var rGWa: UInt16 = 0
    public var rDekonP: UInt16 = 0
    public var rGWg: UInt16 = 0
    public var rGWh: UInt16 = 0
    public var rGWm: UInt16 = 0
    public var rGWo: UInt16 = 0
    public var rRW: UInt16 = 0
    public var rSchlauchwagen: UInt16 = 0
    public var rFlf: UInt16 = 0
    public var rRettungstreppen: UInt16 = 0
    public var rULF: UInt16 = 0
    public var rTurboloescher: UInt16 = 0
    public var rTeleskopmasten: UInt16 = 0
    public var rGWw: UInt16 = 0
    public var rPol: UInt16 = 0
    public var minPoliceOfficers: UInt16 = 0
    public var possiblePrissoners: UInt16 = 0
    public var rPoliceHelicopters: UInt16 = 0
    public var rPoliceMotorbikes: UInt16 = 0
    public var rDhufukw: UInt16 = 0
    public var rCivilVehicles: UInt16 = 0
    public var rRadioPolDienstgruppenleitung: UInt16 = 0
    public var rFukw: UInt16 = 0
    public var rLeBefKw: UInt16 = 0
    public var rGruKw: UInt16 = 0
    public var rSek: UInt16 = 0
    public var rMek: UInt16 = 0
    public var rWasserwerfer: UInt16 = 0
    public var rGWt: UInt16 = 0
    public var rBoats: UInt16 = 0
    public var possiblePatients: UInt16 = 0
    /// in percent
    public var patientTransportProbability: UInt8?
    /// id of hospital department type
    // TODO: create enum for the ", " separated list of fachrichtungen
    public var hospitalDepartmentIds: String?
    /// in percent
    public var nefPosibility: UInt8?
    /// in percent
    public var rthPosibility: UInt8?
    public var rTHW_GKW: UInt16 = 0
    public var rTHW_MtwTz: UInt16 = 0
    public var rTHW_MzGwFGrN: UInt16 = 0
    public var rTHW_BRmGr: UInt16 = 0
    public var rTHW_LKWk9: UInt16 = 0
    public var rTHW_AnhDle: UInt16 = 0
    public var rRescueDogUnits: UInt16 = 0
    public var rFireExtinguishingPumps: UInt16 = 0
    public var rDirtyWaterPumps: UInt16 = 0
    public var rNEA50: UInt16 = 0
    public var rNEA200: UInt16 = 0
    public var rMzGwSB: UInt16 = 0
    public var rVents: UInt16 = 0
    
    public var polMotorbikesCanReplaceCars: Bool?
    
    public func howMany(of type: VehicleType) -> UInt16 {
        switch type {
        case .lf20, .lf10:
            return rLF
        case .dlk:
            return rDLK
        case .elw1:
            return UInt16(rELW1)
        case .rw:
            return rRW
        case .gwA:
            return rGWa
        case .gwOil:
            return rGWo
        case .gwL2Wasser:
            return rFireExtinguishingPumps
        case .gwMess:
            return rGWm
        case .gwGefahrgut:
            return rGWg
        case .rtw:
            return rRW
        case .nef:
            return nefPosibility != nil && nefPosibility! > 40 ? 1 : 0
        case .hlf20:
            return rLF + rRW
        case .fuStW:
            return rPol
        case .gwHoehe:
            return rGWh
        case .elw2:
            return UInt16(rELW2)
        case .tsfW:
            return UInt16(rTurboloescher)
        case .ktw:
            return patientTransportProbability == 100 ? 1 : 0
        case .gkw:
            return rTHW_GKW
        case .mtwTz:
            return rTHW_MtwTz
        case .mzGw:
            return rTHW_MzGwFGrN
        case .lkwK9:
            return rTHW_LKWk9
        case .brmgr:
            return rTHW_BRmGr
        case .dekonP:
            return rDekonP
        case .kdowLNA:
            return 0
        case .kdowOrgL:
            return 0
        case .fwk:
            return rFWK
        case .lkw7Lkr19Tm:
            return rTHW_LKWk9
        case .anhMzB:
            return rBoats
        case .anhSchlB:
            return rBoats
        case .anhMzAB:
            return rBoats
        case .tkw:
            return 0
        case .naw:
            return (patientTransportProbability != nil && patientTransportProbability! > 40 && nefPosibility != nil && nefPosibility! > 40) ? 1 : 0
        case .tlf4000:
            return rWater != nil ? UInt16(rWater! / 4000) : 0
        case .mlf:
            return rLF
        case .hlf10:
            return rLF + rRW
        case .dhuUFueKw:
            return rDhufukw
        case .nea50:
            return rNEA50
        case .gtlf:
            return rLF
        case .mtwOv:
            return 0
        case .all:
            return 0
        }
    }
}
