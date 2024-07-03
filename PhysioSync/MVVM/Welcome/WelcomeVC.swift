//
//  WelcomeVC.swift
//  PhysioSync
//
//  Created by Sanjeev Mehta on 30/05/24.
//

import UIKit

class WelcomeVC: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var roleLbl: UILabel!
    @IBOutlet var roleViews: [UIView]!
    @IBOutlet var roleLbls: [UILabel]!
    @IBOutlet var checkMark: [UIImageView]!
    @IBOutlet weak var nextBtn: UIButton!
    
    // MARK: - Variables
    var selectedTag = -1
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setUI()
    }
    
    // MARK: - Set UI
    func setUI() {
        bottomView.addTopCornerRadius(radius: 24)
        let myString = "Choose your role"
        let attributedString = NSMutableAttributedString(string: myString)
        attributedString.setColor(forText: ["Choose your": Colors.borderClr, "role": Colors.primaryClr])
        roleLbl.attributedText = attributedString
        selection()
    }
    
    // MARK: - Selection Method
    func selection() {
        for i in 0..<roleViews.count {
            if i == selectedTag {
                roleViews[i].backgroundColor = Colors.primaryClr
                roleLbls[i].textColor = .white
                checkMark[i].isHidden = false
            } else {
                roleViews[i].backgroundColor = Colors.primarySubtleClr
                roleLbls[i].textColor = Colors.primaryClr
                checkMark[i].isHidden = true
            }
        }
        nextBtnState()
    }
    
    func nextBtnState() {
        if selectedTag != -1 {
            nextBtn.backgroundColor = Colors.primaryClr
            nextBtn.setTitleColor(.white, for: .normal)
        } else {
            nextBtn.backgroundColor = Colors.disableBtnBg
            nextBtn.setTitleColor(Colors.disableBtnClr, for: .disabled)
        }
    }
    
    // MARK: - Buttons Action
    
    @IBAction func physiotherapistBtnActn(_ sender: UIButton) {
        roleViews[0].pressedAnimation {
            if self.selectedTag == 0 {
                self.selectedTag = -1
                self.nextBtn.isEnabled = false
                self.selection()
            } else {
                self.selectedTag = 0
                self.nextBtn.isEnabled = true
                self.selection()
            }
        }
    }
    
    @IBAction func patientBtnActn(_ sender: UIButton) {
        roleViews[1].pressedAnimation {
            if self.selectedTag == 1 {
                self.selectedTag = -1
                self.nextBtn.isEnabled = false
                self.selection()
            } else {
                self.selectedTag = 1
                self.nextBtn.isEnabled = true
                self.selection()
            }
        }
        
    }
    
    @IBAction func nextBtnActn(_ sender: UIButton) {
        if selectedTag == 0 {
//            if let vc = self.switchController(.therapistOnboardingID, .therapistOnboarding) {
//                self.pushOrPresentViewController(vc, true)
//            }
            if let vc = self.switchController(.therapistWelcomeID, .therapistOnboarding) {
                self.pushOrPresentViewController(vc, true)
            }
        } else if selectedTag == 1 {
//            if let vc = self.switchController(.patientLogin, .patientAuth) {
//                self.pushOrPresentViewController(vc, true)
//            }
            if let vc = self.switchController(.therapistOnboardingID, .therapistOnboarding) as? TherapistOnboardingVC {
                vc.isFromPatient = true
                self.pushOrPresentViewController(vc, true)
            }
        }
    }
}

enum Role {
    case therapist
    case patient
}
