//
//  TherapistHomeModel.swift
//  PhysioSync
//
//  Created by Sanjeev Mehta on 24/06/24.
//

import SwiftyJSON

class TherapistNotificationModel {
    
    var message = ""
    var status: Int?
    var data = [TherapistNotificationData]()
    var success = false
    
    init(_ json: JSON) {
        message = json["message"].stringValue
        status = json["status"].intValue
        data = json["data"].arrayValue.map { TherapistNotificationData($0) }
        success = json["success"].boolValue
    }
}

class TherapistNotificationData {
    
    var exerciseIds = [String]()
    var therapistId = ""
    var status = ""
    var patientId: Patient
    var Id = ""
    var startDate = ""
    var assignedAt = ""
    var isAwaitingReviews = false
    var endDate = ""
    var _v: Int?
    var patientVideoUrl = ""
    var patientExerciseCompletionDateTime = ""
    var days = ""
    var video_title = ""
    
    init(_ json: JSON) {
        exerciseIds = json["exercise_ids"].arrayValue.map { $0.stringValue }
        therapistId = json["therapist_id"].stringValue
        status = json["status"].stringValue
        patientId = Patient(json["patient_id"])
        Id = json["_id"].stringValue
        startDate = json["start_date"].stringValue
        assignedAt = json["assigned_at"].stringValue
        isAwaitingReviews = json["is_awaiting_reviews"].boolValue
        endDate = json["end_date"].stringValue
        _v = json["__v"].intValue
        patientVideoUrl = json["patient_video_url"].stringValue
        patientExerciseCompletionDateTime = json["patient_exercise_completion_date_time"].stringValue
        self.days = getDays(self.patientExerciseCompletionDateTime)
        self.video_title = json["exercise_ids"][0]["video_title"].stringValue
    }
    
    func getDays(_ CompletionDate: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let date = dateFormatter.date(from: CompletionDate)!
        let currentDate = Date()
        let calendar = Calendar.current
        
        let components = calendar.dateComponents([.day], from: date, to: currentDate)
        
        if let days = components.day {
            switch days {
            case 0:
                return "today"
            case 1:
                return "yesterday"
            default:
                return "\(days) days ago"
            } 
        } else {
            return CompletionDate
        }
    }
}
