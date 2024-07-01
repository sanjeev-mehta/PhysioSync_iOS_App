//
//  PatientHomeVC.swift
//  PhysioSync
//
//  Created by Sanjeev Mehta on 14/06/24.
//

import UIKit
import CHIPageControl

class PatientHomeVC: UIViewController {

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
    
    // MARK: -  Variable
    var cellCount = 4
    var sessionCurrentIndex = 0
    var completedCurrentIndex = 0
    static var socketHandler: SocketIOHandler!
    let vm = PatientHomeViewModel.shareInstance
    let chatVM = ChatViewModel.shareInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUI()
        if UserDefaults.standard.getUsernameToken() != "" {
            chatVM.currentUser = UserDefaults.standard.getTherapistId()
        } else {
            chatVM.currentUser = UserDefaults.standard.getPatientLoginId()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        socketConnecting()
        nameLbl.text = "Welcome \(UserDefaults.standard.getPatientName()),"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.callApi()
        PatientHomeVC.socketHandler.fetchPreviousMessage(UserDefaults.standard.getPatientLoginId(), UserDefaults.standard.getTherapistId())
    }
    
    func setUI() {
        sessionCollectionView.delegate = self
        sessionCollectionView.dataSource = self
        completedCollectionView.delegate = self
        completedCollectionView.dataSource = self
        messageView.addShadow()
    }
    
    func callApi() {
        vm.getAssignExercise(self) { status in
            if status {
                self.sessionCollectionView.reloadData()
                self.completedCollectionView.reloadData()
                self.sessionPageControl.numberOfPages = self.vm.assignExerciseCount(.assigned)
                self.sessionPageControl.set(progress: 0, animated: false)
                self.completedPageControl.numberOfPages = self.vm.assignExerciseCount(.completed)
                self.completedPageControl.set(progress: 0, animated: false)
            }
        }
    }
    
    func hideMessageView() {
        for i in messageViewConstraints {
            i.constant = 0
        }
        self.messageView.isHidden = true
    }
    
    func socketConnecting() {
        PatientHomeVC.socketHandler = SocketIOHandler(url: API.SocketURL)
        PatientHomeVC.socketHandler.connect()
        PatientHomeVC.socketHandler.delegate = self
        Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { _ in
            PatientHomeVC.socketHandler.fetchPreviousMessage(UserDefaults.standard.getPatientLoginId(), UserDefaults.standard.getTherapistId())
        }
    }
    
    @IBAction func messageBtnActn(_ sender: UIButton) {
        self.tabBarController?.selectedIndex = 3
    }

}

// MARK: -  UICollection View Delegates and datasource methods

extension PatientHomeVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == sessionCollectionView {
            return vm.assignExerciseCount(.assigned)
        } else {
            return vm.assignExerciseCount(.completed)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == sessionCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PatientHomeCVC1", for: indexPath) as! PatientHomeCVC
            cell.imgView.addTopCornerRadius(radius: 16)
            cell.bottomView.addBottomCornerRadius(radius: 16)
            cell.bgView.layer.cornerRadius = 16
            cell.bgView.addShadow()
            vm.setUpCell(cell, .assigned, indexPath.item)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PatientHomeCVC2", for: indexPath) as! PatientHomeCVC
            cell.imgView.addTopCornerRadius(radius: 16)
            cell.bottomView.addBottomCornerRadius(radius: 16)
            cell.bgView.layer.cornerRadius = 16
            cell.bgView.addShadow()
            vm.setUpCell(cell, .completed, indexPath.item)
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
        //        cell.setTemplateWithSubviews(isLoading, animate: true, viewBackgroundColor: .systemBackground)
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
                        self.pushOrPresentViewController(vc, false)
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
