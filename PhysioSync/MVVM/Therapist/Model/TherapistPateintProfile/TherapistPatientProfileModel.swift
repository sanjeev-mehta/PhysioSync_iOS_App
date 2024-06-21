//
//  TherapistPatientProfileModel.swift
//  PhysioSync
//
//  Created by Gurmeet Singh on 2024-06-19.
//

import Foundation
import SwiftyJSON

class TherapistPatientProfileModel{
    var data: [TherapistPatientProfileData]?
    var status = 0
    var success = false
    var message = ""
    
    init(_ json: JSON) {
        data = json["data"].arrayValue.map { TherapistPatientProfileData($0) }
        status = json["status"].intValue
        success = json["success"].boolValue
        message = json["message"].stringValue
    }
}

class TherapistPatientProfileData {

    var patientId: PatientId?
    var assignedAt = ""
    var exerciseId = ""
    var Id = ""
    var isAwaitingReviews = false
    var endDate = ""
    var therapistId = ""
    var status = ""
    var startDate = ""
    var _v = 0

    init(_ json: JSON) {
        patientId = PatientId(json["patient_id"])
        assignedAt = json["assigned_at"].stringValue
        exerciseId = json["exercise_id"].stringValue
        Id = json["_id"].stringValue
        isAwaitingReviews = json["is_awaiting_reviews"].boolValue
        endDate = json["end_date"].stringValue
        therapistId = json["therapist_id"].stringValue
        status = json["status"].stringValue
        startDate = json["start_date"].stringValue
        _v = json["__v"].intValue
    }

}

class PatientId {

    var profilePhoto = ""
    var medicalHistory = ""
    var therapistId = ""
    var password = ""
    var allergyIfAny = ""
    var firstName = ""
    var patientEmail = ""
    var lastName = ""
    var updatedAt = ""
    var isActive = false
    var createdAt = ""
    var Id = ""
    var _v = 0
    var gender = ""
    var dateOfBirth = ""
    var injuryDetails = ""
    var medicineReminderTime = ""
    var exerciseReminderTime = ""

    init(_ json: JSON) {
        profilePhoto = json["profile_photo"].stringValue
        medicalHistory = json["medical_history"].stringValue
        therapistId = json["therapist_Id"].stringValue
        password = json["password"].stringValue
        allergyIfAny = json["allergy_if_any"].stringValue
        firstName = json["first_name"].stringValue
        patientEmail = json["patient_email"].stringValue
        lastName = json["last_name"].stringValue
        updatedAt = json["updated_at"].stringValue
        isActive = json["is_active"].boolValue
        createdAt = json["created_at"].stringValue
        Id = json["_id"].stringValue
        _v = json["__v"].intValue
        gender = json["gender"].stringValue
        dateOfBirth = json["date_of_birth"].stringValue
        injuryDetails = json["injury_details"].stringValue
        medicineReminderTime = json["medicine_reminder_time"].stringValue
        exerciseReminderTime = json["exercise_reminder_time"].stringValue
    }

}
