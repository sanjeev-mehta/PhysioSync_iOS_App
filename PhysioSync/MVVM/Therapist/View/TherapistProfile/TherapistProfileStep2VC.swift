//
//  TherapistProfileStep2VC.swift
//  PhysioSync
//
//  Created by Gurmeet Singh on 2024-06-13.
//

import UIKit

class TherapistProfileStep2VC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setHeader("Therapist Profile") {
            self.dismissOrPopViewController()
        } rightButtonAction: {
            // No Need
        }
    }
    
    // MARK: -  Buttons Action
    @IBAction func saveBtnActn(_ sender: UIButton) {
        if let vc = self.switchController(.tabBarController, .therapistTab) {
            self.navigationController?.popToViewController(vc, animated: true)
        }
    }


}
