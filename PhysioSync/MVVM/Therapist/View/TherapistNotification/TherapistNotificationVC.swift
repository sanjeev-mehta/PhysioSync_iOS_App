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
        replyView.addBottomCornerRadius(radius: 16)
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
            let parm: [String: Any] = ["is_awaiting_reviews": true, "exercise_ids": model.data[0].exerciseIds[tag].id]
            vm.acknowledgeExercise(vc: self, id: model.data[0].Id, parm: parm) { status in
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
            vm.acknowledgeExercise(vc: self, id: model.data[0].exerciseIds[tag].id, parm: parm) { status in
                if status {
                    if let vc = self.switchController(.chatVC, .messageTab) as? ChatScreenVC {
                        vc.recieverId = model.data[0].patientId.Id
                        vc.name = model.data[0].patientId.firstName + " " + model.data[0].patientId.lastName
                        vc.profileImgLink = model.data[0].patientId.profilePhoto
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
            self.notificationNotFoundImgView.isHidden = false
        } else {
            self.tableView.isHidden = false
            self.notificationNotFoundImgView.isHidden = true
        }
        return vm.getCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationTVC", for: indexPath) as! NotificationTVC
        if let model = self.vm.notificationModel {
            let data = model.data[0].exerciseIds[indexPath.row]
            if let url = URL(string: data.patient_video_url) {
                self.getThumbnailImageFromVideoUrl(url: url) { image in
                    cell.imgView.image = image
                }
            }
            
            cell.daysLbl.text = "Today"
            cell.msgLbl.text = "\(model.data[0].patientId.firstName + " " + model.data[0].patientId.lastName) Sent Video"
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
                self.nameLbl.text = model.data[0].patientId.firstName + " " + model.data[0].patientId.lastName
                self.timeLbl.text = "Today"
                self.exerciseNameLbl.text = model.data[0].exerciseIds[tag].video_title
                self.setupVideoPlayer(url: model.data[0].exerciseIds[tag].patient_video_url)
                self.imgView.setImage(with: model.data[0].patientId.profilePhoto)
                self.openNotifcationView()
            }
        }
    }
}
