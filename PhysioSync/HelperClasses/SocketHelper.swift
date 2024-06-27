//
//  SocketHelper.swift
//  PhysioSync
//
//  Created by Sanjeev Mehta on 26/06/24.
//

import Foundation
import SocketIO
import SwiftyJSON

class SocketIOHandler {
    
    private var manager: SocketManager
    private var socket: SocketIOClient
    var messageID = [String]()
    let messageVM = MessageViewModel.shareInstance
    let chatVM = ChatViewModel.shareInstance
    
    init(url: String) {
        self.manager = SocketManager(socketURL: URL(string: url)!, config: [.log(true), .compress])
        self.socket = manager.defaultSocket
        addHandlers()
    }
    
    func connect() {
        socket.connect()
    }
    
    func disconnect() {
        socket.disconnect()
    }
    
    private func addHandlers() {
        socket.on(clientEvent: .connect) { [weak self] data, ack in
            print("Socket connected")
            // Example event emission
            // self?.socket.emit("new-user-joined", "123457")
        }
        
        socket.on(clientEvent: .disconnect) { data, ack in
            print("Socket disconnected")
        }
        
        socket.on(clientEvent: .error) { data, ack in
            print("Socket error: \(data)", ack)
        }
        
        socket.on("receive") { [weak self] data, ack in
            if let messageData = data[0] as? [String: Any],
               let sender = messageData["sender"] as? String,
               let message = messageData["message"] as? String,
               let messageId = messageData["id"] as? String {
                self?.messageID.append(messageId)
                print("Received message from \(sender): \(message) \(messageId)")
            }
        }
        
        socket.on("user-joined") { data, ack in
            print(data)
        }
        
        socket.on("messageReadResponse") { data, ack in
            
        }
        
        socket.on("typing") { data, ack in
            print(data, ack)
        }
        
        socket.on("allPatientsWithDetails") { data, ack in
            let swifty = JSON(data)
            self.messageVM.responseParse(json: swifty)
        }
        
        socket.on("previousMessages") { data, ack in
            print(data)
            let swifty = JSON(data)
            self.chatVM.getAllMessages(json: swifty)
            
        }
    }
    
    func fetchAllPatient(id: String) {
        socket.emit("fetchAllPatientsWithDetails", id)
    }
    
    func fetchPreviousMessage(_ senderId: String, _ receiverId: String) {
        let data: [String: Any] = ["senderId": senderId, "receiverId": receiverId]
        socket.emit("fetchPreviousMessages", data)
    }
    
    func sendMessage(userId: String, receiverId: String, message: String, isMedia: Bool) {
        let data: [String: Any] = ["senderId": userId, "receiverId": receiverId, "message": message, "is_media": isMedia]
        socket.emit("send", data)
    }
    
    func sendTypingStatus(userId: String, isTyping: Bool) {
        let data = ["id": userId, "isTyping": isTyping] as [String: Any]
        socket.emit("typing", data)
    }
    
    func markMessagesAsRead(messageIDs: [String]) {
        socket.emit("messageRead", messageIDs)
    }
}

protocol SocketIOHandlerDelegate: AnyObject {
    func didReceiveMessage()
    func updatePatientList()
}
