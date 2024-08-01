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

class TherapistHomeVC: UIViewController, UIGestureRecognizerDelegate {
    
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
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var cancelView: UIView!
    @IBOutlet weak var notificationImgView: UIImageView!
    
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
    var timer: Timer?
    private var refreshControl: UIRefreshControl!
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        closeNotifcationView()
        setUI()
        setTableViews()
        setNotificationView()
        setupRefreshControl()
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
           return true
       }
    
    override func viewDidAppear(_ animated: Bool) {
        self.isLoading = true
        callApi()
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
        patientVM.getPatient(vc: self) { _ in
            DispatchQueue.main.async {
                self.patientListTableView.reloadData()
            }
        }
        if let imageData = UserDefaults.standard.data(forKey: "profileImage"),
           let savedImage = UIImage(data: imageData) {
            Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { _ in
                self.animateProfileImageToTabBar(image: savedImage, imgView: self.imgView, userName: UserDefaults.standard.getTherapistName())
            }
        } else {
            print("Failed to retrieve UIImage from UserDefaults")
        }
        
    }
    
    func setTableViews() {
        messageTableView.delegate = self
        messageTableView.dataSource = self
        messageTableView.register(UINib(nibName: "MessageTVC", bundle: nil), forCellReuseIdentifier: "MessageCell")
        patientListTableView.delegate = self
        patientListTableView.dataSource = self
    }
    
    func setupRefreshControl() {
            refreshControl = UIRefreshControl()
            refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
            scrollView.refreshControl = refreshControl
        }
        
        @objc func refreshData(_ sender: UIRefreshControl) {
            callApi()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                sender.endRefreshing()
            }
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
        replyView.addBottomCornerRadius(radius: 16)
        cancelView.cornerRadius = 16

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
        timer?.invalidate()
        self.isLoading = false

        // Use a weak reference to self inside the timer block to avoid retain cycles
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            if UserDefaults.standard.getUsernameToken() != "" {
                TherapistHomeVC.socketHandler.fetchAllPatient(id: UserDefaults.standard.getTherapistId())
                self.messageTableView.reloadData()
                var unreadCount = 0
                for message in self.messageVM.model {
                    unreadCount += message.unreadCount
                }
                self.messageCountLbl.text = "\(unreadCount)"
                self.patientCountLbl.text = "\(self.patientVM.getCount())"
            }
        }
    }

    // Ensure timer is invalidated when the view controller is deinitialized
    deinit {
        timer?.invalidate()
        TherapistHomeVC.socketHandler.disconnect()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        timer?.invalidate()
        timer = nil
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
            let parm: [String: Any] = ["is_awaiting_reviews": false, "status": "reviewed", "exercise_ids": [model.data[0].exerciseIds[tag].id]]
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
            let parm: [String: Any] = ["is_awaiting_reviews": false, "status": "reviewed", "exercise_ids": [model.data[0].exerciseIds[tag].id]]
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
    
    @IBAction func openPatientTabBtnActn(_ sender: UIButton) {
        if let tabBarController = self.tabBarController as? RAMAnimatedTabBarController {
            DispatchQueue.main.async {
                tabBarController.setSelectIndex(from: tabBarController.selectedIndex, to: 2)
            }
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
            self.setupVideoPlayer(url: model.data[0].exerciseIds[tag].patient_video_url)
            self.nameLbl.text = model.data[tag].patientId.firstName + " " + model.data[tag].patientId.lastName
            self.timeLbl.text = model.data[tag].days
            self.exerciseNameLbl.text = model.data[tag].video_title
            notificationImgView.setImage(with: model.data[tag].patientId.profilePhoto)
            self.openNotifcationView()
        }
    }
    
    @objc func acknowledgeBtnActn(_ sender: UIButton) {
        let tag = sender.tag
        videoPlayer?.pause()
        selectedIndex = tag
        if let model = vm.notificationModel {
            let parm: [String: Any] = ["is_awaiting_reviews": false, "status": "reviewed", "exercise_ids": [model.data[0].exerciseIds[tag].id]]
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
        cell.setTemplateWithSubviews(isLoading, color: Colors.darkGray, animate: true, viewBackgroundColor: .lightGray)
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
        cell.setTemplateWithSubviews(isLoading, color: Colors.darkGray, animate: true, viewBackgroundColor: .lightGray)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == messageTableView {
            if let cell = tableView.cellForRow(at: indexPath) {
                cell.pressedAnimation {
                    let patient = self.messageVM.model[indexPath.row].patient!
                    self.openChat(patient.Id,name: patient.firstName + " " + patient.lastName, link: patient.profilePhoto)
                }
            }
        } else {
            if let cell = tableView.cellForRow(at: indexPath) {
                cell.pressedAnimation {
                    if let vc = self.switchController(.therapistPatientProfileVC, .therapistPatientProfile) as? TherapistPatientProfileVC {
                        vc.patientData = self.patientVM.filteredPatients[indexPath.row]
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }
            }
            
        }
    }
    
    func openChat(_ recieverId: String, name: String, link: String) {
        let id = UserDefaults.standard.getTherapistId()
        TherapistHomeVC.socketHandler.fetchPreviousMessage(recieverId, id)
        if let vc = self.switchController(.chatVC, .messageTab) as? ChatScreenVC {
            vc.recieverId = recieverId
            vc.name = name
            vc.profileImgLink = link
            if UserDefaults.standard.getUsernameToken() != "" {
                vc.isPatient = false
            } else {
                vc.isPatient = true
            }
            self.pushOrPresentViewController(vc, true)
        }
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
