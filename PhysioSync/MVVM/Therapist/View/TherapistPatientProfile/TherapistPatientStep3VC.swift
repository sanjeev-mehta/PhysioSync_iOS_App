//
//  TherapistPatientStep3VC.swift
//  PhysioSync
//
//  Created by Gurmeet Singh on 2024-06-13.
//

import UIKit
import RAMAnimatedTabBarController

class TherapistPatientStep3VC: UIViewController {

    //MARK: - IBOutlets
    @IBOutlet weak var historyTV: UITextView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    //MARK: - Variables
    let awsHelper = AWSHelper.shared
    var parms = [String: Any]()
    var profileImage: UIImage?
    let vm = TherapistPatientProfileStep3ViewModel.shareInstance
    var model: Patient?
    var isEdit = false
    var isImageChange = false
    var isPatientSide = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.debugPrint("\(parms)")
        scrollView.delegate = self
        scrollView.contentOffset.y = -50
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setHeader("Therapist Profile", isRightBtn: false) {
            self.dismissOrPopViewController()
        } rightButtonAction: {
            // No Need
        }
        setData()
    }
    
    // MARK: -  Set Edit Data
    func setData() {
        if isEdit {
            if let model = model {
                historyTV.text = model.injuryDetails
            }
        }
    }
    
    //MARK: - Add Patient
    func addPatient() {
        if isEdit {
            if isImageChange {
                vm.uploadImage(profileImage: profileImage) {  link in
                    DispatchQueue.main.async {
                        if self.historyTV.text != "" {
                            self.parms["injury_details"] = self.historyTV.text!
                        }
                        self.parms["profile_photo"] = link
                        self.vm.updatePatient(vc: self, parm: self.parms, id: self.model!.Id) { status in
                            if status {
                                self.popController()
                            }
                        }
                    }
                }
            } else {
                if self.historyTV.text != "" {
                    self.parms["injury_details"] = self.historyTV.text!
                }
                self.parms["profile_photo"] = model!.profilePhoto
                self.vm.updatePatient(vc: self, parm: self.parms, id: self.model!.Id) { status in
                    if status {
                        self.popController()
                    }
                }
            }
        } else {
            vm.uploadImage(profileImage: profileImage) {  link in
                DispatchQueue.main.async {
                    if self.historyTV.text != "" {
                        self.parms["injury_details"] = self.historyTV.text!
                    }
                    self.parms["profile_photo"] = link
                    self.vm.addNewPatient(vc: self, parm: self.parms) { status in
                        if status {
                            self.popController()
                        }
                    }
                }
            }
        }
    }
    
    func popController() {
        if isPatientSide {
            if let viewControllers = navigationController?.viewControllers, viewControllers.count > 2 {
                let targetViewController = viewControllers[2]
                navigationController?.popToViewController(targetViewController, animated: true)
            } else {
                print("Not enough view controllers in the navigation stack.")
            }
        } else {
            if let viewControllers = navigationController?.viewControllers, viewControllers.count > 4 {
                let targetViewController = viewControllers[4]
                navigationController?.popToViewController(targetViewController, animated: true)
            } else {
                print("Not enough view controllers in the navigation stack.")
            }
        }
       
    }
    
    // MARK: -  Buttons Actions
    @IBAction func saveBtnActn(_ sender: UIButton) {      
        sender.pressedAnimation {
            self.addPatient()
        }
    }

}

extension TherapistPatientStep3VC: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.debugPrint("\(scrollView.contentOffset.y)")
        if scrollView == self.scrollView {
            scrollView.contentOffset.y = -50
        }
    }
}
