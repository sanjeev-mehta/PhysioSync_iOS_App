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
    var message: String?

    init(_ json: JSON) {
        success = json["success"].boolValue
        data = PatientHomeData(json["data"])
        message = json["message"].stringValue
    }

}

class PatientHomeData {

    var exercise = [Exercise]()
    var patient: Patient?

    init(_ json: JSON) {
        exercise = json["exercise"].arrayValue.map { Exercise($0) }
        patient = Patient(json["patient"])
    }

}

