//
//  LssMission.swift
//
//
//  Created by Paul on 02.09.23.
//

public struct LssAdditional: Codable, Hashable {
    public let expansionMissionsIds: [Int]?
    public let followupMissionsIds: [Int]?
    public let allowRwInsteadOfLf: Bool?
    public let allowGwoilInsteadOfLf: Bool?
    public let allowArffInsteadOfLf: Bool?
    public let onlyAllianceMission: Bool?
    public let maxPossiblePrisoners: Int?
    public let needK9OnlyIfGuardDogsPresent: Bool?
    public let allowDroneInsteadOfInvestigation: Bool?
    public let subsequentMissionsIds: [Int]?
    public let subsequentMissionOnly: Bool?
    public let needTrafficCarOnlyIfPresent: Bool?
    public let needElwPoliceOnlyIfPresent: Bool?
    public let needBombOnlyIfPresent: Bool?
    public let needPoliceHorseOnlyIfPresent: Bool?
    public let needBikePoliceOnlyIfPresent: Bool?
    public let allowTrafficCarInsteadOfFustw: Bool?
    public let needHelicopterBucketOnlyIfPresent: Bool?
    public let duration: Int?
    public let durationText: String?
    public let guardMission: Bool?
    public let averageMinPolicePersonnel: Int?
    public let averageMinFirePersonnel: Int?
    public let swatPersonnel: Int?
    public let heightRescuePersonnel: Int?
    public let personnelEducations: [String: Int]?
    public let filterId: String?
    public let patientSpecializations: String?
    public let patientAtEndOfMission: Bool?
    public let possiblePatientMin: Int?
    public let possiblePatient: Int?
    public let patientAllowFirstResponderChance: Int?
    public let allowKtwInsteadOfRtw: Bool?
    public let patientUkCodePossible: [String]?
    public let patientUsCodePossible: [String]?
    public let possiblePatientSpecializations: [String]?
    public let patientItCodePossible: [String]?

    private enum CodingKeys: String, CodingKey {
        case expansionMissionsIds = "expansion_missions_ids"
        case followupMissionsIds = "followup_missions_ids"
        case allowRwInsteadOfLf = "allow_rw_instead_of_lf"
        case allowGwoilInsteadOfLf = "allow_gwoil_instead_of_lf"
        case allowArffInsteadOfLf = "allow_arff_instead_of_lf"
        case onlyAllianceMission = "only_alliance_mission"
        case maxPossiblePrisoners = "max_possible_prisoners"
        case needK9OnlyIfGuardDogsPresent = "need_k9_only_if_guard_dogs_present"
        case allowDroneInsteadOfInvestigation = "allow_drone_instead_of_investigation"
        case subsequentMissionsIds = "subsequent_missions_ids"
        case subsequentMissionOnly = "subsequent_mission_only"
        case needTrafficCarOnlyIfPresent = "need_traffic_car_only_if_present"
        case needElwPoliceOnlyIfPresent = "need_elw_police_only_if_present"
        case needBombOnlyIfPresent = "need_bomb_only_if_present"
        case needPoliceHorseOnlyIfPresent = "need_police_horse_only_if_present"
        case needBikePoliceOnlyIfPresent = "need_bike_police_only_if_present"
        case allowTrafficCarInsteadOfFustw = "allow_traffic_car_instead_of_fustw"
        case needHelicopterBucketOnlyIfPresent = "need_helicopter_bucket_only_if_present"
        case duration
        case durationText = "duration_text"
        case guardMission = "guard_mission"
        case averageMinPolicePersonnel = "average_min_police_personnel"
        case averageMinFirePersonnel = "average_min_fire_personnel"
        case swatPersonnel = "swat_personnel"
        case heightRescuePersonnel = "height_rescue_personnel"
        case personnelEducations = "personnel_educations"
        case filterId = "filter_id"
        case patientSpecializations = "patient_specializations"
        case patientAtEndOfMission = "patient_at_end_of_mission"
        case possiblePatientMin = "possible_patient_min"
        case possiblePatient = "possible_patient"
        case patientAllowFirstResponderChance = "patient_allow_first_responder_chance"
        case allowKtwInsteadOfRtw = "allow_ktw_instead_of_rtw"
        case patientUkCodePossible = "patient_uk_code_possible"
        case patientUsCodePossible = "patient_us_code_possible"
        case possiblePatientSpecializations = "possible_patient_specializations"
        case patientItCodePossible = "patient_it_code_possible"
    }
}

