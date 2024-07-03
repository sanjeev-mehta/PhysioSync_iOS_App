//
//  PatientLoginVC.swift
//  PhysioSync
//
//  Created by Sanjeev Mehta on 30/05/24.
//

import UIKit

class PatientLoginVC: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var passwordView: UIView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var emailTf: UITextField!
    @IBOutlet weak var passwordTf: UITextField!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet var labelHeight: [NSLayoutConstraint]!
    @IBOutlet weak var descLbl: UILabel!
    
    // MARK: -  Variables
    private var isVerifiedEmail = false
    private let vm = PatientLoginViewModel.shareInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUI()
    }
    
    // MARK: - Set UI
    func setUI() {
        passwordView.isHidden = true
        bottomView.addTopCornerRadius(radius: 24)
        let myString = "Registered Email"
        let attributedString = NSMutableAttributedString(string: myString)
        attributedString.setColor(forText: ["Registered": Colors.borderClr, "Email": Colors.primaryClr])
        titleLbl.attributedText = attributedString
    }
    
    // MARK: - Call Verify Email
    func callVerifyEmailApi() {
        vm.callVerifyEmail(vc: self, email: emailTf.text!) { status in
            switch status {
            case 1:
                self.isVerifiedEmail = true
                DispatchQueue.main.async {
                    UIView.animate(withDuration: 0.4) {
                        self.passwordView.isHidden = false
                        self.titleLbl.text = "Login"
                        for i in self.labelHeight {
                            i.constant = 0
                        }
                    }
                }
                break
            case 2:
                if let vc = self.switchController(.setPassword, .patientAuth) as? SetPasswordVC  {
                    vc.email = self.emailTf.text!
                    self.pushOrPresentViewController(vc, true)
                }
            default:
                self.debugPrint("Default")
            }
        }
    }
    
    // MARK: - Call Login Api
    func callLoginApi() {
        let parm = ["email": emailTf.text!, "password": passwordTf.text!]

        vm.callPatientLogin(vc: self, parm: parm) { result in
            if result {
                if let vc = self.switchController(.patientTabBarController, .patientTab) {
                    self.pushOrPresentViewController(vc, true)
                }
            }
        }
    }
    
    // MARK: - Buttons Action
    
    @IBAction func nextBtnActn(_ sender: UIButton) {
        sender.pressedAnimation {
            if !self.isVerifiedEmail {
                if self.emailTf.text == "" {
                    self.displayAlert(title: "Warning", msg: "Please enter email", ok: "Ok")
                } else if !self.isValidEmail(self.emailTf.text!) {
                    self.displayAlert(title: "Warning", msg: "Please enter valid email", ok: "Ok")
                } else {
                    self.callVerifyEmailApi()
                }
            } else {
                if self.emailTf.text == "" {
                    self.displayAlert(title: "Warning", msg: "Please enter email", ok: "Ok")
                } else if !self.isValidEmail(self.emailTf.text!) {
                    self.displayAlert(title: "Warning", msg: "Please enter valid email", ok: "Ok")
                } else if self.passwordTf.text == "" {
                    self.displayAlert(title: "Warning", msg: "Please enter password", ok: "Ok")
                } else {
                    self.callLoginApi()
                }
            }
        }
        
    }
    
    @IBAction func backBtnActn(_ sender: UIButton) {
        self.dismissOrPopViewController()
    }

}
