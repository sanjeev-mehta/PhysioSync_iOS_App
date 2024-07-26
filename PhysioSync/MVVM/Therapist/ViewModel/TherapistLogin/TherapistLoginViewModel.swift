//
//  TherapistLoginViewModel.swift
//  PhysioSync
//
//  Created by Sanjeev Mehta on 22/05/24.
//

import UIKit
import SDWebImage

class TherapistLoginViewModel {
    
    //    MARK: - Variables
    static let shareInstance = TherapistLoginViewModel()
    var therapistloginModel: TherapistLoginModel?
    let apiHelper = ApiHelper.shareInstance
    let firebaseHelper = FirebaseHelper.shared
    
    func callTherapistLoginApi(_ vc: UIViewController, with parm: [String: Any], completion: @escaping(Bool) -> ()) {
        let url = API.Endpoints.therapistLogin
        apiHelper.hitApi(view: vc, method: .post, parm: parm, url: url, isHeader: false, isLoader: true) { json, err in
            if err != nil {
                vc.displayAlert(title: "Alert!", msg: "Something went wrong", ok: "Ok")
            } else {
                vc.debugPrint("\(json)")
                self.therapistloginModel = TherapistLoginModel(json)
                if let model = self.therapistloginModel?.data {
                    if json["message"].stringValue == "User not found with these credentials in our database. Please create an account." {
                        vc.displayAlert(title: "Alert!", msg: json["message"].stringValue, ok: "Ok")
                        return
                    }
                    UserDefaults.standard.setUsernameToken(value: model.authentication!.sessionToken)
                    UserDefaults.standard.setTherapistId(value: model.Id)
                    UserDefaults.standard.setTherapistName(value: model.therapistName)
                    UserDefaults.standard.setTherapistProfileImage(value: model.profilePhoto)
                    UserDefaults.standard .set(json["token"]["Access_Key"].stringValue, forKey: "access_key")
                    UserDefaults.standard .set(json["token"]["Secret_access_key"].stringValue, forKey: "secret_key")
                    UserDefaults.standard.synchronize()
                    SDWebImageManager.shared.loadImage(with: URL(string: model.profilePhoto), progress: nil) { img, data, err, cache, status, url in
                        if let img = img {
                            if let imageData = img.pngData() {
                                UserDefaults.standard.set(imageData, forKey: "profileImage")
                            } else {
                                print("Failed to convert UIImage to Data")
                            }
                            completion(true)
                        }
                    }
                } else {
                    vc.displayAlert(title: "Alert!", msg: json["message"].stringValue, ok: "Ok")
                }
            }
        }
    }
    
    func checkAuthentication(vc: UIViewController, with parm: [String: Any], _ email: String, _ password: String, completion: @escaping(Bool) -> ()) {
        var av = UIView()
        av = Loader.start(view: vc.view)
        
        firebaseHelper.checkEmailAuthentication(email, password) { isVerified, status in
            if isVerified {
                av.removeFromSuperview()
                self.callTherapistLoginApi(vc, with: parm) { status in
                    completion(true)
                }
            } else {
                if let message = status {
                    // Show the illustration or an alert with the message
                    switch message {
                    case 0:
                        av.removeFromSuperview()
                        self.callTherapistLoginApi(vc, with: parm) { status in
                            completion(true)
                        }
                        break
                    case 1:
                        av.removeFromSuperview()
                        print("Email is not verified, verification email has been sent")
                        vc.displayAlert(title: "Alert!", msg: "We sent you a verification email.", ok: "Ok")
                        break
                    case 2:
                        av.removeFromSuperview()
                        print("this is an error")
                        vc.displayAlert(title: "Alert!", msg: "Something went wrong", ok: "Ok")
                        break
                    default:
                        av.removeFromSuperview()
                        print("this is default")
                        break
                    }
                }
            }
        }
    }
    
}
