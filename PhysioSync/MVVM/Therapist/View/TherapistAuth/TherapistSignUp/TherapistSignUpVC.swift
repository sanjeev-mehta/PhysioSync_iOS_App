//
//  TherapistAuthVC.swift
//  PhysioSync
//
//  Created by Rohit on 2024-07-11.
//

import UIKit

class TherapistSignUpVC: UIViewController {

    @IBOutlet var tfs: [UITextField]!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var bottomView: UIView!
    
    var img: UIImage?
    var imagePicker: ImagePickerHelper?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        bottomView.addTopCornerRadius(radius: 24)
        self.imagePicker = ImagePickerHelper(viewController: self)
    }
    
    func validation() {
        if imgView.image == nil {
            self.displayAlert(title: "Alert!", msg: "Please select image", ok: "Ok")
        } else if tfs[0].text == "" {
            self.displayAlert(title: "Alert!", msg: "Please enter clinic name", ok: "Ok")
        } else if tfs[1].text == "" {
            self.displayAlert(title: "Alert!", msg: "Please enter therapist name", ok: "Ok")
        } else if tfs[2].text == "" {
            self.displayAlert(title: "Alert!", msg: "Please enter clinic address", ok: "Ok")
        } else {
            if let vc = self.storyboard?.instantiateViewController(withIdentifier: "TherapistSignUpVC2") as? TherapistSignUpVC2 {
                vc.clinicAddress = tfs[2].text!
                vc.clinicName = tfs[0].text!
                vc.therapistName = tfs[1].text!
                vc.img = imgView.image!
                self.pushOrPresentViewController(vc, true)
            }
        }
    }
    
    func openImageSheet(sender: UIButton) {
        let actionSheet = UIAlertController(title: "Select Image", message: "Choose a source", preferredStyle: .actionSheet)
        
        let photoLibraryAction = UIAlertAction(title: "Photo Library", style: .default) { _ in
            self.imagePicker?.showImagePicker(sourceType: .photoLibrary) { image in
                if let selectedImage = image {
                    self.imgView.image = selectedImage
                    } else {
                    // Handle the case where no image was selected
                    print("Image selection canceled.")
                }
            }
        }
        
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { _ in
            self.imagePicker?.showImagePicker(sourceType: .camera) { image in
                if let capturedImage = image {
                    self.imgView.image = capturedImage
                } else {
                    // Handle the case where no image was captured
                    print("Image capture canceled.")
                }
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        actionSheet.addAction(photoLibraryAction)
        actionSheet.addAction(cameraAction)
        actionSheet.addAction(cancelAction)
        
        // For iPad compatibility
        if let popoverController = actionSheet.popoverPresentationController {
            popoverController.sourceView = sender
            popoverController.sourceRect = sender.bounds
        }
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    @IBAction func continueBtnActn(_ sender: UIButton) {
        sender.pressedAnimation {
            self.validation()
        }
        
    }
    
    @IBAction func selectPhotoBtnActn(_ sender: UIButton) {
        sender.pressedAnimation {
            self.openImageSheet(sender: sender)
        }
    }
    
    @IBAction func backBtnActn(_ sender: UIButton) {
        self.dismissOrPopViewController()
    }

}

class TherapistSignUpVC2: UIViewController {

    @IBOutlet var tfs: [UITextField]!
    @IBOutlet weak var setPasswordShowHideBtn: UIButton!
    @IBOutlet weak var confirmPasswordShowHideBtn: UIButton!
    @IBOutlet weak var bottomView: UIView!
    
    var setPasswordHide = false
    var confirmPasswordHide = false
    let vm = TherapistSignUpViewModel.shareInstance
    let awsHelper = AWSHelper.shared
    var img = UIImage()
    var clinicName = ""
    var therapistName = ""
    var clinicAddress = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        bottomView.addTopCornerRadius(radius: 24)
    }

    // MARK: - Password Show Hide
    func setPasswordShowHide() {
        self.tfs[2].isSecureTextEntry = setPasswordHide
        self.setPasswordShowHideBtn.setImage(setPasswordHide ? UIImage(named: "passwordHide")! : UIImage(named: "passwordShow")!, for: .normal)
    }
    
    func confirmPasswordShowHide() {
        self.tfs[3].isSecureTextEntry = confirmPasswordHide
        self.setPasswordShowHideBtn.setImage(confirmPasswordHide ? UIImage(named: "passwordHide")! : UIImage(named: "passwordShow")!, for: .normal)
    }
    
    func uploadImage() {
        guard let imageData = img.jpegData(compressionQuality: 0.8) else { return }
        let tempDirectory = NSTemporaryDirectory()
        let fileName = UUID().uuidString + ".jpg"
        let fileURL = URL(fileURLWithPath: tempDirectory).appendingPathComponent(fileName)
        
        do {
            try imageData.write(to: fileURL)
            AWSHelper.shared.uploadImageFile(url: fileURL, fileName: fileName, progress: { progress in
                print("Upload Progress: \(progress)%")
            }) { success, imageUrl, error in
                if success {
                    print("File uploaded successfully, URL: \(imageUrl ?? "")")
                    DispatchQueue.main.async {
                        let parm = ["therapist_name": self.therapistName, "email": self.tfs[0].text!, "clinic_name": self.clinicName, "clinic_address": self.clinicAddress, "clinic_contact_no": self.tfs[1].text!, "password": self.tfs[2].text!, "profile_photo": imageUrl ?? ""]
                        self.vm.singUpApi(vc: self, parm: parm) { status in
                            if status {
                                if let vc = self.switchController(.tabBarController, .therapistTab) {
                                    self.pushOrPresentViewController(vc, true)
                                }
                            }
                        }
                    }
                } else if let error = error {
                    print("Error uploading file: \(error.localizedDescription)")
                }
            }
        } catch {
            print("Error saving image: \(error.localizedDescription)")
        }
    }
    
    func validation() {
        if tfs[0].text == "" {
            self.displayAlert(title: "Alert!", msg: "Please enter email", ok: "Ok")
        } else if !self.isValidEmail(tfs[0].text!) {
            self.displayAlert(title: "Alert!", msg: "Please enter valid email", ok: "Ok")
        } else if tfs[1].text == "" {
            self.displayAlert(title: "Alert!", msg: "Please enter contact number", ok: "Ok")
        } else if tfs[2].text == "" {
            self.displayAlert(title: "Alert!", msg: "Please enter password", ok: "Ok")
        } else if tfs[2].text != tfs[3].text {
            self.displayAlert(title: "Alert!", msg: "Password not match", ok: "Ok")
        } else {
            self.uploadImage()
        }
    }
    
    @IBAction func setPasswordShowHideBtnActn(_ sender: UIButton) {
        sender.pressedAnimation {
            self.setPasswordHide = self.setPasswordHide ? false : true
            self.setPasswordShowHide()
        }
        
    }
    
    @IBAction func confirmPasswordShowHideBtnActn(_ sender: UIButton) {
        sender.pressedAnimation {
            self.confirmPasswordHide = self.confirmPasswordHide ? false : true
            self.confirmPasswordShowHide()
        }
        
    }
    
    @IBAction func signUpBtnActn(_ sender: UIButton) {
        self.validation()
    }
    
    @IBAction func backBtnActn(_ sender: UIButton) {
        self.dismissOrPopViewController()
    }
}
