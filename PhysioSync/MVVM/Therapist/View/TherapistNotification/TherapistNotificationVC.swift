//
//  TherapistNotificationVC.swift
//  PhysioSync
//
//  Created by Gurmeet Singh on 2024-06-10.
//

import UIKit

class TherapistNotificationVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var notificationView: UIView!
    @IBOutlet weak var acknowledgeView: UIView!
    @IBOutlet weak var replyView: UIView!
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var exerciseNameLbl: UILabel!
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var notificationNotFoundImgView: UIImageView!
    
    // MARK: - Variables
    private let vm = TherapistHomeViewModel.shareInstance
    private var videoPlayer: CustomVideoPlayer?
    private var selectedIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        closeNotifcationView()
        setNotificationView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setHeader("Notifications", isBackBtn: true) {
            self.navigationController?.popViewController(animated: true)
        } rightButtonAction: {}

    }
    
    func setNotificationView() {
        acknowledgeView.addTopCornerRadius(radius: 16)
        replyView.clipsToBounds = true
        replyView.layer.cornerRadius = 16
        replyView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMinYCorner]
    }
    
    func openNotifcationView() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 10, options: .curveEaseInOut, animations: {
            self.notificationView.transform = CGAffineTransform.identity
            self.notificationView.alpha = 1.0
            self.view.bringSubviewToFront(self.notificationView)
        }, completion: nil)
    }
    
    func closeNotifcationView() {
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 10, options: .curveEaseInOut, animations: {
            self.notificationView.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
            self.notificationView.alpha = 0.0
        }, completion: nil)
    }
    
    private func setupVideoPlayer(url: String) {
        videoPlayer = CustomVideoPlayer(frame: videoView.bounds)
        videoPlayer?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        if let videoPlayer = videoPlayer {
            videoView.addSubview(videoPlayer)
            if let videoURL = URL(string: url) {
                videoPlayer.configure(url: videoURL)
                videoPlayer.play()
            }
        }
    }
    
    // MARK: - Buttons Actions
    @IBAction func cancelBtnActn(_ sender: UIButton) {
        videoPlayer?.pause()
        sender.pressedAnimation {
            self.closeNotifcationView()
        }
    }
    
    @IBAction func acknowBtnActn(_ sender: UIButton) {
        let tag = sender.tag
        videoPlayer?.pause()
        if let model = vm.notificationModel {
            let parm: [String: Any] = ["is_awaiting_reviews": true]
            vm.acknowledgeExercise(vc: self, id: model.data[tag].Id, parm: parm) { status in
                if status {
                    self.vm.getNotificationApi(vc: self) { status in
                        self.closeNotifcationView()
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }
    
    @IBAction func replyPrivatelyBtnActn(_ sender: UIButton) {
        let tag = sender.tag
        if let model = vm.notificationModel {
            let parm: [String: Any] = ["is_awaiting_reviews": true]
            vm.acknowledgeExercise(vc: self, id: model.data[tag].Id, parm: parm) { status in
                if status {
                    if let vc = self.switchController(.chatVC, .messageTab) as? ChatScreenVC {
                        vc.recieverId = model.data[tag].patientId.Id
                        vc.name = model.data[tag].patientId.firstName + " " + model.data[tag].patientId.lastName
                        vc.profileImgLink = model.data[tag].patientId.profilePhoto
                        vc.isPatient = false
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                    self.closeNotifcationView()
                    self.vm.getNotificationApi(vc: self) { _ in
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }
}

// MARK: - Table View DataSource and delegate methods
extension TherapistNotificationVC: UITableViewDelegate ,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if vm.getCount() == 0 {
            self.tableView.isHidden = true
            self.imgView.isHidden = false
        } else {
            self.tableView.isHidden = false
            self.imgView.isHidden = true
        }
        return vm.getCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationTVC", for: indexPath) as! NotificationTVC
        if let model = self.vm.notificationModel {
            let data = model.data[indexPath.row]
            self.getThumbnailImageFromVideoUrl(url: URL(string: data.patientVideoUrl)!) { image in
                cell.imgView.image = image
            }
            cell.daysLbl.text = data.days
            cell.msgLbl.text = "\(data.patientId.firstName + " " + data.patientId.lastName) Sent Video"
        }
        cell.watchVideoBtn.tag = indexPath.row
        cell.watchVideoBtn.addTarget(self, action: #selector(watchVideoBtnActn(_ :)), for: .touchUpInside)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    @objc func watchVideoBtnActn(_ sender: UIButton) {
        let tag = sender.tag
        sender.pressedAnimation {
            if let model = self.vm.notificationModel {
                self.nameLbl.text = model.data[tag].patientId.firstName + " " + model.data[tag].patientId.lastName
                self.timeLbl.text = model.data[tag].days
                self.exerciseNameLbl.text = model.data[tag].video_title
                self.setupVideoPlayer(url: model.data[tag].patientVideoUrl)
                self.imgView.setImage(with: model.data[tag].patientId.profilePhoto)
                self.openNotifcationView()
            }
        }
    }
}
