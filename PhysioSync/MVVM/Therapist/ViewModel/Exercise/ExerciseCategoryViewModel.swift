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
        cell.titleLbl.text = data.name
        cell.imgVW.setImage(with: data.imageLink)
    }
}
