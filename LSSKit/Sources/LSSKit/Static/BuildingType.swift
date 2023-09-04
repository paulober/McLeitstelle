//
//  Types.swift
//
//
//  Created by Paul on 01.09.23.
//

public enum LssBuildingType: UInt8 {
    case feuerwache = 0
    case feuerwehrschule = 1
    case rettungswache = 2
    case rettungsschule = 3
    case hospital = 4
    case notarzthubschrauberlandeplatz = 5
    case polizeiwache = 6
    case leitstelle = 7
    case polizeischule = 8
    case thw = 9
    case thwBundesschule = 10
    case bereitsschaftspolizei = 11
    case seg = 12
    case polizeihubschrauberlandeplatz = 13
    case bereitstellungsraum = 14
    case wasserrettung = 15
    case polizeizelle = 16
    case polizeisondereinheiten = 17
    case feuerwacheKleinwache = 18
    case polizeiwacheKleinwache = 19
    case rettungswacheKleinwache = 20
    case rescueDogUnit = 21
    case complex = 22
    case complexSmall = 23
    
    public func asGermanString() -> String {
        switch self {
        case .feuerwache:
            return "Feuerwache"
        case .feuerwehrschule:
            return "Feuerwehrschule"
        case .rettungswache:
            return "Rettungswache"
        case .rettungsschule:
            return "Rettungsschule"
        case .hospital:
            return "Hospital"
        case .notarzthubschrauberlandeplatz:
            return "Notarzthubschrauberlandeplatz"
        case .polizeiwache:
            return "Polizeiwache"
        case .leitstelle:
            return "Leitstelle"
        case .polizeischule:
            return "Polizeischule"
        case .thw:
            return "THW"
        case .thwBundesschule:
            return "THW Bundesschule"
        case .bereitsschaftspolizei:
            return "Bereitschaftspolizei"
        case .seg:
            return "SEG"
        case .polizeihubschrauberlandeplatz:
            return "Polizeihubschrauberlandeplatz"
        case .bereitstellungsraum:
            return "Bereitstellungsraum"
        case .wasserrettung:
            return "Wasserrettung"
        case .polizeizelle:
            return "Polizeizelle"
        case .polizeisondereinheiten:
            return "Polizeisondereinheiten"
        case .feuerwacheKleinwache:
            return "Feuerwache Kleinwache"
        case .polizeiwacheKleinwache:
            return "Polizeiwache Kleinwache"
        case .rettungswacheKleinwache:
            return "Rettungswache Kleinwache"
        case .rescueDogUnit:
            return "Rescue Dog Unit"
        case .complex:
            return "Komplex"
        case .complexSmall:
            return "Komplex (klein)"
        }
    }
}

/**
 Value of LssBuildingType is the index of its icon path in this array.
 */
public let lssBuildingIconPaths = [
    "/images/building_fire_other.png",
    "/images/building_fireschool_other.png",
    "/images/building_rescue_station_other.png",
    "/images/building_rettungsschule_other.png",
    "/images/building_hospital_other.png",
    "/images/building_helipad_other.png",
    "/images/building_polizeiwache_other.png",
    "/images/building_leitstelle_other.png",
    "/images/building_polizeischule_other.png",
    "/images/building_thw_other.png",
    "/images/building_thw_school_other.png",
    "/images/building_bereitschaftspolizei_other.png",
    "/images/building_seg_other.png",
    "/images/building_helipad_polizei_other.png",
    "/images/building_bereitstellungsraum_other.png",
    "/images/building_wasserwacht_other.png",
    "/images/building_polizeiwache_other.png",
    "/images/building_polizeisondereinheiten_other.png",
    "/images/building_fire_other.png",
    "/images/building_polizeiwache_other.png",
    "/images/building_rescue_station_other.png",
    "/images/building_rescue_dog_unit_other.png",
    "/images/building_complex_other.png",
    "/images/building_complex_other.png",
]
