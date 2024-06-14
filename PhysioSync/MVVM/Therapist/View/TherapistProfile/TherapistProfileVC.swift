//
//  TherapistProfileVC.swift
//  PhysioSync
//
//  Created by Gurmeet Singh on 2024-06-13.
//

import UIKit

class TherapistProfileVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func editProfileBtnActn(_ sender: UIButton) {
        if let vc = self.switchController(.therapistProfileStep1VC, .therapistProfile) {
            self.pushOrPresentViewController(vc, true)
        }
    }

}
