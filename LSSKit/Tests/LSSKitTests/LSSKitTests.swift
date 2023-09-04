import XCTest
@testable import LssKit

let sampleHTML = """
<!DOCTYPE html>
<html lang="en">
<body>
<script>
    var user_id = 9113338;
    var username = "theuser";
    var alliance_id = 313;
</script>
<script type="text/javascript">
    var subscriptions = [];
    var faye = new Faye.Client('/faye');

    faye.on('transport:down', function (message) {
      if (mobile_version == 4) {
          mobileBridgeAdd("faye_down", {});
      }
    });

    faye.on('transport:up', function (message) {
      if (mobile_version == 4) {
          mobileBridgeAdd("faye_up", {});
      }
    });


    faye.addExtension({
      outgoing: function (message, callback) {
          if (message.channel !== '/meta/subscribe')
              return callback(message);

          message.ext = message.ext || {};

          message.ext["/private-user9113338de_DE"] = "y622cxe3a02cse6ca7dca11easfvbecv0ace14";
          message.ext["/private-alliance/953885c9-5647-42f1-bfc8-1d66fc116173/de_DE"] = "29d629a1d05323464340955bb6256b5e50f15a2c";
          message.ext["/allde_DE"] = "5282c14d2c05d331cah75013ca826a2b35c6bd92";

          callback(message);
      }
    });


    subscriptions.push(faye.subscribe('/private-user9113338de_DE', function (data) {
      eval(data);
    }));
    subscriptions.push(faye.subscribe('/private-alliance/123813c9-5647-42f1-bhb8-1dyubc11610v/de_DE', function (data) {
      eval(data);
    }));
    subscriptions.push(faye.subscribe('/allde_DE', function (data) {
      eval(data);
    }));
</script>
<script>
        vehicleDrive({"b":5583531,"rh":"7c01c6ea28f2b0747bc5b4ba192f3310c5eb498ca2cd562221c0ac37ae299901","vom":true,"vtid":0,"mid":"3007114739","dd":478,"s":"[[51.15941,8.46459,2.2],[50.9672,8.02185,6.0],[50.9671,8.02093,0]]","fms":3,"fms_real":3,"user_id":871104,"isr":"https://leitstellenspiel.s3.amazonaws.com/vehicle_graphic_images/image_sonderrechtes/000/044/341/original/LF_16_12_FF_HH_Set1_ani.png?1484435057","in":"https://leitstellenspiel.s3.amazonaws.com/vehicle_graphic_images/images/000/044/341/original/LF_16_12_FF_HH_Set1.png?1484435057","apng_sonderrechte":"true","ioverwrite":"false","caption":"LF 20","id":26337474,"sr":"1"});

        map = L.map('map').setView([48.05152711071136, 10.870002126199408], 13);

        buildingMarkerAdd({"id":5011776,"user_id":null,"name":"VK 150 St. Walburga Kh. Meschede","longitude":8.288400961547586,"latitude":51.342998312125445,"icon":"/images/building_hospital.png","icon_other":"/images/building_hospital_other.png","vgi":null,"lbid":0,"show_vehicles_at_startpage":true,"level":20,"personal_count":0,"building_type":4,"filter_id":"hospital","detail_button":"<a href=\\"/buildings/5011776\\" building_type=\\"4\\" class=\\"btn btn-xs pull-right btn-default lightbox-open\\" id=\\"building_button_5011776\\">Details</a>"});
        buildingMarkerAdd({"id":12066098,"user_id":null,"name":"VK 440 Klinik Neuperlach München","longitude":11.656247332760934,"latitude":48.09500009301396,"icon":"/images/building_hospital.png","icon_other":"/images/building_hospital_other.png","vgi":null,"lbid":0,"show_vehicles_at_startpage":true,"level":20,"personal_count":0,"building_type":4,"filter_id":"hospital","detail_button":"<a href=\\"/buildings/12066098\\" building_type=\\"4\\" class=\\"btn btn-xs pull-right btn-default lightbox-open\\" id=\\"building_button_12066098\\">Details</a>"});
        buildingMarkerAdd({"id":6169781,"user_id":null,"name":"VK 183 EVK Düsseldorf","longitude":6.773360999842707,"latitude":51.21269059910518,"icon":"/images/building_hospital.png","icon_other":"/images/building_hospital_other.png","vgi":null,"lbid":0,"show_vehicles_at_startpage":true,"level":20,"personal_count":0,"building_type":4,"filter_id":"hospital","detail_button":"<a href=\\"/buildings/6169781\\" building_type=\\"4\\" class=\\"btn btn-xs pull-right btn-default lightbox-open\\" id=\\"building_button_6169781\\">Details</a>"});
        buildingMarkerAdd({"id":17755441,"user_id":null,"name":"VK 616 SRH Krankenhaus Friedrichroda","longitude":10.561069250106813,"latitude":50.861017471462134,"icon":"/images/building_hospital.png","icon_other":"/images/building_hospital_other.png","vgi":null,"lbid":0,"show_vehicles_at_startpage":true,"level":20,"personal_count":0,"building_type":4,"filter_id":"hospital","detail_button":"<a href=\\"/buildings/17755441\\" building_type=\\"4\\" class=\\"btn btn-xs pull-right btn-default lightbox-open\\" id=\\"building_button_17755441\\">Details</a>"});

        patientMarkerAdd({"missing_text":"Wir benötigen: NEF, LNA, RTW","name":"Christian O.","mission_id":3009218606,"id":2682621864,"miliseconds_by_percent":0,"target_percent":80,"live_current_value":80});patientMarkerAdd({"missing_text":"Wir benötigen: NEF, LNA, RTW","name":"Sandra T.","mission_id":3009218606,"id":2682621865,"miliseconds_by_percent":4637,"target_percent":80,"live_current_value":91});patientMarkerAdd({"missing_text":null,"name":"Jasmin B.","mission_id":3009218606,"id":2682621866,"miliseconds_by_percent":-10,"target_percent":0,"live_current_value":100.0});patientMarkerAdd({"missing_text":null,"name":"Christoph U.","mission_id":3009218606,"id":2682621867,"miliseconds_by_percent":-10,"target_percent":0,"live_current_value":100.0});patientMarkerAdd({"missing_text":null,"name":"Michael W.","mission_id":3009218606,"id":2682621868,"miliseconds_by_percent":-10,"target_percent":0,"live_current_value":100.0});

        missionMarkerAdd( {"id":3009215366,"sw_start_in":-1,"sw":false,"tv":0,"mtid":83,"mission_type":null,"kt":false,"alliance_id":676,"prisoners_count":0,"patients_count":0,"user_id":2609069,"address":"Ostwestfalenstraße, 32107 Knetterheide","vehicle_state":2,"missing_text":null,"missing_text_short":null,"live_current_value":56,"live_current_water_damage_pump_value":0,"water_damage_pump_value":0,"pumping_mission_value":0,"finish_url":"","date_end":1693494426,"pumping_date_start":0,"pumping_date_end":0,"date_now":1693494136,"longitude":8.727277,"latitude":52.052038,"tlng":null,"tlat":null,"icon":"caraccident_gruen","caption":"Gefahrgut-LKW verunglückt","captionOld":"","filter_id":"firehouse_missions","overlay_index":null,"additive_overlays":"","handoff":false});

        radioMessage({"target_building_id":0,"mission_id":3008928869,"additionalText":"","user_id":2313975,"type":"vehicle_fms","id":71462684,"fms_real":5,"fms":5,"fms_text":"Sprechwunsch","caption":"RTW 3 (LL Nord)"});


        radioMessage({"target_building_id":0,"mission_id":3008928869,"additionalText":"","user_id":2313975,"type":"vehicle_fms","id":71414016,"fms_real":5,"fms":5,"fms_text":"Sprechwunsch","caption":"RTW 1 (LL Nord)"});


    allianceChatHeaderInfo('Es gelten wieder die bekannten Regeln! Spielt fair und gebt fleißig Einsätze frei')
});
</script>
<h1> For nice stuff </h1>
<script type="text/javascript">
var continue_tutorial = false
var tutorialView = "mapIndex"
var has_tutorial = false
if(typeof tutorial !== "undefined" && has_tutorial){
    tutorial.init(continue_tutorial,tutorialView)
}
</script>
<div id="test">
test
</div>
</body>
</html>
"""

