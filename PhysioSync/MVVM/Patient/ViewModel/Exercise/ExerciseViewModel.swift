//
//  ExerciseViewModel.swift
//  PhysioSync
//
//  Created by Sanjeev Mehta on 10/07/24.
//

import UIKit

class ExerciseViewModel {
    static let shareInstance = ExerciseViewModel()
    let apiHelper = ApiHelper.shareInstance
    
    func updateAssignExercise(_ vc: UIViewController, id: String, parm: [String: Any], completion: @escaping(Bool) -> ()) {
        //update-completed-status/
        let url = API.baseURL + "update-completed-status/" + "\(id)"
        apiHelper.hitApi(view: vc, method: .put, parm: parm, url: url, isHeader: false, isLoader: false) { json, err in
            if err != nil {
                vc.displayAlert(title: "Alert!", msg: "something went wrong", ok: "Ok")
            } else {
                print(json)
                completion(true)
            }
        }
        
    }
}
