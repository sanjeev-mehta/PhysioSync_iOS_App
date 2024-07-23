//
//  ChatViewModel.swift
//  PhysioSync
//
//  Created by Sanjeev Mehta on 26/06/24.
//

import UIKit
import SwiftyJSON

class ChatViewModel {
    
    static let shareInstance = ChatViewModel()
    var chatArr = [ChatModel]()
    var messageID = [String]()
    var delegate: ChatViewModelDelegate?
    var currentUser = ""
    
    func getAllMessages(json: JSON) {
        var arr = [ChatModel]()
        for i in json[0].arrayValue {
            arr.append(ChatModel(i))
        }
        messageID.removeAll()
        for i in chatArr {
            if i.receiver_id == currentUser {
                if !i.is_read {
                    self.messageID.append(i._id)
                }
            }
            
        }
        if chatArr.count == arr.count || arr.count == 0 {
            return
        }
        chatArr = arr
        chatArr.reverse()
        delegate?.didReceiveMessages()
    }
    
    func readMessage(isPatienSide: Bool) {
        if isPatienSide {
            PatientHomeVC.socketHandler.markMessagesAsRead(messageIDs: messageID)
        } else {
            TherapistHomeVC.socketHandler.markMessagesAsRead(messageIDs: messageID)
        }
    }
}

protocol ChatViewModelDelegate: AnyObject {
    func didReceiveMessages()
}
