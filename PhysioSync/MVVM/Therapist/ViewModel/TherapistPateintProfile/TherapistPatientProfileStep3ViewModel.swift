//
//  TherapistPatientProfileStep1ViewModel.swift
//  PhysioSync
//
//  Created by Gurmeet Singh on 2024-06-23.
//

import Foundation
import UIKit
import SDWebImage

class TherapistPatientProfileStep3ViewModel {
    
    
    // MARK: - Variables
    static let shareInstance = TherapistPatientProfileStep3ViewModel()
    let apiHelper = ApiHelper.shareInstance
    
    // MARK: -  Add New Patient
    func addNewPatient(vc: UIViewController,parm: [String: Any], completion: @escaping(Bool) -> ()) {
        let url = API.Endpoints.addNewPatients
        ApiHelper.shareInstance.hitApi(view: vc, method: .post, parm: parm, url: url, isHeader: true, isLoader: true) { json, err in
            if err != nil {
                vc.displayAlert(title: "Alert!", msg: "Something went wrong", ok: "Ok")
            } else {
                if json["success"].boolValue {
                    completion(true)
                } else {
                    vc.displayAlert(title: "Alert!", msg: json["data"]["success"].stringValue, ok: "Ok")
                }
            }
        }
        
    }
    
    // MARK: - Update Patient
    
    func updatePatient(vc: UIViewController,parm: [String: Any], isHeader: Bool = true ,id: String,completion: @escaping(Bool) -> ()) {
        let url = API.Endpoints.updatePatients + "/\(id)"
        ApiHelper.shareInstance.hitApi(view: vc, method: .put, parm: parm, url: url, isHeader: isHeader, isLoader: true) { json, err in
            if err != nil {
                vc.displayAlert(title: "Alert!", msg: "Something went wrong", ok: "Ok")
            } else {
                if json["success"].boolValue {
                    completion(true)
                } else {
                    vc.displayAlert(title: "Alert!", msg: json["message"].stringValue, ok: "Ok")
                }
            }
        }
        
    }
    
    // MARK: -  Upload Image
    func uploadImage(profileImage: UIImage?,completion: @escaping(String) -> ()) {
        guard let image = profileImage, let imageData = image.jpegData(compressionQuality: 0.8) else { return }
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
                    completion(imageUrl!)
                } else if let error = error {
                    print("Error uploading file: \(error.localizedDescription)")
                }
            }
        } catch {
            print("Error saving image: \(error.localizedDescription)")
        }
    }
    
    
}
