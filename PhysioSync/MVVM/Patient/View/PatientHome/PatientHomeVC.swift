//
//  PatientHomeVC.swift
//  PhysioSync
//
//  Created by Sanjeev Mehta on 14/06/24.
//

import UIKit
import CHIPageControl

class PatientHomeVC: UIViewController, UNUserNotificationCenterDelegate, UIGestureRecognizerDelegate {
    
    // MARK: -  IBOutlets
    @IBOutlet weak var sessionCollectionView: UICollectionView!
    @IBOutlet weak var completedCollectionView: UICollectionView!
    @IBOutlet var messageViewConstraints: [NSLayoutConstraint]!
    @IBOutlet weak var sessionPageControl: CHIPageControlJaloro!
    @IBOutlet weak var completedPageControl: CHIPageControlJaloro!
    @IBOutlet weak var messageView: UIView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var profileImgVW: UIImageView!
    @IBOutlet weak var messageCountLbl: UILabel!
    @IBOutlet weak var therapistNameLbl: UILabel!
    @IBOutlet weak var todaysSessionLbl: UILabel!
    @IBOutlet weak var notTaskImgView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    // MARK: -  Variable
    var cellCount = 4
    var sessionCurrentIndex = 0
    var completedCurrentIndex = 0
    static var socketHandler: SocketIOHandler?
    let vm = PatientHomeViewModel.shareInstance
    let chatVM = ChatViewModel.shareInstance
    private var isLoading = true {
        didSet {
            sessionCollectionView.isUserInteractionEnabled = !isLoading
            sessionCollectionView.reloadData()
            completedCollectionView.reloadData()
            completedCollectionView.isUserInteractionEnabled = !isLoading
        }
    }
    var timer: Timer?
    private var refreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUI()
        chatVM.currentUser = UserDefaults.standard.getPatientLoginId()
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        setupRefreshControl()
        callApi()
        hideMessageView()
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let myString = "Welcome \(UserDefaults.standard.getPatientName()),"
        let attributedString = NSMutableAttributedString(string: myString)
        attributedString.setColor(forText: ["Welcome": Colors.borderClr, "\(UserDefaults.standard.getPatientName()),": Colors.primaryClr])
        self.nameLbl.attributedText = attributedString
    }
    
    override func viewDidAppear(_ animated: Bool) {
        socketConnecting()
        timer?.invalidate()
        timer = nil
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            PatientHomeVC.socketHandler?.fetchPreviousMessage(UserDefaults.standard.getPatientLoginId(), UserDefaults.standard.getTherapistId())
        }
        
        if !vm.isWatchDataSubmitted {
            vm.submitWatchData()
        }
        
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                // Authorization granted, can now schedule notifications
                self.scheduleNotification()
            } else {
                // Handle authorization denial
                if let error = error {
                    print("Authorization error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        timer?.invalidate()
        timer = nil
    }
    
    func setupRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
        scrollView.refreshControl = refreshControl
        scrollView.delegate = self
    }
    
    @objc func refreshData(_ sender: UIRefreshControl) {
        callApi()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            sender.endRefreshing()
        }
    }
        
    func scheduleNotification() {
        if let timeString = UserDefaults.standard.value(forKey: "reminder_time") as? String {
            guard let dateComponents = parseTimeString(timeString) else {
                print("Invalid time format")
                return
            }
            
            let content = UNMutableNotificationContent()
            content.title = "Daily Reminder"
            content.body = "It's exercise time! Remember, consistency is key to your recovery."
            content.sound = .default
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            
            let request = UNNotificationRequest(identifier: "dailyTaskReminder", content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Error scheduling notification: \(error.localizedDescription)")
                } else {
                    print("Daily notification scheduled successfully for \(timeString)")
                }
            }
        }
    }
    
    // Handle notification when the app is in the foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("Notification received with identifier: \(notification.request.identifier)")
        completionHandler([.banner, .sound])
    }
    
    // Handle notification response
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("Notification clicked with identifier: \(response.notification.request.identifier)")
        completionHandler()
    }
    
    func parseTimeString(_ timeString: String) -> DateComponents? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        
        guard let date = dateFormatter.date(from: timeString) else {
            return nil
        }
        
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.hour, .minute], from: date)
        return dateComponents
    }
    
    func setUI() {
        if let imageData = UserDefaults.standard.data(forKey: "profileImage"),
           let savedImage = UIImage(data: imageData) {
            Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { _ in
                self.animateProfileImageToTabBar(image: savedImage, userName: UserDefaults.standard.getPatientName())
            }
        } else {
            print("Failed to retrieve UIImage from UserDefaults")
        }
        sessionCollectionView.delegate = self
        sessionCollectionView.dataSource = self
        completedCollectionView.delegate = self
        completedCollectionView.dataSource = self
        messageView.addShadow()
        
    }
    
    func callApi() {
        vm.getAssignExercise(self) { status in
            if status {
                DispatchQueue.main.async {
                    self.sessionPageControl.numberOfPages = self.vm.assignExerciseCount(.assigned)
                    self.sessionPageControl.set(progress: 0, animated: false)
                    self.completedPageControl.numberOfPages = self.vm.assignExerciseCount(.completed)
                    self.completedPageControl.set(progress: 0, animated: false)
                    Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
                        self.isLoading = false
                        self.todaysSessionLbl.text = "Today's Session (\(self.vm.assignExerciseCount(.completed))/\(self.vm.assignExerciseCount(.assigned) + (self.vm.assignExerciseCount(.completed))))"
                    }
                }
            }
        }
    }
    
    func hideMessageView() {
        for i in messageViewConstraints {
            i.constant = 0
        }
        messageViewConstraints[2].constant = 24
        self.messageView.isHidden = true
    }
    
    func socketConnecting() {
        guard let socketURL = URL(string: API.SocketURL) else {
            print("Invalid socket URL: \(API.SocketURL)")
            return
        }
        
        PatientHomeVC.socketHandler = SocketIOHandler(url: socketURL)
        
        if let socketHandler = PatientHomeVC.socketHandler {
            socketHandler.connect()
            socketHandler.delegate = self
        } else {
            print("Failed to initialize SocketIOHandler")
        }
    }
    
    @IBAction func messageBtnActn(_ sender: UIButton) {
        self.tabBarController?.selectedIndex = 3
    }
    
}

