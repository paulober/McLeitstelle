//
//  MissionEinsatzDetails.swift
//
//
//  Created by Paul on 08.09.23.
//

/// NOTE: not an official DTO used by Lss
public struct MissionEinsatzDetails {
    public var rewardAndPrerequisites: [String: String] = [:]
    public var requiredAssets: [String: UInt16] = [:]
    public var additionalDetails: [String: String] = [:]
}

private extension UInt16 {
    func asUInt32() -> UInt32? {
        return UInt32(self)
    }
    
    func asUInt8() -> UInt8 {
        return UInt8(self)
    }
}

public extension MissionEinsatzDetails {
    func scan() -> MissionUinitsRequirement {
        var units = MissionUinitsRequirement()
        
        units.rLF = requiredAssets["Benötigte Löschfahrzeuge"] ?? 0
        units.minFirefighters = requiredAssets["Mindestanzahl Feuerwehrleute"] ?? 0
        if let rWater = requiredAssets["Benötigte Wasser"] {
            units.rWater = UInt32(rWater)
        }
        if let waterToDrain = additionalDetails["Wasser abzupumpen (in Litern)"] {
            units.waterToDrain = UInt32(waterToDrain)
        }
        if let canReplace = additionalDetails["Polizeimotorrad kann Streifenwagen ersetzen"] {
            units.polMotorbikesCanReplaceCars = canReplace == "Ja"
        }
        units.rDLK = requiredAssets["Benötigte Drehleitern"] ?? 0
        units.rELW1 = requiredAssets["Benötigte ELW 1"]?.asUInt8() ?? 0
        units.rELW2 = requiredAssets["Benötigte ELW 2"]?.asUInt8() ?? 0
        units.rFWK = requiredAssets["Benötigte FWK"] ?? 0
        units.rGWa = requiredAssets["Benötigte GW-A"] ?? 0
        units.rDekonP = requiredAssets["Benötigte Dekon-P"] ?? 0
        units.rGWg = requiredAssets["Benötigte GW-Gefahrgut"] ?? 0
        units.rGWh = requiredAssets["Benötigte GW-Höhenrettung"] ?? 0
        units.rGWm = requiredAssets["Benötigte GW-Messtechnik"] ?? 0
        units.rGWo = requiredAssets["Benötigte GW-Öl"] ?? 0
        units.rRW = requiredAssets["Benötigte Rüstwagen"] ?? 0
        units.rSchlauchwagen = requiredAssets["Benötigte Schlauchwagen (GW-L2 Wasser, SW 1000, SW 2000 oder Ähnliches)"] ?? 0
        units.rFlf = requiredAssets["Benötigte Flugfeldlöschfahrzeuge"] ?? 0
        units.rRettungstreppen = requiredAssets["Benötigte Rettungstreppen"] ?? 0
        units.rULF = requiredAssets["Benötigte ULF mit Löscharm"] ?? 0
        units.rTurboloescher = requiredAssets["Benötigte Turbolöscher"] ?? 0
        units.rTeleskopmasten = requiredAssets["Benötigte Teleskopmasten"] ?? 0
        units.rGWw = requiredAssets["Benötigte GW-Wasserrettung"] ?? 0
        units.rPol = requiredAssets["Benötigte Streifenwagen"] ?? 0
        units.minPoliceOfficers = requiredAssets["Mindestanzahl Polizeibeamte"] ?? 0
        units.possiblePrissoners = requiredAssets["Mögliche Gefangene"] ?? 0
        units.rPoliceHelicopters = requiredAssets["Benötigte Polizeihubschrauber"] ?? 0
        units.rPoliceMotorbikes = requiredAssets["Benötigte Polizeimotorräder"] ?? 0
        units.rDhufukw = requiredAssets["Benötigte DHuFüKw"] ?? 0
        units.rCivilVehicles = requiredAssets["Benötigte Zivilfahrzeuge"] ?? 0
        units.rRadioPolDienstgruppenleitung = requiredAssets["Benötigte Funkstreifenwagen (Dienstgruppenleitung)"] ?? 0
        units.rFukw = requiredAssets["Benötigte FüKw"] ?? 0
        units.rLeBefKw = requiredAssets["Benötigte leBefKw"] ?? 0
        units.rGruKw = requiredAssets["Benötigte GruKw"] ?? 0
        units.rSek = requiredAssets["Benötigte SEK"] ?? 0
        units.rMek = requiredAssets["Benötigte MEK"] ?? 0
        units.rWasserwerfer = requiredAssets["Benötigte Wasserwerfer"] ?? 0
        units.rGWt = requiredAssets["Benötigte GW-Transport"] ?? 0
        units.rBoats = requiredAssets["Benötigte Boote"] ?? 0
        units.possiblePatients = UInt16(additionalDetails["Maximale Patientenanzahl"] ?? "0") ?? 0
        if let patientTransportProbability = additionalDetails["Wahrscheinlichkeit, dass ein Patient transportiert werden muss"] {
            units.patientTransportProbability = UInt8(patientTransportProbability)
        }
        units.hospitalDepartmentIds = additionalDetails["Fachrichtung für Patienten"]
        if let nefPosibility = additionalDetails["NEF Anforderungswahrscheinlichkeit"] {
            units.nefPosibility = UInt8(nefPosibility)
        }
        if let rthPosibility = additionalDetails["RTH-Wahrscheinlichkeit"] {
            units.rthPosibility = UInt8(rthPosibility)
        }
        units.rTHW_GKW = requiredAssets["Benötigte GKW"] ?? 0
        units.rTHW_MtwTz = requiredAssets["Benötigte MTW-TZ"] ?? 0
        units.rTHW_MzGwFGrN = requiredAssets["Benötigte MzGw (FGr N)"] ?? 0
        units.rTHW_BRmGr = requiredAssets["Benötigte BRmGr"] ?? 0
        units.rTHW_LKWk9 = requiredAssets["Benötigte LKW K9"] ?? 0
        units.rTHW_AnhDle = requiredAssets["Benötigte Anh-Dle"] ?? 0
        units.rRescueDogUnits = requiredAssets["Benötigte Rettungshundeeinheiten"] ?? 0
        units.rFireExtinguishingPumps = requiredAssets["Benötigte Feuerlöschkreiselpumpen"] ?? 0
        units.rDirtyWaterPumps = requiredAssets["Benötigte Schmutzwasserpumpen"] ?? 0
        units.rNEA50 = requiredAssets["Benötigte NEA50"] ?? 0
        units.rNEA200 = requiredAssets["Benötigte NEA200"] ?? 0
        units.rMzGwSB = requiredAssets["Benötigte MzGw SB"] ?? 0
        units.rVents = requiredAssets["Benötigte Lüfter"] ?? 0
        
        return units
    }
}
