//
//  ChatScreenVC.swift
//  PhysioSync
//
//  Created by Gurmeet Singh on 2024-06-07.
//

import UIKit
import SwiftyJSON

class ChatScreenVC: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTf: UITextField!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var backImgVW: UIImageView!
    
    // MARK: - variables
    let chatVM = ChatViewModel.shareInstance
    var recieverId = ""
    var name = ""
    var profileImgLink = ""
    var currentUserId = ""
    var isPatient = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        chatVM.delegate = self
        if UserDefaults.standard.getTherapistName() != "" {
            self.isPatient = true
            self.nameLbl.text = UserDefaults.standard.getTherapistName()
            self.profileImg.setImage(with: UserDefaults.standard.getTherapistProfileImage())
            self.currentUserId = UserDefaults.standard.getPatientLoginId()
            self.recieverId = UserDefaults.standard.getTherapistId()
            self.backBtn.isHidden = true
            self.backImgVW.isHidden = true
        } else {
            self.currentUserId = UserDefaults.standard.getTherapistId()
            self.nameLbl.text = name
            self.profileImg.setImage(with: profileImgLink)
        }
    }
    
    func sendMessage() {
        let newMessage = ChatModel(
            _id: (JSON(rawValue: UUID().uuidString) ?? "").rawValue as! String,
            createdAt: Date().iso8601String,
            is_read: false,
            message_text:  messageTf.text!,
            receiver_id: recieverId,
            sender_id: currentUserId,
            updatedAt: Date().iso8601String,
            is_media: false
        )
        
        // Append the new message to the local array
        chatVM.chatArr.append(newMessage)
        tableView.reloadData()
        if isPatient {
            PatientHomeVC.socketHandler.sendMessage(userId: currentUserId, receiverId: recieverId, message: messageTf.text!, isMedia: false)
        } else {
            TherapistHomeVC.socketHandler.sendMessage(userId: currentUserId, receiverId: recieverId, message: messageTf.text!, isMedia: false)
        }
        
    }
    
    // MARK: - Buttons Action
    @IBAction func backBtnActn(_ sender: UIButton) {
        self.dismissOrPopViewController()
    }
    
    @IBAction func sendBtnActn(_ sender: UIButton) {
        if messageTf.text != "" {
            sendMessage()
        } else {
            // show alert
        }
    }
    
    // MARK: - TableView delegate & DataSource functions
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(chatVM.chatArr.count)
        return chatVM.chatArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = chatVM.chatArr[indexPath.row]
        if data.sender_id == currentUserId {
            
            if data.is_media {
                let cell = tableView.dequeueReusableCell(withIdentifier: "RightVideoChatTVC", for: indexPath) as! RightVideoChatTVC
                cell.selectionStyle = .none
                self.setCornerRadius(radius: 16, view: cell.bgView, isLeftCell: false)
                cell.dateLbl.textColor = UIColor.white
                cell.imgView.image = UIImage(named: data.media_link)
                cell.dateLbl.text = data.time
                if !data.is_video {
                    cell.playBtn.isHidden = true
                }
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "RightChatTVC", for: indexPath) as! RightChatTVC
                cell.messageLbl.text = data.message_text
                self.setCornerRadius(radius: 16, view: cell.bgView, isLeftCell: false)
                cell.messageLbl.textColor = UIColor.white
                cell.dateLbl.textColor = UIColor.white
                cell.selectionStyle = .none
                cell.dateLbl.text = data.time
                return cell
            }
        } else {
            if data.is_media {
                let cell = tableView.dequeueReusableCell(withIdentifier: "LeftVideoChatTVC", for: indexPath) as! LeftVideoChatTVC
                cell.selectionStyle = .none
                cell.imgView.image = UIImage(named: data.media_link)
                self.setCornerRadius(radius: 16, view: cell.bgView, isLeftCell: true)
                cell.dateLbl.text = data.time
                if !data.is_video {
                    cell.playBtn.isHidden = true
                }
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "LeftChatTVC", for: indexPath) as! LeftChatTVC
                cell.selectionStyle = .none
                cell.messageLbl.text = data.message_text
                self.setCornerRadius(radius: 16, view: cell.bgView, isLeftCell: true)
                cell.dateLbl.text = data.time
                return cell
            }
        }
       
    }
   
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let data = chatVM.chatArr[indexPath.row]
        if data.is_media {
            return 200
        } else {
            return UITableView.automaticDimension
        }
    }
    // MARK: - Corner radius
    
    func setCornerRadius(radius: CGFloat, view: UIView, isLeftCell: Bool) {
        view.clipsToBounds = true
        view.layer.cornerRadius = radius
        if isLeftCell {
            view.layer.maskedCorners = [.layerMaxXMinYCorner ,.layerMaxXMaxYCorner,.layerMinXMaxYCorner ]
            
        } else {
            view.layer.maskedCorners = [.layerMaxXMinYCorner,.layerMinXMinYCorner, .layerMinXMaxYCorner,]
        }
        
    }
}

extension ChatScreenVC: ChatViewModelDelegate {
    func didReceiveMessages() {
        self.tableView.reloadData()
        self.tableView.scrollToRow(at: IndexPath(row: chatVM.chatArr.count - 1, section: 0), at: .bottom, animated: false)
    }
    
    
}

extension Date {
    var iso8601String: String {
        let formatter = ISO8601DateFormatter()
        return formatter.string(from: self)
    }
}
