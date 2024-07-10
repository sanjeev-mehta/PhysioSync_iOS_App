//
//  PatientHomeViewModel.swift
//  PhysioSync
//
//  Created by Sanjeev Mehta on 27/06/24.
//

import UIKit

class PatientHomeViewModel {
    
    static let shareInstance = PatientHomeViewModel()
    let apiHelper = ApiHelper.shareInstance
    var model: PatientHomeModel?
    var exerciseAssign = [Exercise]()
    var completedExercise = [Exercise]()
    private let healthKitManager = HealthKitManager()
    var timer: Timer?
    
    func getAssignExercise(_ vc: UIViewController, completion: @escaping(Bool) -> ()) {
        let userId = UserDefaults.standard.getPatientLoginId()
        let url = API.Endpoints.getAssignExercise + "/\(userId)"
        apiHelper.getApi(view: vc, url: url, isHeader: true, isLoader: true) { json, err in
            if err != nil {
                vc.displayAlert(title: "Alert!", msg: "Something went wrong", ok: "Ok")
            } else {
                print(json, "<<<======")
                self.model = PatientHomeModel(json)
                self.exerciseAssign.removeAll()
                self.completedExercise.removeAll()
                if let model = self.model {
                    if model.success ?? false {
                        for i in model.data!.exercise {
                            if i.status == "assigned" {
                                self.exerciseAssign.append(i)
                            } else {
                                self.completedExercise.append(i)
                            }
                        }
                        completion(true)
                    } else {
                        vc.displayAlert(title: "Alert!", msg: model.message, ok: "Ok")
                    }
                } else {
                    vc.displayAlert(title: "Alert!", msg: "Something went wrong", ok: "Ok")
                }
            }
        }
    }
    
    func submitWatchData() {
        let url = API.Endpoints.watchdata
        let userId = UserDefaults.standard.getPatientLoginId()
         timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { [self] _ in
            if !HealthKitManager.ishealthkitPermissionPermitted {
                return
            }
            
            let params: [String: Any] = [
                "patient_id": userId,
                "calories": healthKitManager.formattedCalorieData,
                "heartRate": healthKitManager.formattedHeartRateData,
                "sleep": healthKitManager.formattedSleepData,
                "stepCount": healthKitManager.formattedStepCountData
            ]
             apiHelper.hitApiwithoutloader(parm: params, url: url) { [self] json, err in
                if err != nil {
                    print(err?.localizedDescription)
                } else {
                    timer?.invalidate()
                    print("Submitted Apple Watch Data")
                }
            }
        }
    }
    
    func assignExerciseCount(_ status: ExerciseStatus) -> Int {
        if status == .assigned {
            return exerciseAssign.count
        } else {
            return completedExercise.count
        }
    }
    
    func setUpCell(_ cell: PatientHomeCVC, _ status: ExerciseStatus, _ index: Int) {
        var arr = [Exercise]()
        if status == .assigned {
            arr = exerciseAssign
        } else {
            arr = completedExercise
        }
        
        if !arr[index].exerciseIds.isEmpty {
            cell.imgView.setImage(with: arr[index].exerciseIds[0].video_thumbnail)
            let category = arr[index].exerciseIds[0].categoryName.joined(separator: ", ")
            cell.titleLbl.text = category
            cell.exerciseNameLbl.text = arr[index].exerciseIds[0].videoTitle
        }
    }
    
    //PatientExerciseTabTVC
    func setUpTableCell(_ cell: PatientExerciseTabTVC, _ status: ExerciseStatus, _ index: Int) {
        var arr = [Exercise]()
        if status == .assigned {
            arr = exerciseAssign
        } else {
            arr = completedExercise
        }
        
        if !arr[index].exerciseIds.isEmpty {
            cell.imgView.setImage(with: arr[index].exerciseIds[0].video_thumbnail)
            let category = arr[index].exerciseIds[0].categoryName.joined(separator: ", ")
            cell.titleLbl.text = category
            cell.exerciseNameLbl.text = arr[index].exerciseIds[0].videoTitle
        }
    }
}

enum ExerciseStatus {
    case assigned
    case completed
}
