//
//  PatientHome.swift
//  PhysioSync
//
//  Created by Sanjeev Mehta on 27/06/24.
//

import SwiftyJSON

class PatientHomeModel {

    var success: Bool?
    var data: PatientHomeData?
    var message = ""

    init(_ json: JSON) {
        success = json["success"].boolValue
        data = PatientHomeData(json["data"])
        message = json["message"].stringValue
    }

}

class PatientHomeData {

    var exercise = [Exercise]()
    var patient: Patient?
    var watchData: WatchData?
    
    init(_ json: JSON) {
        exercise = json["exercise"].arrayValue.map { Exercise($0) }
        patient = Patient(json["patient"])
        watchData = WatchData(json["watchData"])
    }

}

class WatchData {

    var Id = ""
    var patientId = ""
    var calories = [Calories]()
    var heartRate = [HeartRate]()
    var sleep = [Sleep]()
    var stepCount = [StepCount]()
    var _v = 0

    init(_ json: JSON) {
        Id = json["_id"].stringValue
        patientId = json["patient_id"].stringValue
        calories = json["calories"].arrayValue.map { Calories($0) }
        heartRate = json["heartRate"].arrayValue.map { HeartRate($0) }
        sleep = json["sleep"].arrayValue.map { Sleep($0) }
        stepCount = json["stepCount"].arrayValue.map { StepCount($0) }
        _v = json["__v"].intValue
    }

}

class Calories {

    var day = ""
    var values = [Int]()
    var Id = ""

    init(_ json: JSON) {
        day = json["day"].stringValue
        values = json["values"].arrayValue.map { $0.intValue }
        Id = json["_id"].stringValue
    }

}

class HeartRate {

    var day = ""
    var bpmMinimum = 0
    var bpmMaximum = 0
    var Id = ""

    init(_ json: JSON) {
        day = json["day"].stringValue
        bpmMinimum = json["bpm_minimum"].intValue
        bpmMaximum = json["bpm_maximum"].intValue
        Id = json["_id"].stringValue
    }

}

class Sleep {

    var day = ""
    var awakeHours = 0
    var remHours = 0
    var coreHours = 0
    var deepHours = 0
    var Id = ""

    init(_ json: JSON) {
        day = json["day"].stringValue
        awakeHours = json["awake_hours"].intValue
        remHours = json["rem_hours"].intValue
        coreHours = json["core_hours"].intValue
        deepHours = json["deep_hours"].intValue
        Id = json["_id"].stringValue
    }

}

class StepCount {

    var day = ""
    var steps = 0
    var Id = ""

    init(_ json: JSON) {
        day = json["day"].stringValue
        steps = json["steps"].intValue
        Id = json["_id"].stringValue
    }

}
