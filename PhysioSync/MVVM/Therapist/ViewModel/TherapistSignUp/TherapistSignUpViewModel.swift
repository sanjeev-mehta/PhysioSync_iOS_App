//
//  TherapistSignUpViewModel.swift
//  PhysioSync
//
//  Created by Rohit on 2024-07-11.
//

import UIKit

class TherapistSignUpViewModel {
    
    static let shareInstance = TherapistSignUpViewModel()
    let apiHelper = ApiHelper.shareInstance
    
    func singUpApi(vc: UIViewController, parm: [String: Any], completion: @escaping (Bool) -> ()) {
        let url = API.Endpoints.therapistRegister
        apiHelper.hitApi(view: vc, method: .post, parm: parm, url: url, isHeader: false, isLoader: true) { json, err in
            if err != nil {
                vc.displayAlert(title: "Alert!", msg: "something went wrong", ok: "Ok")
            } else {
                print(json)
                if json["success"].boolValue {
                    completion(true)
                } else {
                    vc.displayAlert(title: "Alert!", msg: json["message"].stringValue, ok: "Ok")
                }
            }
        }
    }
}
