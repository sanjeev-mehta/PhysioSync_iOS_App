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
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var imgViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var imgViewTopConstraint: NSLayoutConstraint!
    
    // MARK: - Variables
    var therapistData = [TherapistOnboardingModel]()
    var tag = 0
    var isFromPatient = false
    var isTherapistLogin = true
    
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
            let title1 = createAttributedString("Advanced Machine \nLearning Model", withColors: ["Machine Learning": Colors.primaryClr])
            therapistData.append(TherapistOnboardingModel(title: title1, description: "Ensure each rep is counted and performed correctly in real-time with the advanced AI. ", img: "patientOnBoarding-1"))
            let title2 = createAttributedString("Daily \nExercise Routine", withColors: ["Videos": Colors.primaryClr])
            therapistData.append(TherapistOnboardingModel(title: title2, description: "Receive daily personalized exercises with tutorials from your physiotherapist", img: "patientOnBoarding-2"))
            let title3 = createAttributedString("Instant\nMessaging", withColors: ["Messaging": Colors.primaryClr])
            therapistData.append(TherapistOnboardingModel(title: title3, description: "Communicate with your therapist through instant messaging for personalized guidance.", img: "patientOnBoarding-3"))
        } else {
            let title1 = createAttributedString("Patient Profile Management", withColors: ["Profile": Colors.primaryClr])
            therapistData.append(TherapistOnboardingModel(title: title1, description: "Easily access and update patient profiles, monitor treatment progress, and review", img: "therapistOnboarding-1"))
            let title2 = createAttributedString("Exercise \nVideos Library", withColors: ["Videos": Colors.primaryClr])
            therapistData.append(TherapistOnboardingModel(title: title2, description: "Upload and manage exercise videos, and easily assign personalized routines to patients.", img: "therapistOnboarding-2"))
            let title3 = createAttributedString("Instant \nMessaging", withColors: ["Messaging": Colors.primaryClr])
            therapistData.append(TherapistOnboardingModel(title: title3, description: "Communicate with your patients through instant messaging for personalized guidance.", img: "therapistOnboarding-3"))
        }
    }
    
    func createAttributedString(_ string: String, withColors colors: [String: UIColor]) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: string)
        for (substring, color) in colors {
            let range = (string as NSString).range(of: substring)
            if range.location != NSNotFound {
                attributedString.addAttribute(.foregroundColor, value: color, range: range)
            }
        }
        return attributedString
    }
    
    // MARK: - Update Lbls
    func updateLbls(_ index: Int) {
        self.titleLbl.attributedText = therapistData[index].title
        self.descLbl.text = therapistData[index].description
        if !isFromPatient {
            if index == 0 {
                self.imgView.contentMode = .scaleAspectFill
                imgViewBottomConstraint.constant = 250
                imgViewTopConstraint.constant = 8
            } else if index == 1 {
                self.imgView.contentMode = .top
                imgViewBottomConstraint.constant = 250
                imgViewTopConstraint.constant = 8
            } else {
                self.imgView.contentMode = .center
                imgViewBottomConstraint.constant = 160
                imgViewTopConstraint.constant = -52
            }
        } else {
            if index == 0 {
                self.imgView.contentMode = .scaleAspectFill
                imgViewBottomConstraint.constant = 300
                imgViewTopConstraint.constant = -52
            } else if index == 1 {
                self.imgView.contentMode = .top
                imgViewBottomConstraint.constant = 250
                imgViewTopConstraint.constant = 8
            } else {
                self.imgView.contentMode = .center
                imgViewBottomConstraint.constant = 80
                imgViewTopConstraint.constant = -52
            }
        }
        UIView.animate(withDuration: 0.15, animations: {
                self.imgView.alpha = 0.0
                self.imgView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            }) { _ in
                self.imgView.image = UIImage(named: self.therapistData[index].img)
                
                UIView.animate(withDuration: 0.15, animations: {
                    self.imgView.alpha = 1.0
                    self.imgView.transform = .identity
                })
            }
        self.imgView.image = UIImage(named: therapistData[index].img)
        self.pageControl.set(progress: index, animated: true)
        self.descLbl.layoutIfNeeded()
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
                if let vc = self.switchController(.patientLogin, .patientAuth) {
                    self.pushOrPresentViewController(vc, true)
                }
            } else {
                if isTherapistLogin {
                    if let vc = self.switchController(.therapistLoginVC, .therapistAuth) {
                        self.pushOrPresentViewController(vc, true)
                    }
                } else {
                    if let vc = self.switchController(.tabBarController, .therapistTab) {
                        self.pushOrPresentViewController(vc, true)
                    }
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
        if tag != 2 {
            nextAnimateLbls()
            tag = therapistData.count - 1
            updateLbls(tag)
        }
    }


}
