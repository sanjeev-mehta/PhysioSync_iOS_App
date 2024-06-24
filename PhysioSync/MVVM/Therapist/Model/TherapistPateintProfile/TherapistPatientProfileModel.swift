//
//  TherapistPatientProfileModel.swift
//  PhysioSync
//
//  Created by Gurmeet Singh on 2024-06-19.
//

import Foundation
import SwiftyJSON

class TherapistPatientProfileModel {
    
    var message = ""
    var success = false
    var data: TherapistPatientProfileData?
    
    init(_ json: JSON) {
        message = json["message"].stringValue
        success = json["success"].boolValue
        data = TherapistPatientProfileData(json["data"])
    }
}

class TherapistPatientProfileData {
    
    var exercise: [Exercise]?
    var patient: Patient?
    
    init(_ json: JSON) {
        exercise = json["exercise"].arrayValue.map { Exercise($0) }
        patient = Patient(json["patient"])
    }
    
}

class Exercise {

    var Id = ""
    var exerciseIds: [ExerciseIds]?
    var patientId = ""
    var startDate = ""
    var endDate = ""
    var status = ""
    var isAwaitingReviews = false
    var assignedAt = ""
    var _v = 0

    init(_ json: JSON) {
        Id = json["_id"].stringValue
        exerciseIds = json["exercise_ids"].arrayValue.map { ExerciseIds($0) }
        patientId = json["patient_id"].stringValue
        startDate = json["start_date"].stringValue
        endDate = json["end_date"].stringValue
        status = json["status"].stringValue
        isAwaitingReviews = json["is_awaiting_reviews"].boolValue
        assignedAt = json["assigned_at"].stringValue
        _v = json["__v"].intValue
    }

}

class ExerciseIds {

    var Id = ""
    var therapistId = ""
    var categoryName = ""
    var videoUrl = ""
    var videoTitle = ""
    var description = ""
    var _v = 0

    init(_ json: JSON) {
        Id = json["_id"].stringValue
        therapistId = json["therapist_id"].stringValue
        categoryName = json["category_name"].stringValue
        videoUrl = json["video_Url"].stringValue
        videoTitle = json["video_title"].stringValue
        description = json["description"].stringValue
        _v = json["__v"].intValue
    }

}

class Patient {

    var Id = ""
    var therapistId = ""
    var firstName = ""
    var lastName = ""
    var patientEmail = ""
    var injuryDetails = ""
    var password = ""
    var exerciseReminderTime = ""
    var medicineReminderTime = ""
    var dateOfBirth = ""
    var allergyIfAny = ""
    var profilePhoto = ""
    var gender = ""
    var medicalHistory = ""
    var createdAt = ""
    var updatedAt = ""
    var _v = 0
    var isActive = false

    init(_ json: JSON) {
        Id = json["_id"].stringValue
        therapistId = json["therapist_Id"].stringValue
        firstName = json["first_name"].stringValue
        lastName = json["last_name"].stringValue
        patientEmail = json["patient_email"].stringValue
        injuryDetails = json["injury_details"].stringValue
        password = json["password"].stringValue
        exerciseReminderTime = json["exercise_reminder_time"].stringValue
        medicineReminderTime = json["medicine_reminder_time"].stringValue
        dateOfBirth = json["date_of_birth"].stringValue
        allergyIfAny = json["allergy_if_any"].stringValue
        profilePhoto = json["profile_photo"].stringValue
        gender = json["gender"].stringValue
        medicalHistory = json["medical_history"].stringValue
        createdAt = json["created_at"].stringValue
        updatedAt = json["updated_at"].stringValue
        _v = json["__v"].intValue
        isActive = json["is_active"].boolValue
    }

}
