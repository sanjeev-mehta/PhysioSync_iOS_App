//
//  TherapistProfileStep2VC.swift
//  PhysioSync
//
//  Created by Gurmeet Singh on 2024-06-13.
//

import UIKit

class TherapistProfileStep2VC: UIViewController {

    //MARK: - IBOutlets
    @IBOutlet weak var emailIdTf: UITextField!
    @IBOutlet weak var contactNumberTf: UITextField!
    
    //MARK: -  Variables
    let vm = TherapistProfileStep1ViewModel.shareInstance
    var isImageChange = false
    var parms = [String: Any]()
    var profileImg: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setHeader("Edit Profile") {
            self.dismissOrPopViewController()
        } rightButtonAction: {
            // No Need
        }
    }
    
    func setData() {
        if let model = vm.model?.data {
            emailIdTf.text = model.email
            contactNumberTf.text = model.clinic?.contactNo
        }
    }
    
    func validation() {
        if emailIdTf.text == "" {
            self.displayAlert(title: "Warning", msg: "Please enter email address", ok: "Ok")
        } else if contactNumberTf.text == "" {
            self.displayAlert(title: "Warning", msg: "Please enter contact number", ok: "Ok")
        } else {
            callUpdateTherapistApi()
        }
    }
    
    func callUpdateTherapistApi() {
        self.parms["email"] = emailIdTf.text!
        self.parms["clinic_contact_no"] = contactNumberTf.text!
        self.parms["clinic_name"] = vm.model?.data!.clinic!.name
        if isImageChange {
            vm.uploadImage(profileImage: profileImg) { link in
                self.parms["profile_photo"] = link
                DispatchQueue.main.async {
                    self.vm.updateTherapistApi(vc: self, parm: self.parms) { status in
                        if status {
                            self.popController()
                        }
                    }
                }
            }
        } else {
            self.parms["profile_photo"] = self.vm.model!.data!.profilePhoto
            vm.updateTherapistApi(vc: self, parm: self.parms) { status in
                if status {
                    self.popController()
                }
            }
        }
    }
    
    //MARK: - Pop Controller
    func popController() {
        if let viewControllers = navigationController?.viewControllers {
               for viewController in viewControllers {
                   print(viewController)
                   if viewController.isKind(of: AnimatedTabBarController.self) {
                       navigationController?.popToViewController(viewController, animated: true)
                       return
                   }
               }
               print("No view controller of the specified class in the navigation stack.")
           } else {
               print("Navigation controller is nil.")
           }
    }
    
    // MARK: -  Buttons Action
    @IBAction func saveBtnActn(_ sender: UIButton) {
        validation()
    }

    @IBAction func cancelBtnActn(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }

}
