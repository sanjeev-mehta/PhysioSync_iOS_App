//
//  SingleExerciseModel.swift
//  PhysioSync
//
//  Created by Rohit on 2024-06-20.
//

import Foundation
import SwiftyJSON

class SingleExerciseModel {
    var videoTitle: String
    var categoryName: String
    var categoryId: String
    var description: String
    var id: String
    var videoUrl: String
    var therapistId: String
    var version: Int
    
    init(_ json: JSON) {
        videoTitle = json["video_title"].stringValue
        categoryName = json["category_name"].stringValue
        categoryId = json["category_id"].stringValue
        description = json["description"].stringValue
        id = json["_id"].stringValue
        videoUrl = json["video_Url"].stringValue
        therapistId = json["therapist_id"].stringValue
        version = json["__v"].intValue
    }
}
