//
//  TherapistProfileVC.swift
//  PhysioSync
//
//  Created by Gurmeet Singh on 2024-06-13.
//

import UIKit

class TherapistProfileVC: UIViewController {

    @IBOutlet weak var profileImgVW: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var emailLbl: UILabel!
    
    var patient: Patient?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if UserDefaults.standard.getUsernameToken() == "" {
            callGetPatientProfileApi()
        } else {
            callGetTherapistProfileApi()
//            profileImgVW.setImage(with: UserDefaults.standard.getTherapistProfileImage())
//            nameLbl.text = UserDefaults.standard.getTherapistName()
//            emailLbl.text = UserDefaults.standard.getT
        }
    }
    
    func callGetPatientProfileApi() {
        let url = API.Endpoints.getPatient + "/\(UserDefaults.standard.getPatientLoginId())"
        ApiHelper.shareInstance.getApi(view: self, url: url, isHeader: false, isLoader: true) { json, err in
            print(json)
            if err != nil {
                self.displayAlert(title: "Alert!", msg: "something went wrong", ok: "Ok")
            } else {
                self.patient = Patient(json["data"][0])
                DispatchQueue.main.async {
                    if let model = self.patient {
                        self.profileImgVW.setImage(with: model.profilePhoto)
                        self.nameLbl.text = model.firstName
                        self.emailLbl.text = model.patientEmail
                    }
                }

            }
        }
    }
    
    func callGetTherapistProfileApi() {
        let url = API.Endpoints.getTherapist
        ApiHelper.shareInstance.getApi(view: self, url: url, isHeader: true, isLoader: true) { json, err in
            print(json)
            if err != nil {
                self.displayAlert(title: "Alert!", msg: "something went wrong", ok: "Ok")
            } else {
                DispatchQueue.main.async {
                   let data = json["data"]
                    self.profileImgVW.setImage(with: data["profile_photo"].stringValue)
                    self.nameLbl.text = data["therapist_name"].stringValue
                    self.emailLbl.text = data["email"].stringValue
                }

            }
        }
    }
    
    @IBAction func editProfileBtnActn(_ sender: UIButton) {
         if UserDefaults.standard.getUsernameToken() == "" {
            if let vc = self.switchController(.therapistPatientStep1VC, .therapistPatientProfile) as? TherapistPatientStep1VC {
                vc.isEdit = true
                vc.model = patient
                vc.isPatientSide = true
                self.pushOrPresentViewController(vc, true)
            }
        } else {
            if let vc = self.switchController(.therapistProfileStep1VC, .therapistProfile) {
                self.pushOrPresentViewController(vc, true)
            }
        }
        
    }
    
    @IBAction func settingBtnActn(_ sender: UIButton) {
        if let vc = self.switchController(.settingVC, .setting) as? SettingsVC {
            vc.isHeroEnabled = true
            vc.heroModalAnimationType = .selectBy(presenting: .pull(direction: .up), dismissing: .pull(direction: .down))
            vc.view.heroID = "settingPage"
            self.pushOrPresentViewController(vc, true)
        }
    }
    
    @IBAction func logOutBtnActn(_ sender: UIButton) {
        if let bundleID = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleID)
        }
        
        if let navigationController = self.navigationController {
            // Remove all view controllers except the root view controller
            navigationController.setViewControllers([navigationController.viewControllers.first!], animated: true)
        }
    }

}
