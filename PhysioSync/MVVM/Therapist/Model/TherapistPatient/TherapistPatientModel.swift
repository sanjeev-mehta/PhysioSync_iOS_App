//
//  TherapistPatientModel.swift
//  PhysioSync
//
//  Created by Gurmeet Singh on 2024-06-19.
//

import Foundation
import SwiftyJSON

class TherapistPatientModel {

    var data: [TherapistPatientData]?
    var success = false

    init(_ json: JSON) {
        data = json["data"].arrayValue.map { TherapistPatientData($0) }
        success = json["success"].boolValue
    }
}


class TherapistPatientData {

    var gender = ""
    var isActive = false
    var patientEmail = ""
    var dateOfBirth = ""
    var injuryDetails = ""
    var Id = ""
    var therapistId = ""
    var lastName = ""
    var medicineReminderTime = ""
    var profilePhoto = ""
    var exerciseReminderTime = ""
    var medicalHistory = ""
    var allergyIfAny = ""
    var createdAt = ""
    var firstName = ""
    var updatedAt = ""
    var _v: Int?

    init(_ json: JSON) {
        gender = json["gender"].stringValue
        isActive = json["is_active"].boolValue
        patientEmail = json["patient_email"].stringValue
        dateOfBirth = json["date_of_birth"].stringValue
        injuryDetails = json["injury_details"].stringValue
        Id = json["_id"].stringValue
        therapistId = json["therapist_Id"].stringValue
        lastName = json["last_name"].stringValue
        medicineReminderTime = json["medicine_reminder_time"].stringValue
        profilePhoto = json["profile_photo"].stringValue
        exerciseReminderTime = json["exercise_reminder_time"].stringValue
        medicalHistory = json["medical_history"].stringValue
        allergyIfAny = json["allergy_if_any"].stringValue
        createdAt = json["created_at"].stringValue
        firstName = json["first_name"].stringValue
        updatedAt = json["updated_at"].stringValue
        _v = json["__v"].intValue
    }

}
