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
    var watchData: WatchData?
    
    init(_ json: JSON) {
        exercise = json["exercise"].arrayValue.map { Exercise($0) }
        patient = Patient(json["patient"])
        watchData = WatchData(json["watchData"])
        
    }
    
}

class Exercise {

    var Id = ""
    var exerciseIds = [SingleExerciseModel]()
    var exerciseIds2 = [SingleExerciseModel2]()
    var patientId = ""
    var startDate = ""
    var endDate = ""
    var status = ""
    var isAwaitingReviews = false
    var assignedAt = ""
    var _v = 0

    init(_ json: JSON) {
        Id = json["_id"].stringValue
        exerciseIds = json["exercise_ids"].arrayValue.map { SingleExerciseModel($0) }
        exerciseIds2 = json["exercise_ids"].arrayValue.map { SingleExerciseModel2($0) }
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
    var unreadCount = 0
    var address = ""
    var phone_no = ""
    
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
        unreadCount = json["unreadCount"].intValue
        address = json["address"].stringValue
        phone_no = json["phone_no"].stringValue
    }

    init(
         Id: String,
         therapistId: String,
         firstName: String,
         lastName: String,
         patientEmail: String,
         injuryDetails: String,
         password: String,
         exerciseReminderTime: String,
         medicineReminderTime: String,
         dateOfBirth: String,
         allergyIfAny: String,
         profilePhoto: String,
         gender: String,
         medicalHistory: String,
         createdAt: String,
         updatedAt: String,
         _v: Int,
         isActive: Bool,
         unreadCount: Int,
         address: String,
         phone_no: String
     ) {
         self.Id = Id
         self.therapistId = therapistId
         self.firstName = firstName
         self.lastName = lastName
         self.patientEmail = patientEmail
         self.injuryDetails = injuryDetails
         self.password = password
         self.exerciseReminderTime = exerciseReminderTime
         self.medicineReminderTime = medicineReminderTime
         self.dateOfBirth = dateOfBirth
         self.allergyIfAny = allergyIfAny
         self.profilePhoto = profilePhoto
         self.gender = gender
         self.medicalHistory = medicalHistory
         self.createdAt = createdAt
         self.updatedAt = updatedAt
         self._v = _v
         self.isActive = isActive
         self.unreadCount = unreadCount
         self.address = address
         self.phone_no = phone_no
     }
}