public struct LssChances: Codable, Hashable {
    public let firetrucks: Int?
    public let platformTrucks: Int?
    public let battalionChiefVehicles: Int?
    public let heavyRescueVehicles: Int?
    public let mobileCommandVehicles: Int?
    public let mobileAirVehicles: Int?
    public let waterTankers: Int?
    public let gwoil: Int?
    public let gwmess: Int?
    public let hazmatDekon: Int?
    public let hazmatVehicles: Int?
    public let policeCars: Int?
    public let fwk: Int?
    public let heightRescueUnits: Int?
    public let diverUnits: Int?
    public let rettungstreppe: Int?
    public let kdowOrgl: Int?
    public let elw3: Int?
    public let ovdp: Int?
    public let boats: Int?
    public let elwAirport: Int?
    public let k9: Int?
    public let trafficCar: Int?
    public let bikePolice: Int?
    public let nef: Int?
    public let helicopter: Int?
    public let patientTransport: Int?
    public let patientOtherTreatment: Int?
    public let patientCriticalCare: Int?
    
    private enum CodingKeys: String, CodingKey {
        case firetrucks
        case platformTrucks
        case battalionChiefVehicles = "battalion_chief_vehicles"
        case heavyRescueVehicles = "heavy_rescue_vehicles"
        case mobileCommandVehicles = "mobile_command_vehicles"
        case mobileAirVehicles = "mobile_air_vehicles"
        case waterTankers = "water_tankers"
        case gwoil
        case gwmess
        case hazmatDekon = "hazmat_dekon"
        case hazmatVehicles = "hazmat_vehicles"
        case policeCars = "police_cars"
        case fwk
        case heightRescueUnits = "height_rescue_units"
        case diverUnits = "diver_units"
        case rettungstreppe
        case kdowOrgl
        case elw3
        case ovdp
        case boats
        case elwAirport = "elw_airport"
        case k9
        case trafficCar = "traffic_car"
        case bikePolice = "bike_police"
        case nef
        case helicopter
        case patientTransport = "patient_transport"
        case patientOtherTreatment = "patient_other_treatment"
        case patientCriticalCare = "patient_critical_care"
    }
}

public struct LssPrerequisites: Codable, Hashable {
    public let fireStations: Int?
    public let maxPoliceStations: Int?
    public let rescueStations: Int?
    public let policeStations: Int?
    public let maxRescueStations: Int?
    public let thw: Int?
    public let bereitschaftspolizei: Int?
    public let policeHelicopterStations: Int?
    public let wasserrettung: Int?
    public let mek: Int?
    public let sek: Int?
    public let werkfeuerwehr: Int?
    public let rescueDogUnits: Int?
    public let federalpoliceStations: Int?
    public let bombDisposalCount: Int?
    public let commercePoliceStations: Int?
    
    private enum CodingKeys: String, CodingKey {
        case fireStations = "fire_stations"
        case maxPoliceStations = "max_police_stations"
        case rescueStations = "rescue_stations"
        case policeStations = "police_stations"
        case maxRescueStations = "max_rescue_stations"
        case thw
        case bereitschaftspolizei
        case policeHelicopterStations = "police_helicopter_stations"
        case wasserrettung
        case mek
        case sek
        case werkfeuerwehr
        case rescueDogUnits = "rescue_dog_units"
        case federalpoliceStations = "federalpolice_stations"
        case bombDisposalCount = "bomb_disposal_count"
        case commercePoliceStations = "commerce_police_stations"
    }
}

public struct LssRequirements: Codable, Hashable {
    public let firetrucks: Int?
    public let platformTrucks: Int?
    public let waterNeeded: Int?
    public let battalionChiefVehicles: Int?
    public let heavyRescueVehicles: Int?
    public let mobileCommandVehicles: Int?
    public let mobileAirVehicles: Int?
    public let waterTankers: Int?
    public let gwoil: Int?
    public let gwmess: Int?
    public let hazmatDekon: Int?
    public let hazmatVehicles: Int?
    public let policeCars: Int?
    public let heightRescueUnits: Int?
    public let fwk: Int?
    public let thwBrmgR: Int?
    public let thwGkw: Int?
    public let thwLkw: Int?
    public let thwMtwtz: Int?
    public let thwMzkw: Int?
    public let thwDle: Int?
    public let grukw: Int?
    public let lebefkw: Int?
    public let gefkw: Int?
    public let fukw: Int?
    public let ambulances: Int?
    public let gwSan: Int?
    public let policeHelicopters: Int?
    public let boats: Int?
    public let diverUnits: Int?
    public let wasserwerfer: Int?
    public let arff: Int?
    public let rettungstreppe: Int?
    public let mek: Int?
    public let sek: Int?
    public let gwWerkfeuerwehr: Int?
    public let teleskopmast: Int?
    public let turboloescher: Int?
    public let ulf: Int?
    public let rescueDogUnits: Int?
    public let kdowOrgl: Int?
    public let k9: Int?
    public let elw3: Int?
    public let spokesman: Int?
    public let ovdp: Int?
    public let elwAirport: Int?
    public let hondengeleider: Int?
    public let atC: Int?
    public let atM: Int?
    public let atO: Int?
    public let sheriff: Int?
    public let fbi: Int?
    public let fbiInvestigation: Int?
    public let fbiMcc: Int?
    public let fbiDrone: Int?
    public let fbiBomb: Int?
    public let trafficCar: Int?
    public let elwPolice: Int?
    public let commercePolice: Int?
    public let policeHorse: Int?
    public let bikePolice: Int?
    public let helicopterBucket: Int?
    
