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
    var isPatientSide = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.debugPrint("\(parms)")
        phoneNumber.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isPatientSide {
            self.setHeader("Edit Profile", isRightBtn: false) {
                self.dismissOrPopViewController()
            } rightButtonAction: {
                // No Need
            }
        } else {
            self.setHeader("Patient Info", isRightBtn: false) {
                self.dismissOrPopViewController()
            } rightButtonAction: {
                // No Need
            }
        }
        setData()
    }
    
    // MARK: -  Set Edit Data
    func setData() {
        if isEdit {
            if let model = model {
                emailId.text = model.patientEmail
                phoneNumber.text = model.phone_no
                address.text = model.address
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
        } else if !isValidPhoneNumber(phoneNumber.text!) {
            showWarningAlert("Please enter valid phone number")
        }  else if address.text == "" {
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
                vc.isPatientSide = isPatientSide
                self.pushOrPresentViewController(vc, true)
            }
        }
    }
    
    // MARK: - Phone Number Validation
       func isValidPhoneNumber(_ number: String) -> Bool {
           let phoneRegex = "^(\\d{3}-\\d{3}-\\d{4})$"
           let phoneTest = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
           return phoneTest.evaluate(with: number)
       }
    
    // MARK: - showAlert
    func showWarningAlert(_ message: String) {
        self.displayAlert(title: "Warning!", msg: message, ok: "Ok")
    }
    
    // MARK: -  Buttons Actions
    @IBAction func saveBtnActn(_ sender: UIButton) {
        sender.pressedAnimation {
            self.validation()
        }
    }
}

extension TherapistPatientStep2VC: UITextFieldDelegate {
    // MARK: - Text Field Delegate for Phone Number Formatting
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == phoneNumber {
            let currentText = textField.text ?? ""
            let updatedText = (currentText as NSString).replacingCharacters(in: range, with: string)
            
            if string.isEmpty { // Handling backspace
                return true
            }
            
            if updatedText.count > 12 {
                return false
            }
            
            let formattedText = formatPhoneNumber(updatedText)
            textField.text = formattedText
            
            return false
        }
        return true
    }
    
    func formatPhoneNumber(_ number: String) -> String {
        let digits = number.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        let length = digits.count
        
        switch length {
        case 0...3:
            return digits
        case 4...6:
            let startIndex = digits.index(digits.startIndex, offsetBy: 3)
            let firstPart = String(digits[..<startIndex])
            let secondPart = String(digits[startIndex...])
            return "\(firstPart)-\(secondPart)"
        case 7...10:
            let startIndex = digits.index(digits.startIndex, offsetBy: 3)
            let middleIndex = digits.index(digits.startIndex, offsetBy: 6)
            let firstPart = String(digits[..<startIndex])
            let secondPart = String(digits[startIndex..<middleIndex])
            let thirdPart = String(digits[middleIndex...])
            return "\(firstPart)-\(secondPart)-\(thirdPart)"
        default:
            return digits
        }
    }
}
