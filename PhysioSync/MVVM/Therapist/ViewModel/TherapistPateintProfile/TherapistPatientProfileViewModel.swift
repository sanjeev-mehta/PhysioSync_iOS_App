//
//  TherapistPatientProfileViewModel.swift
//  PhysioSync
//
//  Created by Gurmeet Singh on 2024-06-19.
//

import Foundation
import UIKit
import SDWebImage

class TherapistPatientProfileViewModel{
    
    // MARK: - Variables
    static let shareInstance = TherapistPatientProfileViewModel()
    let apiHelper = ApiHelper.shareInstance
    var therapistPatientprofileModel: [TherapistPatientProfileModel]?
    
    func getAssignedExercise(vc: UIViewController,patientId: String, completion: @escaping(Bool) -> ()){
        let url = API.Endpoints.getAssignExercise + "/" + patientId
        apiHelper.getApi(view: vc, url: url, isHeader: true, isLoader: true) { json, err in
            if err != nil {
                vc.displayAlert(title: "Alert!", msg: "Something went wrong", ok: "Ok")
            } else {
                vc.debugPrint("\(json)")
                self.therapistPatientprofileModel = [TherapistPatientProfileModel(json)]
                if self.therapistPatientprofileModel?.count == 0 {
                    // No data
                } else {
                    completion(true)
                }
//                print(json)
            }
        }
    }
    
    func getCount() -> Int {
        if let data = therapistPatientprofileModel?[0].data {
            if data.exercise?.count != 0 {
                return data.exercise?[0].exerciseIds.count ?? 0
            } else {
                return 0
            }
        } else {
            return 0
        }
    }
    
}