    private enum CodingKeys: String, CodingKey {
        case firetrucks
        case platformTrucks
        case waterNeeded = "water_needed"
        case battalionChiefVehicles = "battalion_chief_vehicles"
        case heavyRescueVehicles = "heavy_rescue_vehicles"
        case mobileCommandVehicles = "mobile_command_vehicles"
        case mobileAirVehicles = "mobile_air_vehicles"
        case waterTankers = "water_tankers"
        case gwoil
        case gwmess
        case hazmatDekon = "hazmat_dekon"
        case hazmatVehicles = "hazmat_vehicles"
        case policeCars = "police_cars"
        case heightRescueUnits = "height_rescue_units"
        case fwk
        case thwBrmgR = "thw_brmg_r"
        case thwGkw = "thw_gkw"
        case thwLkw = "thw_lkw"
        case thwMtwtz = "thw_mtwtz"
        case thwMzkw = "thw_mzkw"
        case thwDle = "thw_dle"
        case grukw
        case lebefkw
        case gefkw
        case fukw
        case ambulances
        case gwSan = "gw_san"
        case policeHelicopters = "police_helicopters"
        case boats
        case diverUnits = "diver_units"
        case wasserwerfer
        case arff
        case rettungstreppe
        case mek
        case sek
        case gwWerkfeuerwehr = "gw_werkfeuerwehr"
        case teleskopmast
        case turboloescher
        case ulf
        case rescueDogUnits = "rescue_dog_units"
        case kdowOrgl
        case k9
        case elw3
        case spokesman
        case ovdp
        case elwAirport = "elw_airport"
        case hondengeleider
        case atC = "at_c"
        case atM = "at_m"
        case atO = "at_o"
        case sheriff
        case fbi
        case fbiInvestigation = "fbi_investigation"
        case fbiMcc = "fbi_mcc"
        case fbiDrone = "fbi_drone"
        case fbiBomb = "fbi_bomb"
        case trafficCar = "traffic_car"
        case elwPolice = "elw_police"
        case commercePolice = "commerce_police"
        case policeHorse = "police_horse"
        case bikePolice = "bike_police"
        case helicopterBucket = "helicopter_bucket"
    }
    
