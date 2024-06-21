//
//  ExerciseCategoryModel.swift
//  PhysioSync
//
//  Created by Rohit on 2024-06-20.
//

import Foundation
import SwiftyJSON

class ExerciseCatergoryModel {

    var _v: Int?
    var imageLink: String?
    var name: String?
    var Id: String?

    init(_ json: JSON) {
        _v = json["__v"].intValue
        imageLink = json["image_link"].stringValue
        name = json["name"].stringValue
        Id = json["_id"].stringValue
    }

}
