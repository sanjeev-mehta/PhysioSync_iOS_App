//
//  TherapistPatientStep1VC.swift
//  PhysioSync
//
//  Created by Gurmeet Singh on 2024-06-13.
//

import UIKit
import Fastis
import iOSDropDown

class TherapistPatientStep1VC: UIViewController {
    
    //MARK: - IBOutlets
    @IBOutlet weak var profileImgView: UIImageView!
    @IBOutlet var viewsTf: [UITextField]!
    @IBOutlet weak var dropDownView: UIView!
    
    // Variables
    var isEdit = false
    var customImagePicker: ImagePickerHelper?
    var parms = [String: Any]()
    var model: Patient?
    var isImageChange = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.customImagePicker = ImagePickerHelper(viewController: self)
        setDropDown()
        setData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setHeader("Therapist Profile", isRightBtn: false) {
            self.dismissOrPopViewController()
        } rightButtonAction: {
            // No Need
        }
    }
    
    // MARK: -  Set Edit Data
    func setData() {
        if isEdit {
            if let model = model {
                profileImgView.setImage(with: model.profilePhoto)
                viewsTf[0].text = model.firstName
                viewsTf[1].text = model.lastName
                viewsTf[2].text = model.dateOfBirth
                viewsTf[3].text = model.gender
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
    
    //MARK: - Validation
    func validation() {
        if viewsTf[0].text == "" {
            showWarningAlert("Please enter first name")
        } else if viewsTf[1].text == "" {
            showWarningAlert("Please enter last name")
        } else if viewsTf[2].text == "" {
            showWarningAlert("Please select date of birth")
        } else if viewsTf[3].text == "" {
            showWarningAlert("Please select gender")
        } else {
            parms = ["first_name": viewsTf[0].text!, "last_name": viewsTf[1].text!, "date_of_birth": viewsTf[2].text!, "gender": viewsTf[3].text!]
            if let vc = self.switchController(.therapistPatientStep2VC, .therapistPatientProfile) as? TherapistPatientStep2VC {
                vc.parms = parms
                vc.profileImage = profileImgView.image
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
    
    // MARK: - Open Calendar
    func openCalendar() {
        let fastisController = FastisController(mode: .single)
        fastisController.title = "Choose range"
        fastisController.maximumDate = Date()
        fastisController.allowToChooseNilDate = true
        fastisController.dismissHandler = {
        }
        fastisController.doneHandler = { [self] value in
            self.viewsTf[2].text = "\(dateFormat(value!))"
        }
        fastisController.present(above: self)
    }
    
    //MARK: - Date Formatter
    func dateFormat(_ value: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: value)
    }
    
    // MARK: -  Buttons Actions
    
    @IBAction func saveBtnActn(_ sender: UIButton) {
        self.validation()
    }
    
    // MARK: - Drop Down
    func setDropDown() {
        let dropDown = DropDown()
        dropDown.frame = CGRect(x: 10, y: 0, width: dropDownView.frame.width - 20, height: dropDownView.frame.height)
        dropDownView.addSubview(dropDown)
        let arr = ["Male", "Female", "other"]
        self.setDropDown(dropDown: dropDown, arr: arr, arwClr: .clear)
        dropDown.didSelect { selectedText, index, id in
            print(selectedText, index, id)
            self.viewsTf[3].text = selectedText
        }
    }
    
    @IBAction func uploadPictureBtnActn(_ sender: UIButton) {
        openSheet(sender: sender)
    }
    
    @IBAction func selectDate(_ sender: UIButton) {
        openCalendar()
    }
    
}

