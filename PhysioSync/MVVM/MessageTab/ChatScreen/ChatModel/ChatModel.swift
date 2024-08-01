//
//  ChatModel.swift
//  PhysioSync
//
//  Created by Sanjeev Mehta on 26/06/24.
//

import Foundation
import SwiftyJSON
import AVFoundation

class ChatModel {
    
    var __v = 0;
    var _id = "";
    var createdAt = "";
    var is_read = false;
    var message_text = "";
    var receiver_id = "";
    var sender_id = "";
    var updatedAt = "";
    var media_link = ""
    var is_media = false
    var is_video = false
    var time = ""
    var progress: Float = 0.0
    var thumbnailImg: UIImage?
    
    init(_ json: JSON) {
        self._id = json["_id"].stringValue
        self.is_read = json["is_read"].boolValue
        self.createdAt = json["createdAt"].stringValue
        self.message_text = json["message_text"].stringValue
        self.receiver_id = json["receiver_id"].stringValue
        self.sender_id = json["sender_id"].stringValue
        self.updatedAt = json["updatedAt"].stringValue
        self.time = getTime(dateString: self.createdAt)
        self.media_link = json["media_link"].stringValue
        self.is_media = json["is_media"].boolValue
        self.is_video = json["is_video"].boolValue
        self.progress = 1.0
        
        if is_video {
            self.getThumbnailImageFromVideoUrl(url: URL(string: media_link)!, completion: { image in
                if let img = image {
                    self.thumbnailImg = image!
                } else {
                }
            })
        }
    }
    
    init(__v: Int = 0, _id: String = "", createdAt: String = "", is_read: Bool = false, message_text: String = "", receiver_id: String = "", sender_id: String = "", updatedAt: String = "", media_link: String = "", is_media: Bool = false, is_video: Bool = false, time: String = "", progess: Float = 0.0) {
        self.__v = __v
        self._id = _id
        self.createdAt = createdAt
        self.is_read = is_read
        self.message_text = message_text
        self.receiver_id = receiver_id
        self.sender_id = sender_id
        self.updatedAt = updatedAt
        self.media_link = media_link
        self.is_media = is_media
        self.is_video = is_video
        self.time = time
        self.progress = progess
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
    
    func getThumbnailImageFromVideoUrl(url: URL, completion: @escaping ((_ image: UIImage?)->Void)) {
        DispatchQueue.global().async { //1
            let asset = AVAsset(url: url) //2
            let avAssetImageGenerator = AVAssetImageGenerator(asset: asset) //3
            avAssetImageGenerator.appliesPreferredTrackTransform = true //4
            let thumnailTime = CMTimeMake(value: 2, timescale: 1) //5
            do {
                let cgThumbImage = try avAssetImageGenerator.copyCGImage(at: thumnailTime, actualTime: nil) //6
                let thumbNailImage = UIImage(cgImage: cgThumbImage) //7
                DispatchQueue.main.async { //8
                    completion(thumbNailImage) //9
                }
            } catch {
                print(error.localizedDescription) //10
                DispatchQueue.main.async {
                    completion(nil) //11
                }
            }
        }
    }
}

