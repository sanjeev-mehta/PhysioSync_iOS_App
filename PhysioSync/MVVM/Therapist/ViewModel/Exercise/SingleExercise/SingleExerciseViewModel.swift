//
//  SingleExerciseViewModel.swift
//  PhysioSync
//
//  Created by Rohit on 2024-06-20.
//

import UIKit

class SingleExerciseViewModel {
    
    // MARK: -  Variables
    static let shareInstance = SingleExerciseViewModel()
    let apiHelper = ApiHelper.shareInstance
    var exerciseModel = [SingleExerciseModel]()
    
    func getSingleExercise(vc: UIViewController, name: String, completion: @escaping (Bool) -> ()) {
        let url = API.Endpoints.getAllExercises + "name=\(name)"
        apiHelper.getApi(view: vc, url: url, isHeader: true, isLoader: true) { json, err in
            if let error = err {
                completion(false)
            } else {
                let exercises = json["data"].arrayValue.map { SingleExerciseModel($0) }
                self.exerciseModel = exercises
                completion(true)
            }
        }
    }
    
    // MARK: - Get Array Count
    func getArrayCount() -> Int {
        return exerciseModel.count
    }
    
    func setCell(_ cell: ExerciseGridCVC, index: Int, isCreateSchedule: Bool = false) {
        let data = exerciseModel[index]
        cell.titleLbl.text = data.videoTitle
        cell.imgVW.setImage(with: data.video_thumbnail)
        cell.imgVW.contentMode = .scaleToFill
        if isCreateSchedule {
            if data.isSelected {
                cell.selectedView.isHidden = false
            } else {
                cell.selectedView.isHidden = true
            }
        } else {
            cell.selectedView.isHidden = true
        }
    }
}
