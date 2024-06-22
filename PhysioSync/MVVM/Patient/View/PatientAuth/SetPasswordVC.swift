//
//  SetPasswordVC.swift
//  PhysioSync
//
//  Created by Sanjeev Mehta on 30/05/24.
//

import UIKit

class SetPasswordVC: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var passwordTf: UITextField!
    @IBOutlet weak var confirmPasswordTf: UITextField!
    
    // MARK: - Variables
    let vm = SetPasswordViewModel.shareInstance
    var email = ""
    let loginVM = PatientLoginViewModel.shareInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    // MARK: - Set UI
    func setUI() {
        bottomView.addTopCornerRadius(radius: 24)
    }
    
    //MARK: - Set Password Api
    func setPasswordApi() {
        let parm = ["email": email, "password": passwordTf.text!]
       
        vm.callPatientLogin(vc: self, parm: parm) { status in
            if status {
                self.loginVM.callPatientLogin(vc: self, parm: parm) { status in
                    self.showOnBoarding()
                }
            }
        }
    }
    
    //MARK: - Open Tab
    func showOnBoarding() {
        if let vc = self.switchController(.therapistOnboardingID, .therapistOnboarding) as? TherapistOnboardingVC {
            vc.isFromPatient = true
            self.pushOrPresentViewController(vc, true)
        }
    }
    
    //MARK: - Validation
    func validation() {
        if passwordTf.text == "" {
            self.displayAlert(title: "Warning", msg: "please enter password", ok: "ok")
        } else if confirmPasswordTf.text == "" {
            self.displayAlert(title: "Warning", msg: "please enter confirm password", ok: "ok")
        } else if confirmPasswordTf.text != passwordTf.text {
            self.displayAlert(title: "Warning", msg: "password is not matching", ok: "ok")
        } else {
            setPasswordApi()
        }
    }
    
    // MARK: - Buttons Action
    
    @IBAction func nextBtnActn(_ sender: UIButton) {
        sender.pressedAnimation {
            self.validation()
        }
    }
    
    @IBAction func backBtnActn(_ sender: UIButton) {
        self.dismissOrPopViewController()
    }
}
