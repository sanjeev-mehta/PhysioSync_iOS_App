//
//  AddNewExerciseViewModel.swift
//  PhysioSync
//
//  Created by Rohit on 2024-06-24.
//

import UIKit
import Alamofire

class AddNewExerciseViewModel {
    
    static let shareInstance = AddNewExerciseViewModel()
    let apiHelper = ApiHelper.shareInstance
    
    func addExerciseApi(vc: UIViewController,id: String = "" , isEdit: Bool ,parm: [String: Any], completion: @escaping (Bool) -> ()) {
        var url = ""
        var method: HTTPMethod?
        
        if isEdit {
            method = .put
            url = API.Endpoints.updateExercise + "/\(id)"
        } else {
            method = .post
            url = API.Endpoints.addNewExercise
        }
        
        apiHelper.hitApi(view: vc, method: method! , parm: parm, url: url, isHeader: true, isLoader: true) { json, err in
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
