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

        // Do any additional setup after loading the view.
    }
    
    // MARK: - Api Calling
    func callApi() {
        let parm : [String: Any] = ["email": emailTf.text!, "password": passwordTf.text!]
        vm.callTherapistLoginApi(self, with: parm) { status in
            if status {
                
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
            callApi()
        }
    }
    
    // MARK: - Show Alert
    func showAlert(_ message: String) {
        self.displayAlert(title: "Alert", msg: message, ok: "Ok")
    }
    // Buttons Actions
    @IBAction func loginBtnActn(_ sender: UIButton) {
        validation()
    }

}
