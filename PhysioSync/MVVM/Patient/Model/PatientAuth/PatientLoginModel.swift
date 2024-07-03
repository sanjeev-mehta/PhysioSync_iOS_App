//
//  PatientLoginModel.swift
//  PhysioSync
//
//  Created by Sanjeev Mehta on 21/06/24.
//

import SwiftyJSON

class PatientVerifyEmailModel: Codable {
    
    var success: Bool
    var data: [PatientVerifyEmailData]
    var message: String
    
    init(_ json: JSON) {
        success = json["success"].boolValue
        data = json["data"].arrayValue.map { PatientVerifyEmailData($0) }
        message = json["message"].stringValue
    }
    
}

class PatientVerifyEmailData: Codable {
    
    var exerciseReminderTime: String
    var createdAt: String
    var gender: String
    var medicineReminderTime: String
    var therapistId: String
    var patientEmail: String
    var lastName: String
    var allergyIfAny: String
    var isActive: Bool
    var profilePhoto: String
    var Id: String
    var injuryDetails: String
    var _v: Int
    var password: String
    var dateOfBirth: String
    var updatedAt: String
    var firstName: String
    var medicalHistory: String
    
    init(_ json: JSON) {
        exerciseReminderTime = json["exercise_reminder_time"].stringValue
        createdAt = json["created_at"].stringValue
        gender = json["gender"].stringValue
        medicineReminderTime = json["medicine_reminder_time"].stringValue
        therapistId = json["therapist_Id"].stringValue
        patientEmail = json["patient_email"].stringValue
        lastName = json["last_name"].stringValue
        allergyIfAny = json["allergy_if_any"].stringValue
        isActive = json["is_active"].boolValue
        profilePhoto = json["profile_photo"].stringValue
        Id = json["_id"].stringValue
        injuryDetails = json["injury_details"].stringValue
        _v = json["__v"].intValue
        password = json["password"].stringValue
        dateOfBirth = json["date_of_birth"].stringValue
        updatedAt = json["updated_at"].stringValue
        firstName = json["first_name"].stringValue
        medicalHistory = json["medical_history"].stringValue
    }
}

class PatientLoginModel {
    
    var data: PatientUserData?
    var token: Token?
    var status = 0
    var message = ""
    var success = false
    
    init(_ json: JSON) {
        data = PatientUserData(json["data"])
//        token = Token(json["token"])
        status = json["status"].intValue
        message = json["message"].stringValue
        success = json["success"].boolValue
    }
    
}

class PatientUserData {

    var exerciseReminderTime = ""
    var lastName = ""
    var allergyIfAny = ""
    var password = ""
    var dateOfBirth = ""
    var isActive = false
    var profilePhoto = ""
    var salt = ""
    var patientEmail = ""
    var injuryDetails = ""
    var medicalHistory = ""
    var updatedAt = ""
    var firstName = ""
    var createdAt = ""
    var medicineReminderTime = ""
    var gender = ""
    var Id = ""
    var _v = 0
    var therapist: TherapistId?
    
    init(_ json: JSON) {
        exerciseReminderTime = json["exercise_reminder_time"].stringValue
        lastName = json["last_name"].stringValue
        allergyIfAny = json["allergy_if_any"].stringValue
        password = json["password"].stringValue
        dateOfBirth = json["date_of_birth"].stringValue
        isActive = json["is_active"].boolValue
        profilePhoto = json["profile_photo"].stringValue
        salt = json["salt"].stringValue
        patientEmail = json["patient_email"].stringValue
        injuryDetails = json["injury_details"].stringValue
        medicalHistory = json["medical_history"].stringValue
        updatedAt = json["updated_at"].stringValue
        firstName = json["first_name"].stringValue
        createdAt = json["created_at"].stringValue
        medicineReminderTime = json["medicine_reminder_time"].stringValue
        gender = json["gender"].stringValue
        Id = json["_id"].stringValue
        _v = json["__v"].intValue
        therapist = TherapistId(json["therapist_Id"])
    }

}

class TherapistId {

    var therapistName = ""
    var isAuthenticated = false
    var clinic: Clinic?
    var email = ""
    var _v = 0
    var authentication: Authentication?
    var Id = ""
    var profilePhoto = ""
    var firebaseUid = ""

    init(_ json: JSON) {
        therapistName = json["therapist_name"].stringValue
        isAuthenticated = json["is_authenticated"].boolValue
        clinic = Clinic(json["clinic"])
        email = json["email"].stringValue
        _v = json["__v"].intValue
        authentication = Authentication(json["authentication"])
        Id = json["_id"].stringValue
        profilePhoto = json["profile_photo"].stringValue
        firebaseUid = json["firebase_uid"].stringValue
    }
}

class Token {

}
