//
//  ChangePasswordVC.swift
//  PhysioSync
//
//  Created by Gurmeet Singh on 2024-07-11.
//

import UIKit

class ChangePasswordVC: UIViewController {

    @IBOutlet weak var oldpasswordBtn: UIButton!
    @IBOutlet weak var newpasswordBtn: UIButton!
    @IBOutlet weak var confirmpasswordBtn: UIButton!
    @IBOutlet var passwordTfs: [UITextField]!
    @IBOutlet weak var deleteBtn: UIButton!
    
    var isOldHide = true
    var isNewHide = true
    var isConfirmHide = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    // MARK: - Password Show Hide
    func oldPasswordShowHide() {
        self.passwordTfs[0].isSecureTextEntry = isOldHide
        self.oldpasswordBtn.setImage(isOldHide ? UIImage(named: "passwordHide")! : UIImage(named: "passwordShow")!, for: .normal)
    }
    
    func newPasswordShowHide() {
        self.passwordTfs[1].isSecureTextEntry = isNewHide
        self.newpasswordBtn.setImage(isNewHide ? UIImage(named: "passwordHide")! : UIImage(named: "passwordShow")!, for: .normal)
    }
    
    func confirmPasswordShowHide() {
        self.passwordTfs[2].isSecureTextEntry = isConfirmHide
        self.confirmpasswordBtn.setImage(isConfirmHide ? UIImage(named: "passwordHide")! : UIImage(named: "passwordShow")!, for: .normal)
    }
    
    func validation() {
        if passwordTfs[0].text == "" {
            self.displayAlert(title: "Alert!", msg: "Please enter old password", ok: "Ok")
        } else if passwordTfs[1].text == "" {
            self.displayAlert(title: "Alert!", msg: "Please enter new password", ok: "Ok")
        } else if passwordTfs[2].text == "" {
            self.displayAlert(title: "Alert!", msg: "Please enter confirm password", ok: "Ok")
        } else if passwordTfs[2].text != passwordTfs[1].text {
            self.displayAlert(title: "Alert!", msg: "Password is not matched", ok: "Ok")
        } else {
            let url = API.baseURL + "update-password"
            let parm = ["oldPassword": passwordTfs[0].text!, "newPassword": passwordTfs[1].text!]
            ApiHelper.shareInstance.hitApi(view: self, method: .put, parm: parm, url: url, isHeader: true, isLoader: true) { json, err in
                if err != nil {
                    self.displayAlert(title: "Alert!", msg: err?.localizedDescription, ok: "Ok")
                } else {
                    self.displayAlert(title: "Success", msg: "Password has been changed", ok: "Ok") {
                        self.dismissOrPopViewController()
                    }
                }
            }
        }
    }

    @IBAction func saveBtnActn(_ sender: UIButton) {
        validation()
    }
    
    @IBAction func hideShowPasswordActn(_ sender: UIButton) {
        if sender.tag == 0 {
            self.isOldHide = self.isOldHide ? false : true
            self.oldPasswordShowHide()
        } else if sender.tag == 1 {
            self.isNewHide = self.isNewHide ? false : true
            self.newPasswordShowHide()
        } else {
            self.isConfirmHide = self.isConfirmHide ? false : true
            self.confirmPasswordShowHide()
        }
    }
    
    @IBAction func backBtnActn(_ sender: UIButton) {
        self.dismissOrPopViewController()
    }
}
