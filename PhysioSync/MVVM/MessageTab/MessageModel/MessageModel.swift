//
//  MessageModel.swift
//  PhysioSync
//
//  Created by Sanjeev Mehta on 26/06/24.
//

import Foundation
import SwiftyJSON

class MessageModel {
    
    var patient: Patient?
    var message = ""
    var isRead = false
    var time = ""
    
    init(_ json: JSON) {
        self.patient = Patient(json)
        self.message = json["latestMessage"]["message_text"].stringValue
        self.isRead = json["latestMessage"]["is_read"].boolValue
        self.time = getTime(dateString: json["latestMessage"]["createdAt"].stringValue)
    }
    
    func getTime(dateString: String) -> String {
        let inputDateFormatter = DateFormatter()
        inputDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
        inputDateFormatter.locale = Locale(identifier: "en_US_POSIX")

        // Step 2: Convert the string to a Date object
        if let date = inputDateFormatter.date(from: dateString) {
            // Step 3: Create another DateFormatter to format the date to extract the time
            let outputDateFormatter = DateFormatter()
            outputDateFormatter.dateFormat = "hh:mm a"
            let timeString = outputDateFormatter.string(from: date)
            return timeString
        } else {
            return ""
        }
    }
}
