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
    var categoryName = [String]()
    var categoryId = [String]()
    var description: String
    var id: String
    var videoUrl: String
    var therapistId: String
    var version: Int
    var isSelected = false
    var video_thumbnail = ""
    
    init(_ json: JSON) {
        categoryId.removeAll()
        categoryName.removeAll()
        for i in json["category_name"].arrayValue {
            categoryName.append(i.stringValue)
        }
        for i in json["category_id"].arrayValue {
            categoryId.append(i.stringValue)
        }
        videoTitle = json["video_title"].stringValue
        description = json["description"].stringValue
        id = json["_id"].stringValue
        videoUrl = json["video_Url"].stringValue
        therapistId = json["therapist_id"].stringValue
        version = json["__v"].intValue
        video_thumbnail = json["video_thumbnail"].stringValue
    }
}
