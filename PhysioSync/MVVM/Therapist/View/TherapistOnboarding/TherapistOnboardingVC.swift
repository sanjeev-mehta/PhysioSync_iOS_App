//
//  TherapistOnboardingVC.swift
//  PhysioSync
//
//  Created by Sanjeev Mehta on 30/05/24.
//

import UIKit
import CHIPageControl

class TherapistOnboardingVC: UIViewController, CHIBasePageControlDelegate {

    // MARK: - Outlets
    @IBOutlet weak var pageControl: CHIPageControlFresno!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var descLbl: UILabel!
    @IBOutlet weak var nextBtn: UIButton!
    
    // MARK: - Variables
    var therapistData = [TherapistOnboardingModel]()
    var tag = 0
    var isFromPatient = false
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
       
        setUI()
    }
    
    // MARK: - Set UI
    func setUI() {
        bottomView.addTopCornerRadius(radius: 24)
        setData()
        updateLbls(0)
        pageControl.delegate = self
        pageControl.numberOfPages = therapistData.count
        pageControl.radius = 5
    }
    
    // MARK: - Set Data
    func setData() {
        if isFromPatient {
            therapistData.append(TherapistOnboardingModel(title: "Daily Exercises", description: "Receive personalized daily exercises with video instructions to help you recover from your Physiotherapist."))
            therapistData.append(TherapistOnboardingModel(title: "Exercise Accuracy", description: "Ensure each rep is counted and performed correctly in real-time with the advanced AI model."))
            therapistData.append(TherapistOnboardingModel(title: "Messaging", description: "Stay connected with your physiotherapist with instant messaging for personalized guidance."))
        } else {
            therapistData.append(TherapistOnboardingModel(title: "Patient Profile Management", description: "Easily access and update patient profiles, monitor treatment progress, and review exercise history."))
            therapistData.append(TherapistOnboardingModel(title: "Exercise Library", description: "Upload and manage exercise videos, and easily assign personalized routines to patients."))
            therapistData.append(TherapistOnboardingModel(title: "Messaging", description: "Communicate with your patients through instant messaging for personalized guidance."))
        }
    }
    
    // MARK: - Update Lbls
    func updateLbls(_ index: Int) {
        self.titleLbl.text = therapistData[index].title
        self.descLbl.text = therapistData[index].description
        self.pageControl.set(progress: index, animated: true)
        self.descLbl.layoutIfNeeded()
        if index == therapistData.count - 1 {
            nextBtn.setTitle("Get Started", for: .normal)
        } else {
            nextBtn.setTitle("Next", for: .normal)
        }
    }
    
    // MARK: - Animate Lbls
    func nextAnimateLbls() {
        UIView.animate(withDuration: 0.2) {
            self.titleLbl.transform = CGAffineTransform(translationX: -1000, y: 0)
            self.descLbl.transform = CGAffineTransform(translationX: -1000, y: 0)
        } completion: { _ in
            self.titleLbl.transform = CGAffineTransform(translationX: 1000, y: 0)
            self.descLbl.transform = CGAffineTransform(translationX: 1000, y: 0)
            UIView.animate(withDuration: 0.3) {
                self.titleLbl.transform = CGAffineTransform(translationX: 0, y: 0)
                self.descLbl.transform = CGAffineTransform(translationX: 0, y: 0)
            }
        }
    }
    
    func backAnimateLbls() {
        UIView.animate(withDuration: 0.2) {
            self.titleLbl.transform = CGAffineTransform(translationX: 1000, y: 0)
            self.descLbl.transform = CGAffineTransform(translationX: 1000, y: 0)
        } completion: { _ in
            self.titleLbl.transform = CGAffineTransform(translationX: -1000, y: 0)
            self.descLbl.transform = CGAffineTransform(translationX: -1000, y: 0)
            UIView.animate(withDuration: 0.3) {
                self.titleLbl.transform = CGAffineTransform(translationX: 0, y: 0)
                self.descLbl.transform = CGAffineTransform(translationX: 0, y: 0)
            }
        }
    }
    
    // MARK: - Page Control Delegate Methods
    func didTouch(pager: CHIBasePageControl, index: Int) {
        print(index)
    }
    
    
    // MARK: - Buttons Action
    @IBAction func nextBtnActn(_ sender: UIButton) {
        if tag != 2 {
            nextAnimateLbls()
            tag += 1
            updateLbls(tag)
        } else {
            if isFromPatient {
                if let vc = self.switchController(.tabBarController, .patientTab) {
                    self.pushOrPresentViewController(vc, true)
                }
            } else {
                if let vc = self.switchController(.therapistWelcomeID, .therapistOnboarding) {
                    self.pushOrPresentViewController(vc, true)
                }
            }
        }
    }
    
    @IBAction func backBtnActn(_ sender: UIButton) {
        if tag != 0 {
            backAnimateLbls()
            tag -= 1
            updateLbls(tag)
        } else {
            self.dismissOrPopViewController()
        }
    }
    
    @IBAction func skipBtnActn(_ sender: UIButton) {
        nextAnimateLbls()
        tag = therapistData.count - 1
        updateLbls(tag)
    }


}
