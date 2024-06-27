//
//  CreateScheduleViewModel.swift
//  PhysioSync
//
//  Created by Sanjeev Mehta on 24/06/24.
//

import UIKit


class CreateScheduleViewModel {
    static let shareInstance = CreateScheduleViewModel()
    let apiHelper = ApiHelper.shareInstance
    
    func callTherapistLoginApi(_ vc: UIViewController, with parm: [String: Any], completion: @escaping(Bool) -> ()) {
        let url = API.Endpoints.addAssignExercise
        apiHelper.hitApi(view: vc, method: .post, parm: parm, url: url, isHeader: true, isLoader: true) { json, err in
            if err != nil {
                vc.displayAlert(title: "Alert!", msg: "Something went wrong", ok: "Ok")
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
