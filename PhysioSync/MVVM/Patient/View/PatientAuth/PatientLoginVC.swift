//
//  PatientLoginVC.swift
//  PhysioSync
//
//  Created by Sanjeev Mehta on 30/05/24.
//

import UIKit

class PatientLoginVC: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var passwordView: UIView!
    @IBOutlet weak var bottomView: UIView!
    
    // MARK: -  Variables
    var isVerifiedEmail = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUI()
    }
    
    // MARK: - Set UI
    func setUI() {
        passwordView.isHidden = true
        bottomView.addTopCornerRadius(radius: 24)
    }
    
    
    // MARK: - Buttons Action
    
    @IBAction func nextBtnActn(_ sender: UIButton) {
        if isVerifiedEmail {
            UIView.animate(withDuration: 0.4) {
                self.passwordView.isHidden = false
            }
        } else {
            if let vc = self.switchController(.setPassword, .patientAuth) {
                self.present(vc, animated: true)
            }
        }
       
        
    }
    
    @IBAction func backBtnActn(_ sender: UIButton) {
        self.dismissOrPopViewController()
    }

}
