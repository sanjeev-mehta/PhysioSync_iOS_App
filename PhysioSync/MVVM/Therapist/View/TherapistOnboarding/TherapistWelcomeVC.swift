//
//  TherapistWelcomeVC.swift
//  PhysioSync
//
//  Created by Sanjeev Mehta on 30/05/24.
//

import UIKit

class TherapistWelcomeVC: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var bottomView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
    }
    
    // MARK: - Set UI
    func setUI() {
        bottomView.addTopCornerRadius(radius: 24)
    }

    // MARK: - Buttons Action
    @IBAction func backBtnActn(_ sender: UIButton) {
            self.dismissOrPopViewController()
    }
    
    @IBAction func loginBtnActn(_ sender: UIButton) {
        if let vc = self.switchController(.tabBarController, .therapistTab) {
            self.pushOrPresentViewController(vc, true)
        }
    }
    
}
