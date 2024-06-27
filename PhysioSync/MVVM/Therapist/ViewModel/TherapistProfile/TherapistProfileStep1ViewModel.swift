//
//  TherapistProfileStep1ViewModel.swift
//  PhysioSync
//
//  Created by Gurmeet Singh on 2024-06-24.
//

import UIKit

class TherapistProfileStep1ViewModel {
    
    static let shareInstance = TherapistProfileStep1ViewModel()
    let apiHelper = ApiHelper.shareInstance
    var model: TherapistProfileModel?
    
    func getTherapistApi(vc: UIViewController, completion: @escaping (Bool) -> ()) {
        let url = API.Endpoints.getTherapist
        apiHelper.getApi(view: vc, url: url, isHeader: true, isLoader: true) { json, err in
            if err != nil {
                vc.displayAlert(title: "Alert!", msg: "something went wrong", ok: "Ok")
            } else {
                vc.debugPrint("\(json)")
                self.model = TherapistProfileModel(json)
                if let model = self.model {
                    if model.success {
                        completion(true)
                    } else {
                        vc.displayAlert(title: "Alert!", msg: model.message, ok: "Ok")
                    }
                } else {
                    vc.displayAlert(title: "Alert!", msg: "something went wrong", ok: "Ok")
                }
                
            }
        }
    }
    
    func updateTherapistApi(vc: UIViewController, parm: [String: Any], completion: @escaping (Bool) -> ()) {
        let url = API.Endpoints.updateTherapists
        apiHelper.hitApi(view: vc, method: .put, parm: parm, url: url, isHeader: true, isLoader: true) { json, err in
            if err != nil {
                vc.displayAlert(title: "Alert!", msg: "something went wrong", ok: "Ok")
            } else {
                vc.debugPrint("\(json)")
                if json["success"].boolValue {
                    completion(true)
                } else {
                    vc.displayAlert(title: "Alert!", msg: "something went wrong", ok: "Ok")
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
