//
//  MessageViewModel.swift
//  PhysioSync
//
//  Created by Sanjeev Mehta on 26/06/24.
//

import UIKit
import SwiftyJSON

class MessageViewModel {
    
    static let shareInstance = MessageViewModel()
    let apiHelper = ApiHelper.shareInstance
    var model = [MessageModel]()
    
    func responseParse(json: JSON) {
        model.removeAll()
        for i in json[0].arrayValue {
            model.append(MessageModel(i))
        }
    }
    
    func getUserCount() -> Int {
        return model.count
    }
   
    func setUpCell(_ cell: MessageTVC, index: Int) {
        if let data = model[index].patient {
            cell.profileImgView.setImage(with: data.profilePhoto)
            cell.nameLbl.text = data.firstName + " " + data.lastName
            cell.msgLbl.text = model[index].message
            if data.unreadCount == 0 {
                cell.badgeLbl.text = ""
                cell.badgeLbl.isHidden = true
                cell.msgLbl.font = UIFont(name: "Outfit-Regular", size: 14.0)!
            } else {
                cell.badgeLbl.text = "\(data.unreadCount)"
                cell.badgeLbl.isHidden = false
                cell.msgLbl.font = UIFont(name: "Outfit-Bold", size: 14.0)!
            }
           
            cell.timeLbl.text = model[index].time
        }
    }
    
}
