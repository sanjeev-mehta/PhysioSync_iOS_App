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
    var exerciseAssign = [SingleExerciseModel]()
    var completedExercise = [SingleExerciseModel]()
    private let healthKitManager = HealthKitManager()
    var timer: Timer?
    var assignmentID = ""
    
    func getAssignExercise(_ vc: UIViewController, completion: @escaping(Bool) -> ()) {
        let userId = UserDefaults.standard.getPatientLoginId()
        let url = API.Endpoints.getAssignExercise + "/\(userId)"
        apiHelper.getApi(view: vc, url: url, isHeader: true, isLoader: false) { json, err in
            if err != nil {
                vc.displayAlert(title: "Alert!", msg: "Something went wrong", ok: "Ok")
            } else {
                print(json, "<<<======")
                self.model = PatientHomeModel(json)
                self.exerciseAssign.removeAll()
                self.completedExercise.removeAll()
                if let model = self.model {
                    if model.data?.exercise.count != 0 {
                        self.assignmentID = model.data?.exercise[0].Id ?? ""
                    }
                    
                    if model.success ?? false {
                        if model.data?.exercise.count != 0 {
                            for i in model.data!.exercise[0].exerciseIds {
                                if i.status == "assigned" {
                                    self.exerciseAssign.append(i)
                                } else {
                                    self.completedExercise.append(i)
                                }
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
        let userId = UserDefaults.standard.getPatientLoginId()
        let url = API.Endpoints.watchdata + "/\(userId)"
        timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { [self] _ in
            if !HealthKitManager.ishealthkitPermissionPermitted {
                return
            }
            
            let params: [String: Any] = [
                "calories": healthKitManager.formattedCalorieData,
                "heartRate": healthKitManager.formattedHeartRateData,
                "sleep": healthKitManager.formattedSleepData,
                "stepCount": healthKitManager.formattedStepCountData
            ]
           // print(params)
            apiHelper.hitApiwithoutloader(parm: params, url: url) { [self] json, err in
                if err != nil {
                    print(err?.localizedDescription)
                } else {
                    timer?.invalidate()
                    timer = nil
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
        var arr = [SingleExerciseModel]()
        if status == .assigned {
            arr = exerciseAssign
        } else {
            arr = completedExercise
        }
        
        cell.imgView.setImage(with: arr[index].video_thumbnail)
        let category = arr[index].categoryName.joined(separator: ", ")
        cell.titleLbl.text = category
        cell.exerciseNameLbl.text = arr[index].videoTitle
    }
    
    //PatientExerciseTabTVC
    func setUpTableCell(_ cell: PatientExerciseTabTVC, _ status: ExerciseStatus, _ index: Int) {
        var arr = [SingleExerciseModel]()
        if status == .assigned {
            arr = exerciseAssign
        } else {
            arr = completedExercise
        }
        
        cell.imgView.setImage(with: arr[index].video_thumbnail)
        let category = arr[index].categoryName.joined(separator: ", ")
        cell.titleLbl.text = category
        cell.exerciseNameLbl.text = arr[index].videoTitle
    }
}

enum ExerciseStatus {
    case assigned
    case completed
}
