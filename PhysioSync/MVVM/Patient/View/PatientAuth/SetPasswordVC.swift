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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    // MARK: - Set UI
    func setUI() {
        bottomView.addTopCornerRadius(radius: 24)
    }
    
    // MARK: - Buttons Action
    
    @IBAction func nextBtnActn(_ sender: UIButton) {
        if let vc = self.switchController(.therapistOnboardingID, .therapistOnboarding) as? TherapistOnboardingVC {
            vc.isFromPatient = true
            self.pushOrPresentViewController(vc, true)
        }
    }
    
    @IBAction func backBtnActn(_ sender: UIButton) {
        self.dismissOrPopViewController()
    }
}
