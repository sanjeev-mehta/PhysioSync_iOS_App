//
//  ExerciseCategoryViewModel.swift
//  PhysioSync
//
//  Created by Rohit on 2024-06-20.
//

import Foundation
import UIKit

class ExerciseCategoryViewModel {
    static let shareInstance = ExerciseCategoryViewModel()
    let apiHelper = ApiHelper.shareInstance
    var categoriesModel = [ExerciseCatergoryModel]()
    
    func getAllCategories(vc: UIViewController, completion: @escaping (Bool) -> ()) {
        let url = API.Endpoints.getAllcategories
        apiHelper.getApi(view: vc, url: url, isHeader: true, isLoader: true) { json, err in
            if let error = err {
                completion(false)
            } else {
                let categories = json["data"].arrayValue.map { ExerciseCatergoryModel($0) }
                self.categoriesModel = categories
                completion(true)
            }
        }
    }
    
    // MARK: - Get Array Count
    func getArrayCount() -> Int {
        return categoriesModel.count
    }
    
    func setCell(_ cell: ExerciseGridCVC, index: Int) {
        let data = categoriesModel[index]
        cell.titleLbl.text = data.name?.capitalized
        cell.imgVW.image = UIImage(named: data.name?.lowercased() ?? "")
    }
    
    // MARK: - Delete Exercise
    func deleteExercises(vc: UIViewController, id: String, completion: @escaping (Bool) -> ()) {
        let url = API.Endpoints.delete_exercise + "/\(id)"
        apiHelper.hitApi(view: vc, method: .delete, parm: [:], url: url, isHeader: true, isLoader: true) { json, err in
            if err != nil {
                vc.displayAlert(title: "Alert!", msg: "Something went wrong", ok:"Ok")
            } else {
                completion(true)
            }
        }
    }
    
    func getExerciseDetail(vc: UIViewController, completion: @escaping (Bool) -> ()) {
        let url = API.Endpoints.getAllcategories
        apiHelper.getApi(view: vc, url: url, isHeader: true, isLoader: true) { json, err in
            if let error = err {
                completion(false)
            } else {
                let categories = json["data"].arrayValue.map { ExerciseCatergoryModel($0) }
                self.categoriesModel = categories
                completion(true)
            }
        }
    }
}
