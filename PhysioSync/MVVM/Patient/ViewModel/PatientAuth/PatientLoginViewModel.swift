//
//  PatientLoginViewModel.swift
//  PhysioSync
//
//  Created by Sanjeev Mehta on 20/06/24.
//

import UIKit
import SDWebImage

class PatientLoginViewModel {
    
    static let shareInstance = PatientLoginViewModel()
    let apiHelper = ApiHelper.shareInstance
    var patientVerifyEmailModel: PatientVerifyEmailModel?
    var patientLoginModel: PatientLoginModel?
    
    func callVerifyEmail(vc: UIViewController, email: String, completion: @escaping(Int) -> ()) {
        let url = API.Endpoints.patientVerifyEmail + email
        apiHelper.getApi(view: vc, url: url, isHeader: false, isLoader: true) { json, err in
            vc.debugPrint("\(json)")
            if err != nil {
                vc.displayAlert(title: "Alert!", msg: "Something went wrong", ok: "ok")
            } else {
                self.patientVerifyEmailModel = PatientVerifyEmailModel(json)
                if let model = self.patientVerifyEmailModel {
                    if model.success {
                        if model.data[0].password != "" {
                            completion(1)
                        } else {
                            completion(2)
                        }
                    } else {
                        vc.displayAlert(title: "Alert!", msg: model.message, ok: "ok")
                    }
                } else {
                    vc.displayAlert(title: "Alert!", msg: "Something went wrong", ok: "ok")
                }
            }
        }
    }
    
    func callPatientLogin(vc: UIViewController, parm: [String: Any], completion: @escaping(Bool) -> ()) {
        let url = API.Endpoints.patientLogin
        apiHelper.hitApi(view: vc, method: .post, parm: parm, url: url, isHeader: false, isLoader: true) { json, err in
            if err != nil {
                vc.displayAlert(title: "Alert!", msg: "Something went wrong", ok: "ok")
            } else {
                print(json)
                self.patientLoginModel = PatientLoginModel(json)
                if let model = self.patientLoginModel {
                    if model.success {
                        if let user = model.data {
                            UserDefaults.standard.setPatientLoginId(value: user.Id)
                            if let therapist = user.therapist {
                                UserDefaults.standard.setTherapistId(value: therapist.Id)
                                UserDefaults.standard.setTherapistProfileImage(value: therapist.profilePhoto)
                                UserDefaults.standard.setTherapistName(value: therapist.therapistName)
                                UserDefaults.standard.setPatientName(value: user.firstName + " " + user.lastName)
                            }
                            
                            SDWebImageManager.shared.loadImage(with: URL(string: model.data?.profilePhoto ?? ""), progress: nil) { img, data, err, cache, status, url in
                                if let img = img {
                                    if let imageData = img.pngData() {
                                        UserDefaults.standard.set(imageData, forKey: "profileImage")
                                    } else {
                                        print("Failed to convert UIImage to Data")
                                    }
                                    completion(true)
                                }
                            }
                        }
                    } else {
                        vc.displayAlert(title: "Alert!", msg: model.message, ok: "ok")
                    }
                }
            }
        }
    }
}
