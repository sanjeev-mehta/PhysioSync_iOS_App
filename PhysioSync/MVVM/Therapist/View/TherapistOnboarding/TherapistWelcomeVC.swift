//
//  TherapistWelcomeVC.swift
//  PhysioSync
//
//  Created by Sanjeev Mehta on 30/05/24.
//

import UIKit

class TherapistWelcomeVC: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var loginLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
    }
    
    // MARK: - Set UI
    func setUI() {
        bottomView.addTopCornerRadius(radius: 24)
        let titleString = "Welcome to PhysioSync,"
        let attributedString = NSMutableAttributedString(string: titleString)
        attributedString.setColor(forText: ["Welcome to ": Colors.borderClr, "PhysioSync,": Colors.primaryClr])
        titleLbl.attributedText = attributedString
        
        let loginString = "Already have an account? Log in"
        let attributedStr = NSMutableAttributedString(string: loginString)
        attributedStr.setColor(forText: ["Already have an account?": Colors.borderClr, "Log in": Colors.primaryClr])
        loginLbl.attributedText = attributedStr
    }

    // MARK: - Buttons Action
    @IBAction func backBtnActn(_ sender: UIButton) {
            self.dismissOrPopViewController()
    }
    
    @IBAction func loginBtnActn(_ sender: UIButton) {
        sender.pressedAnimation {
            if let vc = self.switchController(.therapistOnboardingID, .therapistOnboarding) {
                self.pushOrPresentViewController(vc, true)
            }
        }
    }
    
    @IBAction func signUpBtnActn(_ sender: UIButton) {
        sender.pressedAnimation {
            let storyBoard = UIStoryboard(name: "TherapistAuth", bundle: nil)
            if let vc = storyBoard.instantiateViewController(withIdentifier: "TherapistSignUpVC") as? TherapistSignUpVC {
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
}
