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
    var filterArr = [MessageModel]()
    
    func responseParse(json: JSON) {
        model.removeAll()
        for i in json[0].arrayValue {
            model.append(MessageModel(i))
        }
        filterArr = model
    }
    
    func getUserCount() -> Int {
        return filterArr.count
    }
   
    func setUpCell(_ cell: MessageTVC, index: Int) {
        if let data = filterArr[index].patient {
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
    
    func filter(query: String) {
        if query.isEmpty {
            filterArr = model
        } else {
            filterArr = model.filter { patient in
                return patient.patient!.firstName.lowercased().contains(query.lowercased()) ||
                patient.patient!.lastName.lowercased().contains(query.lowercased())
            }
            // Print each patient's properties
                for patient in filterArr {
                    print("First Name: \(patient.patient?.firstName)")
                }
        }
    }
    
    func unreadCount() -> Int {
        var count = 0
        for i in model {
           count += i.unreadCount
        }
        return count
    }
}
