//
//  TherapistLoginModel.swift
//  PhysioSync
//
//  Created by Sanjeev Mehta on 22/05/24.
//

import UIKit
import SwiftyJSON

class TherapistLoginModel {

    var message = ""
    var data: TherapistLoginData?

    init(_ json: JSON) {
        message = json["message"].stringValue
        data = TherapistLoginData(json["data"])
    }

}

class TherapistLoginData {

    var _v = 0
    var isAuthenticated = false
    var Id = ""
    var authentication: Authentication?
    var firebaseUid = ""
    var email = ""
    var clinic: Clinic?
    var profilePhoto = ""
    var therapistName = ""

    init(_ json: JSON) {
        _v = json["__v"].intValue
        isAuthenticated = json["is_authenticated"].boolValue
        Id = json["_id"].stringValue
        authentication = Authentication(json["authentication"])
        firebaseUid = json["firebase_uid"].stringValue
        email = json["email"].stringValue
        clinic = Clinic(json["clinic"])
        profilePhoto = json["profile_photo"].stringValue
        therapistName = json["therapist_name"].stringValue
    }

}

class Authentication {

    var sessionToken = ""
    var password = ""
    var salt = ""
    var Id = ""

    init(_ json: JSON) {
        sessionToken = json["sessionToken"].stringValue
        password = json["password"].stringValue
        salt = json["salt"].stringValue
        Id = json["_id"].stringValue
    }

}

class Clinic {

    var name = ""
    var contactNo = ""
    var address = ""
    var Id = ""

    init(_ json: JSON) {
        name = json["name"].stringValue
        contactNo = json["contact_no"].stringValue
        address = json["address"].stringValue
        Id = json["_id"].stringValue
    }

}
