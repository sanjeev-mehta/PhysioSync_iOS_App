//
//  SetPasswordViewModel.swift
//  PhysioSync
//
//  Created by Sanjeev Mehta on 21/06/24.
//

import UIKit

class SetPasswordViewModel {
    
    static let shareInstance = SetPasswordViewModel()
    let apiHelper = ApiHelper.shareInstance
    
    func callPatientLogin(vc: UIViewController, parm: [String: Any], completion: @escaping(Bool) -> ()) {
        let url = API.Endpoints.patientSetPassword
        apiHelper.hitApi(view: vc, method: .post, parm: parm, url: url, isHeader: false, isLoader: true) { json, err in
            if err != nil {
                vc.displayAlert(title: "Alert!", msg: "Something went wrong", ok: "ok")
            } else {
                print(json)
                if json["success"].boolValue {
                    completion(true)
                }
            }
        }
    }
}
