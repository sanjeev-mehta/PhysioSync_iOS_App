//
//  TherapistPatientInfoVC.swift
//  PhysioSync
//
//  Created by Gurmeet Singh on 2024-06-13.
//

import UIKit

class TherapistPatientInfoVC: UIViewController {

    // MARK: -  IBOutlets
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setHeader("Therapist Profile", rightImg: UIImage(named: "editProfile")!, isRightBtn: true) {
            self.dismissOrPopViewController()
        } rightButtonAction: {
            self.editBtnActn()
        }
    }
    
    // MARK: - Methods
    func editBtnActn() {
        if let vc = self.switchController(.therapistPatientStep1VC, .therapistPatientProfile) as? TherapistPatientStep1VC {
            self.pushOrPresentViewController(vc, true)
        }
    }
}
