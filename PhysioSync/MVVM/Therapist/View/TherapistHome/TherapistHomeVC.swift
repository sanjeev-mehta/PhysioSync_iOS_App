//
//  TherapistHomeVC.swift
//  PhysioSync
//
//  Created by Sanjeev Mehta on 14/06/24.
//

import UIKit
import CHIPageControl
import SocketIO
import RAMAnimatedTabBarController

class TherapistHomeVC: UIViewController {
    
    // MARK: -  IBOutlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var messageTableView: UITableView!
    @IBOutlet weak var patientListTableView: UITableView!
    @IBOutlet var shadowViews: [UIView]!
    @IBOutlet weak var pageControl: CHIPageControlChimayo!
    @IBOutlet weak var notificationView: UIView!
    @IBOutlet weak var acknowledgeView: UIView!
    @IBOutlet weak var replyView: UIView!
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var exerciseNameLbl: UILabel!
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var therapistNameLbl: UILabel!
    @IBOutlet weak var messageCountLbl: UILabel!
    @IBOutlet weak var patientCountLbl: UILabel!
    @IBOutlet weak var notify: UIImageView!
    @IBOutlet var topSectionConstraint: [NSLayoutConstraint]!
    
    // MARK: -  Variables
    var cellCount = 6
    var currentIndex = 0
    private let vm = TherapistHomeViewModel.shareInstance
    private var videoPlayer: CustomVideoPlayer?
    private var selectedIndex = 0
    static var socketHandler: SocketIOHandler!
    private let patientVM = TherapistPatientViewModel.shareInstance
    private let messageVM = MessageViewModel.shareInstance
    private var isLoading = true {
        didSet {
            patientListTableView.isUserInteractionEnabled = !isLoading
            patientListTableView.reloadData()
            messageTableView.reloadData()
            messageTableView.isUserInteractionEnabled = !isLoading
            collectionView.isUserInteractionEnabled = !isLoading
            collectionView.reloadData()
        }
    }
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        closeNotifcationView()
        setUI()
        setTableViews()
        callApi()
        setNotificationView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.isLoading = true
        self.collectionView.reloadData()
        self.updateCollection()
        socketConnecting()
        let myString = "Welcome \(UserDefaults.standard.getTherapistName()),"
        let attributedString = NSMutableAttributedString(string: myString)
        attributedString.setColor(forText: ["Welcome": Colors.borderClr, "\(UserDefaults.standard.getTherapistName()),": Colors.primaryClr])
        self.therapistNameLbl.attributedText = attributedString
        patientVM.getPatient(vc: self) { _ in
            DispatchQueue.main.async {
                self.patientListTableView.reloadData()
            }
        }
    }
    
    func setUI() {
        for i in shadowViews {
            i.layer.cornerRadius = 12
            i.addShadow()
        }
        patientVM.getPatient(vc: self) { _ in
            DispatchQueue.main.async {
                self.patientListTableView.reloadData()
            }
            
        }
    }
    
    func setTableViews() {
        messageTableView.delegate = self
        messageTableView.dataSource = self
        messageTableView.register(UINib(nibName: "MessageTVC", bundle: nil), forCellReuseIdentifier: "MessageCell")
        patientListTableView.delegate = self
        patientListTableView.dataSource = self
    }
    
    func callApi() {
        vm.getNotificationApi(vc: self) { status in
            self.closeNotifcationView()
            self.updateCollection()
            if self.vm.notificationModel?.data.count != 0 {
                self.notify.isHidden = false
                self.topSectionConstraint[0].constant = 200
                self.topSectionConstraint[1].constant = 24
                self.topSectionConstraint[2].constant = 20
            } else {
                self.notify.isHidden = true
                for i in self.topSectionConstraint {
                    i.constant = 0
                }
            }
        }
    }
    
    func updateCollection() {
        self.collectionView.reloadData()
        self.pageControl.numberOfPages = self.vm.notificationModel?.data.count ?? 0
        self.pageControl.set(progress: 0, animated: false)
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
    
    func socketConnecting() {
        TherapistHomeVC.socketHandler = SocketIOHandler(url: API.SocketURL)
        TherapistHomeVC.socketHandler.connect()
        TherapistHomeVC.socketHandler.delegate = self
        Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { _ in
            if UserDefaults.standard.getUsernameToken() != "" {
                TherapistHomeVC.socketHandler.fetchAllPatient(id: UserDefaults.standard.getTherapistId())
                self.messageTableView.reloadData()
                self.isLoading = false
                var unreadCount = 0
                for i in self.messageVM.model {
                    unreadCount += i.unreadCount
                }
                self.messageCountLbl.text = "\(unreadCount)"
                self.patientCountLbl.text = "\(self.patientVM.getCount())"
            }
        }
    }
    
    // MARK: - Buttons Actions
    @IBAction func cancelBtnActn(_ sender: UIButton) {
        sender.pressedAnimation {
            self.closeNotifcationView()
            self.videoPlayer?.pause()
        }
    }
    
    @IBAction func notificationBtnActn(_ sender: UIButton) {
        if let vc = self.switchController(.TherapistNotificationVC, .TherapistNotification) as? TherapistNotificationVC {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func acknowBtnActn(_ sender: UIButton) {
        let tag = sender.tag
        if let model = vm.notificationModel {
            let parm: [String: Any] = ["is_awaiting_reviews": true]
            vm.acknowledgeExercise(vc: self, id: model.data[tag].Id, parm: parm) { status in
                if status {
                    self.callApi()
                }
            }
        }
    }
    
    @IBAction func replyBtnActn(_ sender: UIButton) {
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
                    self.callApi()
                }
            }
        }
    }
    
    @IBAction func messageViewAllBtnActn(_ sender: UIButton) {
        if let tabBarController = self.tabBarController as? RAMAnimatedTabBarController {
            DispatchQueue.main.async {
                tabBarController.setSelectIndex(from: tabBarController.selectedIndex, to: 3)
            }
        }
    }
    
    @IBAction func addPatientBtnActn(_ sender: UIButton) {
        if let vc = self.switchController(.therapistPatientStep1VC, .therapistPatientProfile) as? TherapistPatientStep1VC {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

// MARK: -  UICollection View Delegates and datasource methods

extension TherapistHomeVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.isLoading {
            return cellCount
        } else {
            return vm.getCount()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TherapistHomeCVC", for: indexPath) as! TherapistHomeCVC
        if !self.isLoading {
            vm.setCollectionCell(cell, indexPath.item, vc: self)
            cell.playBtn.tag = indexPath.item
            cell.acknowledgeBtn.tag = indexPath.item
            
            cell.playBtn.addTarget(self, action: #selector(playBtnActn(_:)), for: .touchUpInside)
            cell.acknowledgeBtn.addTarget(self, action: #selector(acknowledgeBtnActn(_:)), for: .touchUpInside)
            
        }
        return cell
    }
    
    @objc func playBtnActn(_ sender: UIButton) {
        let tag = sender.tag
        selectedIndex = tag
        if let model = vm.notificationModel {
            self.setupVideoPlayer(url: model.data[tag].patientVideoUrl)
            self.nameLbl.text = model.data[tag].patientId.firstName + " " + model.data[tag].patientId.lastName
            self.timeLbl.text = model.data[tag].days
            self.exerciseNameLbl.text = model.data[tag].video_title
            self.openNotifcationView()
        }
    }
    
    @objc func acknowledgeBtnActn(_ sender: UIButton) {
        let tag = sender.tag
        videoPlayer?.pause()
        selectedIndex = tag
        if let model = vm.notificationModel {
            let parm: [String: Any] = ["is_awaiting_reviews": true]
            vm.acknowledgeExercise(vc: self, id: model.data[selectedIndex].Id, parm: parm) { status in
                if status {
                    self.callApi()
                }
            }
        }
    }

    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: collectionView.bounds.width, height: 200)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
        
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        cell.setTemplateWithSubviews(isLoading, animate: true, viewBackgroundColor: .systemBackground)
        cell.alpha = 0
        cell.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        
        // Apply animation
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: {
            cell.alpha = 1
            cell.transform = CGAffineTransform(scaleX: 1, y: 1)
        }, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // MARK: - Switch Controllers on tap
        
    }
    
}

// MARK: - UIScrollViewDelegate

extension TherapistHomeVC: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == collectionView {
            let pageIndex = round(scrollView.contentOffset.x / scrollView.frame.width)
            pageControl.set(progress: Int(pageIndex), animated: true)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == collectionView {
            currentIndex = Int(scrollView.contentOffset.x / scrollView.frame.size.width)
        }
    }
}

