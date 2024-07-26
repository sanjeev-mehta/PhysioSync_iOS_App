//
//  TherapistLoginVC.swift
//  PhysioSync
//
//  Created by Sanjeev Mehta on 22/05/24.
//

import UIKit

class TherapistLoginVC: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var emailTf: UITextField!
    @IBOutlet weak var passwordTf: UITextField!
    @IBOutlet weak var welcomeLbl: UILabel!
    @IBOutlet weak var signUpLbl: UILabel!
    @IBOutlet weak var passwordBtn: UIButton!
    @IBOutlet weak var bottomView: UIView!
    
    // MARK: - Variables
    let vm = TherapistLoginViewModel.shareInstance
    var isHide = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        emailTf.text = "sgurmeet392@gmail.com"//"gsingh391@mylangara.ca"
        passwordTf.text = "123456"
        setUI()
    }
    
    // MARK: - Set UI
    func setUI() {
        self.bottomView.addTopCornerRadius(radius: 16)
        let titleString = "Welcome Back,"
        let attributedString = NSMutableAttributedString(string: titleString)
        attributedString.setColor(forText: ["Welcome": Colors.borderClr, "Back,": Colors.primaryClr])
        welcomeLbl.attributedText = attributedString
        
        let loginString = "Don’t have an account? Sign up"
        let attributedStr = NSMutableAttributedString(string: loginString)
        attributedStr.setColor(forText: ["Don’t have an account?": Colors.borderClr, "Sign up": Colors.primaryClr])
        signUpLbl.attributedText = attributedStr
        passwordShowHide()
    }
    
    // MARK: - Password Show Hide
    func passwordShowHide() {
        self.passwordTf.isSecureTextEntry = isHide
        self.passwordBtn.setImage(isHide ? UIImage(named: "passwordHide")! : UIImage(named: "passwordShow")!, for: .normal)
    }
    
    // MARK: - Api Calling
    func callApi() {
        let parm : [String: Any] = ["email": emailTf.text!, "password": passwordTf.text!]
        vm.checkAuthentication(vc: self, with: parm, emailTf.text!, passwordTf.text!) { status in
            if status {
                if let vc = self.switchController(.tabBarController, .therapistTab) {
                    self.pushOrPresentViewController(vc, true)
                }
            }
        }
    }
    
    // MARK: -  Check Validation
    func validation() {
        if emailTf.text == "" {
            showAlert("Please enter email address")
        } else if !self.isValidEmail(emailTf.text!) {
            showAlert("Please enter valid email address")
        } else if passwordTf.text == "" {
            showAlert("Please enter password")
        } else {
            self.callApi()
        }
    }
    
    // MARK: - Show Alert
    func showAlert(_ message: String) {
        self.displayAlert(title: "Alert", msg: message, ok: "Ok")
    }
    // Buttons Actions
    @IBAction func loginBtnActn(_ sender: UIButton) {
        sender.pressedAnimation {
            self.validation()
        }
    }
    
    @IBAction func passwordShowHideBtnActn(_ sender: UIButton) {
        sender.pressedAnimation {
            self.isHide = self.isHide ? false : true
            self.passwordShowHide()
        }
        
    }
    
    @IBAction func backBtnActn(_ sender: UIButton) {
        self.dismissOrPopViewController()
    }
    
    @IBAction func signUpBtnActn(_ sender: UIButton) {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "TherapistSignUpVC") as? TherapistSignUpVC {
            self.pushOrPresentViewController(vc, true)
        }
    }

}