// MARK: -  UICollection View Delegates and datasource methods

extension PatientHomeVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isLoading {
            notTaskImgView.isHidden = true
            return 1
        } else {
            if collectionView == sessionCollectionView {
                return vm.assignExerciseCount(.assigned)
            } else {
                if vm.assignExerciseCount(.completed) == 0 {
                    notTaskImgView.isHidden = false
                } else {
                    notTaskImgView.isHidden = true
                }
                return vm.assignExerciseCount(.completed)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == sessionCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PatientHomeCVC1", for: indexPath) as! PatientHomeCVC
            cell.imgView.addTopCornerRadius(radius: 16)
            cell.bottomView.addBottomCornerRadius(radius: 16)
            cell.bgView.layer.cornerRadius = 16
            cell.bgView.addShadow()
            if !isLoading {
                vm.setUpCell(cell, .assigned, indexPath.item)
            }
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PatientHomeCVC2", for: indexPath) as! PatientHomeCVC
            cell.imgView.addTopCornerRadius(radius: 16)
            cell.bottomView.addBottomCornerRadius(radius: 16)
            cell.bgView.layer.cornerRadius = 16
            cell.bgView.addShadow()
            if !isLoading {
                vm.setUpCell(cell, .completed, indexPath.item)
            } else {
                
            }
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: collectionView.bounds.width, height: 260)
        
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
        if collectionView == sessionCollectionView {
            if let cell = collectionView.cellForItem(at: indexPath) {
                cell.pressedAnimation {
                    if let vc = self.switchController(.patientExerciseDetail, .patientExercisTab) as? PatientExerciseDetailVC {
                        vc.data = self.vm.exerciseAssign[indexPath.row]
                        vc.isHeroEnabled = true
                        vc.heroModalAnimationType = .zoom
                        vc.view.heroID = "cell_\(indexPath.section)_\(indexPath.row)"
                        self.pushOrPresentViewController(vc, true)
                    }
                }
            }
        }
    }
    
}

// MARK: - UIScrollViewDelegate

extension PatientHomeVC: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == sessionCollectionView {
            let pageIndex = round(scrollView.contentOffset.x / scrollView.frame.width)
            sessionPageControl.set(progress: Int(pageIndex), animated: true)
        }
        
        if scrollView == completedCollectionView {
            let pageIndex = round(scrollView.contentOffset.x / scrollView.frame.width)
            completedPageControl.set(progress: Int(pageIndex), animated: true)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == sessionCollectionView {
            sessionCurrentIndex = Int(scrollView.contentOffset.x / scrollView.frame.size.width)
        }
        
        if scrollView == completedCollectionView {
            completedCurrentIndex = Int(scrollView.contentOffset.x / scrollView.frame.size.width)
        }
    }
}

extension PatientHomeVC: SocketIOHandlerDelegate {
    func didReceiveMessage() {
        
    }
    
    func updatePatientList() {
        
    }
    
    func fetchMessage(unreadCount: Int) {
        if unreadCount == 0 {
            for i in messageViewConstraints {
                i.constant = 0
            }
            messageViewConstraints[2].constant = 24
            self.messageView.isHidden = true
        } else {
            self.messageView.isHidden = false
            messageViewConstraints[0].constant = 16
            messageViewConstraints[1].constant = 90
            messageViewConstraints[2].constant = 24
            self.messageView.isHidden = false
            self.therapistNameLbl.text = UserDefaults.standard.getTherapistName()
            self.profileImgVW.setImage(with: UserDefaults.standard.getTherapistProfileImage())
            self.messageCountLbl.text = "\(unreadCount) new messages"
            
        }
    }
    
    
}
