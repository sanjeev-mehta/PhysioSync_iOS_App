//
//  PatientHome.swift
//  PhysioSync
//
//  Created by Sanjeev Mehta on 27/06/24.
//

import SwiftyJSON

// Main Model for Patient Home
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

// Data Model for Patient Home
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

// Model for Watch Data
class WatchData {
    var id = ""
    var patientId = ""
    var calories = [Calories]()
    var heartRate = [HeartRate]()
    var sleep = [Sleep]()
    var stepCount = [StepCount]()
    var version = 0

    init(_ json: JSON) {
        id = json["_id"].stringValue
        patientId = json["patient_id"].stringValue
        calories = json["calories"].arrayValue.map { Calories($0) }
        heartRate = json["heartRate"].arrayValue.map { HeartRate($0) }
        sleep = json["sleep"].arrayValue.map { Sleep($0) }
        stepCount = json["stepCount"].arrayValue.map { StepCount($0) }
        version = json["__v"].intValue
    }

    // Method to get the latest calories
    func latestCalories() -> String {
        return "\(calories.last?.values.last ?? 0) kcal"
    }

    // Method to get the latest step count
    func latestSteps() -> String {
        return "\(stepCount.last?.steps ?? 0)"
    }

    // Method to get the average heart rate
    func averageHeartRate() -> String {
        return "\(heartRate.last?.bpmMinimum ?? 0) bpm"
    }

    // Method to get combined sleep hours
    func combinedSleep() -> String {
        let totalAwake = sleep.reduce(0) { $0 + $1.awakeHours }
        let totalRem = sleep.reduce(0) { $0 + $1.remHours }
        let totalCore = sleep.reduce(0) { $0 + $1.coreHours }
        let totalDeep = sleep.reduce(0) { $0 + $1.deepHours }
        let totalSleep = totalAwake + totalRem + totalCore + totalDeep
        let formattedTotalSleep = String(format: "%.1f hours", totalSleep)
            
        return formattedTotalSleep
    }
}

// Model for Calories Data
class Calories {
    var day = ""
    var values = [Int]()
    var id = ""

    init(_ json: JSON) {
        day = json["day"].stringValue
        values = json["values"].arrayValue.map { $0.intValue }
        id = json["_id"].stringValue
    }
}

// Model for Heart Rate Data
class HeartRate {
    var day = ""
    var bpmMinimum = 0
    var bpmMaximum = 0
    var id = ""

    var formattedDate: Date? {
           let dateFormatter = DateFormatter()
           dateFormatter.dateFormat = "yyyy-MM-dd"
           return dateFormatter.date(from: day)
       }
    
    init(_ json: JSON) {
        day = json["day"].stringValue
        bpmMinimum = json["bpm_minimum"].intValue
        bpmMaximum = json["bpm_maximum"].intValue
        id = json["_id"].stringValue
    }
}

// Model for Sleep Data
class Sleep: Identifiable {
    var day = ""
    var awakeHours: Double = 0.00
    var remHours: Double = 0.00
    var coreHours: Double = 0.00
    var deepHours: Double = 0.00
    var id = ""

    init(_ json: JSON) {
        day = json["day"].stringValue
        awakeHours = json["awake_hours"].doubleValue
        remHours = json["rem_hours"].doubleValue
        coreHours = json["core_hours"].doubleValue
        deepHours = json["deep_hours"].doubleValue
        id = json["_id"].stringValue
    }
}

// Model for Step Count Data
class StepCount {
    var day = ""
    var steps = 0
    var id = ""

    init(_ json: JSON) {
        day = json["day"].stringValue
        steps = json["steps"].intValue
        id = json["_id"].stringValue
    }
}
