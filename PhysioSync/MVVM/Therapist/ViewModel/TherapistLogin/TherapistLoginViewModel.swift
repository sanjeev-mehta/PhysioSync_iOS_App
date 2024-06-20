//
//  TherapistLoginViewModel.swift
//  PhysioSync
//
//  Created by Sanjeev Mehta on 22/05/24.
//

import UIKit

class TherapistLoginViewModel {
    
//    MARK: - Variables
    static let shareInstance = TherapistLoginViewModel()
    var therapistloginModel: TherapistLoginModel?
    let apiHelper = ApiHelper.shareInstance
    
    func callTherapistLoginApi(_ vc: UIViewController, with parm: [String: Any], completion: @escaping(Bool) -> ()) {
        let url = API.Endpoints.therapistLogin
        apiHelper.hitApi(view: vc, method: .post, parm: parm, url: url, isHeader: false, isLoader: true) { json, err in
            if err != nil {
                vc.displayAlert(title: "Alert!", msg: "Something went wrong", ok: "Ok")
            } else {
                vc.debugPrint("\(json)")
                self.therapistloginModel = TherapistLoginModel(json)
                if let model = self.therapistloginModel?.data {
                    UserDefaults.standard.setUsernameToken(value: model.authentication?.sessionToken ?? "")
                    completion(true)
                }
            }
        }
    }
}
