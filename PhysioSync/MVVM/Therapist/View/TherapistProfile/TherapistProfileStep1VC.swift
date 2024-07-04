//
//  TherapistProfileStep1VC.swift
//  PhysioSync
//
//  Created by Gurmeet Singh on 2024-06-13.
//

import UIKit

class TherapistProfileStep1VC: UIViewController {

    //MARK: - IBOutlets
    @IBOutlet weak var profileImgView: UIImageView!
    @IBOutlet weak var firstNameTf: UITextField!
    @IBOutlet weak var clinicAddressTV: UITextView!
    
    //MARK: - Variables
    var customImagePicker: ImagePickerHelper?
    let vm = TherapistProfileStep1ViewModel.shareInstance
    var isImageChange = false
    var parms = [String: Any]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.customImagePicker = ImagePickerHelper(viewController: self)
        callGetTherapist()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setHeader("Edit Profile", backImg: UIImage(named: "Cross 1")!) {
            let alertController = UIAlertController(title: "Discard Changes?", message: "Are you sure you want to discard your changes?", preferredStyle: .alert)
            
            let discardAction = UIAlertAction(title: "Discard", style: .destructive) { _ in
                // Handle discard action here
                self.dismissOrPopViewController()
            }
            
            let keepEditingAction = UIAlertAction(title: "Keep Editing", style: .default) { _ in
                print("Continuing to edit")
            }
            
            alertController.addAction(discardAction)
            alertController.addAction(keepEditingAction)
            
            self.present(alertController, animated: true, completion: nil)
        } rightButtonAction: {
            // No Need
        }
    }
    
    func callGetTherapist() {
        vm.getTherapistApi(vc: self) { status in
            if status {
                DispatchQueue.main.async {
                    self.setData()
                }
            }
        }
    }
    
    func setData() {
        if let data = vm.model?.data {
            profileImgView.setImage(with: data.profilePhoto)
            firstNameTf.text = data.therapistName
            clinicAddressTV.text = data.clinic?.address
        }
    }
    
    func validation() {
        if profileImgView.image == nil {
            self.displayAlert(title: "Warning", msg: "Please select a profile image", ok: "Ok")
        } else if firstNameTf.text == "" {
            self.displayAlert(title: "Warning", msg: "Please enter first name", ok: "Ok")
        } else if clinicAddressTV.text == "" {
            self.displayAlert(title: "Warning", msg: "Please enter clinic address", ok: "Ok")
        } else {
            self.parms = ["therapist_name": firstNameTf.text!, "clinic_address": clinicAddressTV.text!]
            if let vc = self.switchController(.therapistProfileStep2VC, .therapistProfile) as? TherapistProfileStep2VC {
                vc.isImageChange = isImageChange
                vc.parms = parms
                vc.profileImg = profileImgView.image!
                self.pushOrPresentViewController(vc, true)
            }
        }
    }
    
    // MARK: -  openActionSheet for select image
    func openSheet(sender: UIButton) {
        let actionSheet = UIAlertController(title: "Select Image", message: "Choose a source", preferredStyle: .actionSheet)
        
        let photoLibraryAction = UIAlertAction(title: "Photo Library", style: .default) { _ in
            self.customImagePicker?.showImagePicker(sourceType: .photoLibrary) { image in
                if let selectedImage = image {
                    // Use the selected image
                    self.profileImgView.image = selectedImage
                    self.isImageChange = true
                    print("Image selected: \(selectedImage)")
                } else {
                    // Handle the case where no image was selected
                    print("Image selection canceled.")
                }
            }
        }
        
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { _ in
            self.customImagePicker?.showImagePicker(sourceType: .camera) { image in
                if let capturedImage = image {
                    // Use the captured image
                    self.profileImgView.image = capturedImage
                    self.isImageChange = true
                    print("Image captured: \(capturedImage)")
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

    
    // MARK: -  Buttons Action
    @IBAction func saveBtnActn(_ sender: UIButton) {
        validation()
    }
    
    @IBAction func changeImageBtnActn(_ sender: UIButton) {
        self.openSheet(sender: sender)
    }

}