    public func doesNeedMe(caption: String, type: UInt16) -> Bool {
        guard let type = VehicleType(rawValue: type) else {
            print("Unknown type: \(type) for caption: \(caption)")
            return false
        }
        switch type {
        case .lf20:
            if let firetrucks = self.firetrucks {
                return firetrucks > 0
            }
            
        case .lf10:
            if let firetrucks = self.firetrucks {
                return firetrucks > 0
            }
            
        case .dlk:
            if let platformTrucks = self.platformTrucks {
                return platformTrucks > 0
            }
            
        case .elw1:
            if let battalionChiefVehicles = self.battalionChiefVehicles {
                return battalionChiefVehicles > 0
            }
            
        case .rw:
            if let heavyRescueVehicles = self.heavyRescueVehicles {
                return heavyRescueVehicles > 0
            }
            
        case .gwA:
            if let gwSan = self.gwSan {
                return gwSan > 0
            }
            
        case .gwOil:
            if let gwoil = self.gwoil {
                return gwoil > 0
            }
            
        case .gwL2Wasser:
            if let waterTankers = self.waterTankers {
                return waterTankers > 0
            }
        
        case .gwMess:
            if let gwMess = self.gwmess {
                return gwMess > 0
            }
            
        case .gwGefahrgut:
            if let hazmatVehicles = self.hazmatVehicles {
                return hazmatVehicles > 0
            }
            
        case .rtw:
            if let ambulances = self.ambulances {
                return ambulances > 0
            }
        case .nef:
            if let ambulances = self.ambulances {
                return ambulances > 0
            }
            
        case .hlf20:
            let heavyRescueVehicles = self.heavyRescueVehicles
            let firetrucks = self.firetrucks
            
            if let hrv = heavyRescueVehicles, hrv > 0 {
                return true
            }
            
            if let ft = firetrucks, ft > 0 {
                return true
            }
            
            return false
            
        case .fuStW:
            if let policeCars = self.policeCars {
                return policeCars > 0
            }
        case .gwHoehe:
            if let heightRescueUnits = self.heightRescueUnits {
                return heightRescueUnits > 0
            }
            
        case .elw2:
            if let mobileCommandVehicles = self.mobileCommandVehicles {
                return mobileCommandVehicles > 0
            }
            
        case .tsfW:
            if let firetrucks = self.firetrucks {
                return firetrucks > 0
            }
            
        case .ktw:
            if let ambulances = self.ambulances {
                return ambulances > 0
            }
            
        case .gkw:
            if let thwGkw = self.thwGkw {
                return thwGkw > 0
            }
            
        case .mtwTz:
            if let thwMtwtz = self.thwMtwtz {
                return thwMtwtz > 0
            }
            
        case .mtwOv:
            if let thwMzkw = self.thwMzkw, thwMzkw > 0 {
                return true
            }
            if let thwMtwtz = self.thwMtwtz, thwMtwtz > 0 {
                return true
            }
            
        case .mzGw:
            if let thwMzkw = self.thwMzkw, thwMzkw > 0 {
                return true
            }
            if let thwMtwtz = self.thwMtwtz, thwMtwtz > 0 {
                return true
            }
            
        case .tkw:
            if let thwMzkw = self.thwMzkw, thwMzkw > 0 {
                return true
            }
            if let thwMtwtz = self.thwMtwtz, thwMtwtz > 0 {
                return true
            }
            if let thwLkw = self.thwLkw, thwLkw > 0 {
                return true
            }
            
    
        case .lkw7Lkr19Tm:
            if let thwLkw = self.thwLkw {
                return thwLkw > 0
            }
            
        case .anhMzB:
            if let thwLkw = self.thwLkw {
                return thwLkw > 0
            }
            
        case .anhMzAB:
            if let thwLkw = self.thwLkw {
                return thwLkw > 0
            }
            
        case .anhSchlB:
            if let thwLkw = self.thwLkw {
                return thwLkw > 0
            }
            
        case .dekonP:
            if let hazmatDekon = self.hazmatDekon {
                return hazmatDekon > 0
            }
            
        case .kdowLNA:
            if let ambulances = self.ambulances {
                return ambulances > 0
            }
            
        case .kdowOrgL:
            if let kdowOrgl = self.kdowOrgl {
                return kdowOrgl > 0
            }
        
        case .fwk:
            if let fwk = self.fwk {
                return fwk > 0
            }
            
        case .naw:
            if let ambulances = self.ambulances {
                return ambulances > 0
            }
            
        case .tlf4000:
            if let waterTankers = self.waterTankers {
                return waterTankers > 0
            }
        
        case .mlf:
            if let firetrucks = self.firetrucks {
                return firetrucks > 0
            }
            
        case .hlf10:
            if let firetrucks = self.firetrucks {
                return firetrucks > 0
            }
            
        case .dhuUFueKw:
            if let rescueDogUnits = self.rescueDogUnits {
                return rescueDogUnits > 0
            }
            
        case .nea50:
            // TODO: check
            return false
            
        case .gtlf:
            if let firetrucks = self.firetrucks, firetrucks > 0 {
                return true
            } else if let waterTankers = self.waterTankers, waterTankers > 0 {
                return true
            }
            
        case .all:
            return true
            
        case .lkwK9:
            if let thwLkw = self.thwLkw {
                return thwLkw > 0
            }
            
        case .brmgr:
            if let thwBrmgR = self.thwBrmgR {
                return thwBrmgR > 0
            }
        case .anhHund:
            return false
        case .mtwO:
            return false
        case .flf:
            return false
        case .zivilstreifenwagen:
            return (commercePolice ?? 0) > 0
        case .tankwagen:
            if let waterTankers = self.waterTankers {
                return waterTankers > 0
            }
        case .anhDle:
            if let thwDle = self.thwDle {
                return thwDle > 0
            }
        }
        
        return false
    }
}

public struct LssMission: Codable, Identifiable, Hashable, Equatable {
    public let id: String
    public let name: String
    public let place: String
    public let placeArray: [String]
    public let averageCredits: Int?
    public let generatedBy: String
    public let icons: [String]
    public let requirements: LssRequirements
    public let chances: LssChances
    public let additional: LssAdditional
    public let prerequisites: LssPrerequisites
    
    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case place
        case placeArray = "place_array"
        case averageCredits
        case generatedBy = "generated_by"
        case icons
        case requirements
        case chances
        case additional
        case prerequisites
    }
    
    public static func == (lhs: LssMission, rhs: LssMission) -> Bool {
        return lhs.id == rhs.id
    }
}