// MARK: -  Uitable View Delegates and data source methods

extension TherapistHomeVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == messageTableView {
            if self.isLoading {
                return cellCount
            } else {
                return messageVM.getUserCount()
            }
        } else {
            if self.isLoading {
                return cellCount
            } else {
                return patientVM.getCount()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == messageTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath) as! MessageTVC
            cell.selectionStyle = .none
            if !self.isLoading {
                let data = messageVM.model[indexPath.row]
                cell.profileImgView.setImage(with: data.patient?.profilePhoto)
                cell.nameLbl.text = data.patient!.firstName + "" + data.patient!.lastName
                cell.msgLbl.text = data.message
                if data.unreadCount != 0 {
                    cell.badgeLbl.isHidden = false
                    cell.badgeLbl.text = "\(data.unreadCount)"
                } else {
                    cell.badgeLbl.isHidden = true
                }
            } else {
                cell.badgeLbl.isHidden = true
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TherapistHomeTVC", for: indexPath) as! TherapistHomeTVC
            cell.selectionStyle = .none
            if !self.isLoading {
                let data = patientVM.filteredPatients[indexPath.row]
                cell.imgVW.setImage(with: data.profilePhoto)
                cell.nameLbl.text = data.firstName + " " + data.lastName
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.setTemplateWithSubviews(isLoading, animate: true, viewBackgroundColor: .systemBackground)
    }
}

extension TherapistHomeVC : SocketIOHandlerDelegate {
    func didReceiveMessage() {
        
    }
    
    func updatePatientList() {
        self.messageTableView.reloadData()
    }
    
    func fetchMessage(unreadCount: Int) {
        
    }
    
    
}
