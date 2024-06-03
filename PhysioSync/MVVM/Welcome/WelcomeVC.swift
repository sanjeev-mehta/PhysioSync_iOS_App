//
//  WelcomeVC.swift
//  PhysioSync
//
//  Created by Sanjeev Mehta on 30/05/24.
//

import UIKit

class WelcomeVC: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var bottomView: UIView!
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setUI()
    }
    
    // MARK: - Set UI
    func setUI() {
        bottomView.addTopCornerRadius(radius: 24)
    }
    
    
    // MARK: - Buttons Action
    
    @IBAction func physiotherapistBtnActn(_ sender: UIButton) {
        if let vc = self.switchController(.therapistOnboardingID, .therapistOnboarding) {
            self.pushOrPresentViewController(vc, true)
        }
    }
    
    @IBAction func patientBtnActn(_ sender: UIButton) {
        if let vc = self.switchController(.patientLogin, .patientAuth) {
            self.pushOrPresentViewController(vc, true)
        }
    }
}
