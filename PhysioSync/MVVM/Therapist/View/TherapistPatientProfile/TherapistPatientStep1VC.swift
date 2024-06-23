//
//  TherapistPatientStep1VC.swift
//  PhysioSync
//
//  Created by Gurmeet Singh on 2024-06-13.
//

import UIKit

class TherapistPatientStep1VC: UIViewController {

    //MARK: - IBOutlets
    @IBOutlet weak var profileImgView: UIImageView!
    @IBOutlet var viewsTf: [UITextField]!
    
    // Variables
    var isEdit = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setHeader("Therapist Profile", isRightBtn: false) {
            self.dismissOrPopViewController()
        } rightButtonAction: {
            // No Need
        }
    }
    
    // MARK: -  Buttons Actions
    @IBAction func saveBtnActn(_ sender: UIButton) {
        if let vc = self.switchController(.therapistPatientStep2VC, .therapistPatientProfile) as? TherapistPatientStep2VC {
            self.pushOrPresentViewController(vc, true)
        }
    }
    
    @IBAction func uploadPictureBtnActn(_ sender: UIButton) {
        
    }
}
