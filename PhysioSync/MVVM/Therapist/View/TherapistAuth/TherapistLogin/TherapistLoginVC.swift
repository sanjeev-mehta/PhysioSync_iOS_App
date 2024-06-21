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
    
    // MARK: - Variables
    let vm = TherapistLoginViewModel.shareInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()

        emailTf.text = "sgurmeet392@gmail.com"
        passwordTf.text = "123456"
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

}
