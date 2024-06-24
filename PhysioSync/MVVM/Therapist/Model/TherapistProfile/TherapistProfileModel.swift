//
//  TherapistProfileModel.swift
//  PhysioSync
//
//  Created by Gurmeet Singh on 2024-06-24.
//

import SwiftyJSON

class TherapistProfileModel {

    var success = false
    var status: Int?
    var message = ""
    var data: TherapistProfileData?

    init(_ json: JSON) {
        success = json["success"].boolValue
        status = json["status"].intValue
        message = json["message"].stringValue
        data = TherapistProfileData(json["data"])
    }

}

class TherapistProfileData {

    var _v: Int?
    var profilePhoto = ""
    var therapistName = ""
    var isAuthenticated = false
    var clinic: Clinic?
    var firebaseUid = ""
    var email = ""
    var Id = ""

    init(_ json: JSON) {
        _v = json["__v"].intValue
        profilePhoto = json["profile_photo"].stringValue
        therapistName = json["therapist_name"].stringValue
        isAuthenticated = json["is_authenticated"].boolValue
        clinic = Clinic(json["clinic"])
        firebaseUid = json["firebase_uid"].stringValue
        email = json["email"].stringValue
        Id = json["_id"].stringValue
    }

}
