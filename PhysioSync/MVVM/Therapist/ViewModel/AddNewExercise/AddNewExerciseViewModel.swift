//
//  AddNewExerciseViewModel.swift
//  PhysioSync
//
//  Created by Rohit on 2024-06-24.
//

import UIKit

class AddNewExerciseViewModel {
    
    static let shareInstance = AddNewExerciseViewModel()
    let apiHelper = ApiHelper.shareInstance
    
    func addExerciseApi(vc: UIViewController, parm: [String: Any], completion: @escaping (Bool) -> ()) {
        let url = API.Endpoints.addNewExercise
        apiHelper.hitApi(view: vc, method: .post, parm: parm, url: url, isHeader: true, isLoader: true) { json, err in
            if err != nil {
                vc.displayAlert(title: "Alert!", msg: "something went wrong", ok: "Ok")
            } else {
                print(json)
            }
        }
    }
    
}
