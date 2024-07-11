//
//  SettingsVC.swift
//  PhysioSync
//
//  Created by Gurmeet Singh on 2024-07-11.
//

import UIKit

class SettingsVC: UIViewController {

    @IBOutlet weak var reminderView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if UserDefaults.standard.getUsernameToken() == "" {
            self.reminderView.isHidden = false
        } else {
            self.reminderView.isHidden = true
        }
    }
    
    @IBAction func crossBtnActn(_ sender: UIButton) {
        self.dismissOrPopViewController()
    }
    
    @IBAction func changePasswordBtnActn(_ sender: UIButton) {
        
    }
}