func arraysContainSameElements<T: Hashable>(_ array1: [T], _ array2: [T]) -> Bool {
    let set1 = Set(array1)
    let set2 = Set(array2)
    return set1 == set2
}

func credsExtsContain(_ exts: [String : String], _ keysToCheck: [String]) -> Bool {
    var containsAllKeys = true
    for key in keysToCheck {
        if !exts.keys.contains(key) {
            containsAllKeys = false
        }
    }
    return containsAllKeys
}

final class LSSKitTests: XCTestCase {
    func testHTMLScriptsReduction() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        //XCTAssertEqual(LSSKit().text, "Hello, World!")
        
        let expectedResult = """
<script>
    var user_id = 9113338;
    var username = "theuser";
    var alliance_id = 313;
</script><script type="text/javascript">
    var subscriptions = [];
    var faye = new Faye.Client('/faye');

    faye.on('transport:down', function (message) {
      if (mobile_version == 4) {
          mobileBridgeAdd("faye_down", {});
      }
    });

    faye.on('transport:up', function (message) {
      if (mobile_version == 4) {
          mobileBridgeAdd("faye_up", {});
      }
    });


    faye.addExtension({
      outgoing: function (message, callback) {
          if (message.channel !== '/meta/subscribe')
              return callback(message);

          message.ext = message.ext || {};

          message.ext["/private-user9113338de_DE"] = "y622cxe3a02cse6ca7dca11easfvbecv0ace14";
          message.ext["/private-alliance/953885c9-5647-42f1-bfc8-1d66fc116173/de_DE"] = "29d629a1d05323464340955bb6256b5e50f15a2c";
          message.ext["/allde_DE"] = "5282c14d2c05d331cah75013ca826a2b35c6bd92";

          callback(message);
      }
    });


    subscriptions.push(faye.subscribe('/private-user9113338de_DE', function (data) {
      eval(data);
    }));
    subscriptions.push(faye.subscribe('/private-alliance/123813c9-5647-42f1-bhb8-1dyubc11610v/de_DE', function (data) {
      eval(data);
    }));
    subscriptions.push(faye.subscribe('/allde_DE', function (data) {
      eval(data);
    }));
</script><script>
        vehicleDrive({"b":5583531,"rh":"7c01c6ea28f2b0747bc5b4ba192f3310c5eb498ca2cd562221c0ac37ae299901","vom":true,"vtid":0,"mid":"3007114739","dd":478,"s":"[[51.15941,8.46459,2.2],[50.9672,8.02185,6.0],[50.9671,8.02093,0]]","fms":3,"fms_real":3,"user_id":871104,"isr":"https://leitstellenspiel.s3.amazonaws.com/vehicle_graphic_images/image_sonderrechtes/000/044/341/original/LF_16_12_FF_HH_Set1_ani.png?1484435057","in":"https://leitstellenspiel.s3.amazonaws.com/vehicle_graphic_images/images/000/044/341/original/LF_16_12_FF_HH_Set1.png?1484435057","apng_sonderrechte":"true","ioverwrite":"false","caption":"LF 20","id":26337474,"sr":"1"});

        map = L.map('map').setView([48.05152711071136, 10.870002126199408], 13);

        buildingMarkerAdd({"id":5011776,"user_id":null,"name":"VK 150 St. Walburga Kh. Meschede","longitude":8.288400961547586,"latitude":51.342998312125445,"icon":"/images/building_hospital.png","icon_other":"/images/building_hospital_other.png","vgi":null,"lbid":0,"show_vehicles_at_startpage":true,"level":20,"personal_count":0,"building_type":4,"filter_id":"hospital","detail_button":"<a href=\\"/buildings/5011776\\" building_type=\\"4\\" class=\\"btn btn-xs pull-right btn-default lightbox-open\\" id=\\"building_button_5011776\\">Details</a>"});
        buildingMarkerAdd({"id":12066098,"user_id":null,"name":"VK 440 Klinik Neuperlach München","longitude":11.656247332760934,"latitude":48.09500009301396,"icon":"/images/building_hospital.png","icon_other":"/images/building_hospital_other.png","vgi":null,"lbid":0,"show_vehicles_at_startpage":true,"level":20,"personal_count":0,"building_type":4,"filter_id":"hospital","detail_button":"<a href=\\"/buildings/12066098\\" building_type=\\"4\\" class=\\"btn btn-xs pull-right btn-default lightbox-open\\" id=\\"building_button_12066098\\">Details</a>"});
        buildingMarkerAdd({"id":6169781,"user_id":null,"name":"VK 183 EVK Düsseldorf","longitude":6.773360999842707,"latitude":51.21269059910518,"icon":"/images/building_hospital.png","icon_other":"/images/building_hospital_other.png","vgi":null,"lbid":0,"show_vehicles_at_startpage":true,"level":20,"personal_count":0,"building_type":4,"filter_id":"hospital","detail_button":"<a href=\\"/buildings/6169781\\" building_type=\\"4\\" class=\\"btn btn-xs pull-right btn-default lightbox-open\\" id=\\"building_button_6169781\\">Details</a>"});
        buildingMarkerAdd({"id":17755441,"user_id":null,"name":"VK 616 SRH Krankenhaus Friedrichroda","longitude":10.561069250106813,"latitude":50.861017471462134,"icon":"/images/building_hospital.png","icon_other":"/images/building_hospital_other.png","vgi":null,"lbid":0,"show_vehicles_at_startpage":true,"level":20,"personal_count":0,"building_type":4,"filter_id":"hospital","detail_button":"<a href=\\"/buildings/17755441\\" building_type=\\"4\\" class=\\"btn btn-xs pull-right btn-default lightbox-open\\" id=\\"building_button_17755441\\">Details</a>"});

        patientMarkerAdd({"missing_text":"Wir benötigen: NEF, LNA, RTW","name":"Christian O.","mission_id":3009218606,"id":2682621864,"miliseconds_by_percent":0,"target_percent":80,"live_current_value":80});patientMarkerAdd({"missing_text":"Wir benötigen: NEF, LNA, RTW","name":"Sandra T.","mission_id":3009218606,"id":2682621865,"miliseconds_by_percent":4637,"target_percent":80,"live_current_value":91});patientMarkerAdd({"missing_text":null,"name":"Jasmin B.","mission_id":3009218606,"id":2682621866,"miliseconds_by_percent":-10,"target_percent":0,"live_current_value":100.0});patientMarkerAdd({"missing_text":null,"name":"Christoph U.","mission_id":3009218606,"id":2682621867,"miliseconds_by_percent":-10,"target_percent":0,"live_current_value":100.0});patientMarkerAdd({"missing_text":null,"name":"Michael W.","mission_id":3009218606,"id":2682621868,"miliseconds_by_percent":-10,"target_percent":0,"live_current_value":100.0});

        missionMarkerAdd( {"id":3009215366,"sw_start_in":-1,"sw":false,"tv":0,"mtid":83,"mission_type":null,"kt":false,"alliance_id":676,"prisoners_count":0,"patients_count":0,"user_id":2609069,"address":"Ostwestfalenstraße, 32107 Knetterheide","vehicle_state":2,"missing_text":null,"missing_text_short":null,"live_current_value":56,"live_current_water_damage_pump_value":0,"water_damage_pump_value":0,"pumping_mission_value":0,"finish_url":"","date_end":1693494426,"pumping_date_start":0,"pumping_date_end":0,"date_now":1693494136,"longitude":8.727277,"latitude":52.052038,"tlng":null,"tlat":null,"icon":"caraccident_gruen","caption":"Gefahrgut-LKW verunglückt","captionOld":"","filter_id":"firehouse_missions","overlay_index":null,"additive_overlays":"","handoff":false});

        radioMessage({"target_building_id":0,"mission_id":3008928869,"additionalText":"","user_id":2313975,"type":"vehicle_fms","id":71462684,"fms_real":5,"fms":5,"fms_text":"Sprechwunsch","caption":"RTW 3 (LL Nord)"});


        radioMessage({"target_building_id":0,"mission_id":3008928869,"additionalText":"","user_id":2313975,"type":"vehicle_fms","id":71414016,"fms_real":5,"fms":5,"fms_text":"Sprechwunsch","caption":"RTW 1 (LL Nord)"});


    allianceChatHeaderInfo('Es gelten wieder die bekannten Regeln! Spielt fair und gebt fleißig Einsätze frei')
});
</script><script type="text/javascript">
var continue_tutorial = false
var tutorialView = "mapIndex"
var has_tutorial = false
if(typeof tutorial !== "undefined" && has_tutorial){
    tutorial.init(continue_tutorial,tutorialView)
}
</script>
"""
        let result = htmlReduceToScripts(from: sampleHTML)
        Swift.print(result)
        Swift.print("\n\n\n")
        Swift.print(expectedResult)
        XCTAssertEqual(result, expectedResult)
    }
    
    func testHTMLRadioMessagesExtraction() {
        let expectedMessages = [
            RadioMessage(
                targetBuildingId: 0,
                missionId: 3008928869,
                additionalText: "",
                userId: 2313975,
                type: "vehicle_fms",
                id: 71462684,
                fmsReal: 5,
                fms: 5,
                fmsText: "Sprechwunsch",
                caption: "RTW 3 (LL Nord)"
            ),
            RadioMessage(
                targetBuildingId: 0,
                missionId: 3008928869,
                additionalText: "",
                userId: 2313975,
                type: "vehicle_fms",
                id: 71414016,
                fmsReal: 5,
                fms: 5,
                fmsText: "Sprechwunsch",
                caption: "RTW 1 (LL Nord)"
            )

        ]
        
        let messages = htmlExtractRadioMessages(from: sampleHTML)
        
        XCTAssertEqual(messages.count, expectedMessages.count)
        XCTAssertTrue(arraysContainSameElements(messages, expectedMessages))
    }
    
    func testHTMLVehicleDrivesExtraction() {
        let expected = [
            VehicleDrive(
                id: 26337474,
                b: 5583531,
                rh: "7c01c6ea28f2b0747bc5b4ba192f3310c5eb498ca2cd562221c0ac37ae299901",
                vom: true,
                vtid: 0,
                mid: "3007114739",
                dd: 478,
                s: "[[51.15941,8.46459,2.2],[50.9672,8.02185,6.0],[50.9671,8.02093,0]]",
                fms: 3,
                fmsReal:3,
                userId: 871104,
                isr: "https://leitstellenspiel.s3.amazonaws.com/vehicle_graphic_images/image_sonderrechtes/000/044/341/original/LF_16_12_FF_HH_Set1_ani.png?1484435057",
                inGraphic: "https://leitstellenspiel.s3.amazonaws.com/vehicle_graphic_images/images/000/044/341/original/LF_16_12_FF_HH_Set1.png?1484435057",
                apngSonderrechte: "true",
                ioverwrite: "false",
                caption: "LF 20",
                sr: "1"
            )
        ]
        
        let vehicleDrives = htmlExtractVehicleDrives(from: sampleHTML)
        
        XCTAssertEqual(vehicleDrives.count, expected.count)
        XCTAssertTrue(arraysContainSameElements(vehicleDrives, expected))
    }
    
    func testHTMLMissionMarkersExtraction() {
        let expected = [
            MissionMarker(id: 3009215366, swStartIn: -1, sw: false, tv: 0, mtid: 83, missionType: nil, kt: false, allianceId: 676, prisonersCount: 0, patientsCount: 0, userId: 2609069, address: "Ostwestfalenstraße, 32107 Knetterheide", vehicleState: 2, missingText: nil, missingTextShort: nil, liveCurrentValue: 56, liveCurrentWaterDamagePumpValue: 0.0, waterDamagePumpValue: 0, pumpingMissionValue: 0, finishUrl: "", dateEnd: 1693494426, pumpingDateStart: 0, pumpingDateEnd: 0, dateNow: 1693494136, longitude: 8.727277, latitude: 52.052038, tlng: nil, tlat: nil, icon: "caraccident_gruen", caption: "Gefahrgut-LKW verunglückt", captionOld: "", filterId: "firehouse_missions", overlayIndex: nil, additiveOverlays: "", handoff: false)
        ]
        
        let markers = htmlExtractMissionMarkers(from: sampleHTML)
        
        XCTAssertEqual(markers.count, expected.count)
        XCTAssertTrue(arraysContainSameElements(markers, expected))
    }
    
    func testHTMLPatientMarkersExtraction() {
        let expected = [
            PatientMarker(missingText: "Wir benötigen: NEF, LNA, RTW",
                   name: "Christian O.",
                   missionId: 3009218606,
                   id: 2682621864,
                   milisecondsByPercent: 0,
                   targetPercent: 80,
                   liveCurrentValue: 80),

            PatientMarker(missingText: "Wir benötigen: NEF, LNA, RTW",
                   name: "Sandra T.",
                   missionId: 3009218606,
                   id: 2682621865,
                   milisecondsByPercent: 4637,
                   targetPercent: 80,
                   liveCurrentValue: 91),

            PatientMarker(missingText: nil,
                   name: "Jasmin B.",
                   missionId: 3009218606,
                   id: 2682621866,
                   milisecondsByPercent: -10,
                   targetPercent: 0,
                   liveCurrentValue: 100),

            PatientMarker(missingText: nil,
                   name: "Christoph U.",
                   missionId: 3009218606,
                   id: 2682621867,
                   milisecondsByPercent: -10,
                   targetPercent: 0,
                   liveCurrentValue: 100),

            PatientMarker(missingText: nil,
                   name: "Michael W.",
                   missionId: 3009218606,
                   id: 2682621868,
                   milisecondsByPercent: -10,
                   targetPercent: 0,
                   liveCurrentValue: 100)
        ]
        
        let patientMarkers = htmlExtractPatientMarkers(from: sampleHTML)
        
        XCTAssertEqual(patientMarkers.count, expected.count)
        XCTAssertTrue(arraysContainSameElements(patientMarkers, expected))
    }
    
    func testHTMLBuildingMarkersExtraction() {
        let expected = [
            BuildingMarker(id: 5011776, userId: nil, name: "VK 150 St. Walburga Kh. Meschede", longitude: 8.288400961547586, latitude: 51.342998312125445, icon: "/images/building_hospital.png", iconOther: "/images/building_hospital_other.png", vgi: nil, lbid: 0, showVehiclesAtStartpage: true, level: 20, personalCount: 0, buildingType: 4, filterId: "hospital", detailButton: "<a href=\"/buildings/5011776\" building_type=\"4\" class=\"btn btn-xs pull-right btn-default lightbox-open\" id=\"building_button_5011776\">Details</a>"),
            BuildingMarker(id: 12066098, userId: nil, name: "VK 440 Klinik Neuperlach München", longitude: 11.656247332760934, latitude: 48.09500009301396, icon: "/images/building_hospital.png", iconOther: "/images/building_hospital_other.png", vgi: nil, lbid: 0, showVehiclesAtStartpage: true, level: 20, personalCount: 0, buildingType: 4, filterId: "hospital", detailButton: "<a href=\"/buildings/12066098\" building_type=\"4\" class=\"btn btn-xs pull-right btn-default lightbox-open\" id=\"building_button_12066098\">Details</a>"),
            BuildingMarker(id: 6169781, userId: nil, name: "VK 183 EVK Düsseldorf", longitude: 6.773360999842707, latitude: 51.21269059910518, icon: "/images/building_hospital.png", iconOther: "/images/building_hospital_other.png", vgi: nil, lbid: 0, showVehiclesAtStartpage: true, level: 20, personalCount: 0, buildingType: 4, filterId: "hospital", detailButton: "<a href=\"/buildings/6169781\" building_type=\"4\" class=\"btn btn-xs pull-right btn-default lightbox-open\" id=\"building_button_6169781\">Details</a>"),
            BuildingMarker(id: 17755441, userId: nil, name: "VK 616 SRH Krankenhaus Friedrichroda", longitude: 10.561069250106813, latitude: 50.861017471462134, icon: "/images/building_hospital.png", iconOther: "/images/building_hospital_other.png", vgi: nil, lbid: 0, showVehiclesAtStartpage: true, level: 20, personalCount: 0, buildingType: 4, filterId: "hospital", detailButton: "<a href=\"/buildings/17755441\" building_type=\"4\" class=\"btn btn-xs pull-right btn-default lightbox-open\" id=\"building_button_17755441\">Details</a>")
        ]
        
        let buildingMarkers = htmlExtractBuildingMarkers(from: sampleHTML)
        
        XCTAssertEqual(buildingMarkers.count, expected.count)
        XCTAssertTrue(arraysContainSameElements(buildingMarkers, expected))
    }
    
    func testHTMLUserDetailsExtraction() {
        var creds = FayeCredentials(stripeMid: "", sessionId: "", mcUniqueClientId: "", rememberUserToken: "")
        htmlExtractUserDetails(from: sampleHTML, creds: &creds)
        
        XCTAssertEqual("9113338", creds.userId)
        XCTAssertEqual("theuser", creds.userName)
        XCTAssertEqual("313", creds.allianceId)
        XCTAssertEqual("953885c9-5647-42f1-bfc8-1d66fc116173", creds.allianceGuid)
        
        let keysToCheck = ["/private-user9113338de_DE", "/private-alliance/953885c9-5647-42f1-bfc8-1d66fc116173/de_DE", "/allde_DE"]
        XCTAssertTrue(credsExtsContain(creds.exts, keysToCheck))
        
        XCTAssertEqual("y622cxe3a02cse6ca7dca11easfvbecv0ace14", creds.exts["/private-user9113338de_DE"])
        XCTAssertEqual("29d629a1d05323464340955bb6256b5e50f15a2c", creds.exts["/private-alliance/953885c9-5647-42f1-bfc8-1d66fc116173/de_DE"])
        XCTAssertEqual("5282c14d2c05d331cah75013ca826a2b35c6bd92", creds.exts["/allde_DE"])
    }
}
