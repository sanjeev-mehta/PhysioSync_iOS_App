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
    
    func getAllMessages(json: JSON) {
        print(json)
        chatArr.removeAll()
        for i in json[0].arrayValue {
            chatArr.append(ChatModel(i))
        }
        print(chatArr)
        for i in chatArr {
            if !i.is_read {
                self.messageID.append(i._id)
            }
        }
        chatArr.reverse()
        print(self.messageID)
        delegate?.didReceiveMessages()
    }
    
    func readMessage() {
        TherapistHomeVC.socketHandler.markMessagesAsRead(messageIDs: messageID)
    }

}


protocol ChatViewModelDelegate: AnyObject {
    func didReceiveMessages()
}
