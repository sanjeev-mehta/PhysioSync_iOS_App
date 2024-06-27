//
//  TherapistPatientStep2VC.swift
//  PhysioSync
//
//  Created by Gurmeet Singh on 2024-06-13.
//

import UIKit

class TherapistPatientStep2VC: UIViewController {

    //MARK: - IBOutlers
    @IBOutlet weak var emailId: UITextField!
    @IBOutlet weak var phoneNumber: UITextField!
    @IBOutlet weak var address: UITextView!
    
    // MARK: - Variables
    var parms = [String: Any]()
    var profileImage: UIImage?
    var model: Patient?
    var isEdit = false
    var isImageChange = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.debugPrint("\(parms)")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setHeader("Patient Info", isRightBtn: false) {
            self.dismissOrPopViewController()
        } rightButtonAction: {
            // No Need
        }
        setData()
    }
    
    // MARK: -  Set Edit Data
    func setData() {
        if isEdit {
            if let model = model {
                emailId.text = model.firstName
                phoneNumber.text = model.lastName
//                address.text = model.address
            }
        }
    }
    
    
    // MARK: -  Validation
    func validation() {
        if emailId.text == "" {
            showWarningAlert("Please enter email address")
        } else if !self.isValidEmail(emailId.text ?? "") {
            showWarningAlert("Please enter valid email address")
        } else if phoneNumber.text == "" {
            showWarningAlert("Please enter phone number")
        } else if address.text == "" {
            showWarningAlert("Please enter address")
        } else {
            parms["patient_email"] = emailId.text!
            parms["phone_no"] = phoneNumber.text!
            parms["address"] = address.text!
            if let vc = self.switchController(.therapistPatientStep3VC, .therapistPatientProfile) as? TherapistPatientStep3VC {
                vc.parms = parms
                vc.profileImage = profileImage
                vc.model = model
                vc.isEdit = isEdit
                vc.isImageChange = isImageChange
                self.pushOrPresentViewController(vc, true)
            }
        }
    }
    
    // MARK: - showAlert
    func showWarningAlert(_ message: String) {
        self.displayAlert(title: "Warning!", msg: message, ok: "Ok")
    }
    
    // MARK: -  Buttons Actions
    @IBAction func saveBtnActn(_ sender: UIButton) {
        validation()
    }
    
}
