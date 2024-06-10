//
//  ChatScreenVC.swift
//  PhysioSync
//
//  Created by Gurmeet Singh on 2024-06-07.
//

import UIKit

class ChatScreenVC: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - variables
    var messageArr = [MessageData]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        setData()
    }
    
    func setData() {
        messageArr.append(MessageData(is_video: false, message: "Hello, I need your help today!", media_link: "", is_image: false))
        messageArr.append(MessageData(is_video: true, message: "", media_link: "img1", is_image: false))
        messageArr.append(MessageData(is_video: true, message: "", media_link: "img1", is_image: false))
        messageArr.append(MessageData(is_video: false, message: "Hello, I need your help today!", media_link: "", is_image: false))
        messageArr.append(MessageData(is_video: false, message: "Hello, I need your help today!", media_link: "img1", is_image: true))
        messageArr.append(MessageData(is_video: false, message: "Hello, I need your help today!", media_link: "img1", is_image: true))
        self.tableView.showsVerticalScrollIndicator = false
        self.tableView.reloadData()
    }
    
    // MARK: - TableView delegate & DataSource functions
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = messageArr[indexPath.row]
        if (indexPath.row % 2 == 0) {
            
            if data.is_video || data.is_image {
                let cell = tableView.dequeueReusableCell(withIdentifier: "RightVideoChatTVC", for: indexPath) as! RightVideoChatTVC
                cell.selectionStyle = .none
                self.setCornerRadius(radius: 16, view: cell.bgView, isLeftCell: false)
                cell.bgView.backgroundColor = UIColor.black
                cell.dateLbl.textColor = UIColor.white
                cell.imgView.image = UIImage(named: data.media_link)
                if data.is_image {
                    cell.playBtn.isHidden = true
                }
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "RightChatTVC", for: indexPath) as! RightChatTVC
                cell.messageLbl.text = data.message
                self.setCornerRadius(radius: 16, view: cell.bgView, isLeftCell: false)
                cell.bgView.backgroundColor = UIColor.black
                cell.messageLbl.textColor = UIColor.white
                cell.dateLbl.textColor = UIColor.white
                cell.selectionStyle = .none
                return cell
            }
        } else {
            if data.is_video || data.is_image {
                let cell = tableView.dequeueReusableCell(withIdentifier: "LeftVideoChatTVC", for: indexPath) as! LeftVideoChatTVC
                cell.selectionStyle = .none
                cell.imgView.image = UIImage(named: data.media_link)
                self.setCornerRadius(radius: 16, view: cell.bgView, isLeftCell: true)
                if data.is_image {
                    cell.playBtn.isHidden = true
                }
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "LeftChatTVC", for: indexPath) as! LeftChatTVC
                cell.messageLbl.text = messageArr[indexPath.row].message
                self.setCornerRadius(radius: 16, view: cell.bgView, isLeftCell: true)
                cell.selectionStyle = .none
                return cell
            }
        }
       
    }
   
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let data = messageArr[indexPath.row]
        if data.is_video || data.is_image {
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

struct MessageData {
    var is_video = false
    var message = ""
    var media_link = ""
    var is_image = false
    
    init(is_video: Bool = false, message: String = "", media_link: String = "", is_image: Bool = false) {
        self.is_video = is_video
        self.message = message
        self.media_link = media_link
        self.is_image = is_image
    }
}
