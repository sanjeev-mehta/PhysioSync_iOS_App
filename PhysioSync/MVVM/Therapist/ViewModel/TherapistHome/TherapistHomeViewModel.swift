//
//  TherapistHomeViewModel.swift
//  PhysioSync
//
//  Created by Sanjeev Mehta on 24/06/24.
//

import UIKit

class TherapistHomeViewModel {
    
    static let shareInstance = TherapistHomeViewModel()
    let apiHelper = ApiHelper.shareInstance
    var notificationModel: TherapistNotificationModel?
    
    func getNotificationApi(vc: UIViewController, completion: @escaping (Bool) -> ()) {
        let url = API.Endpoints.getTherapistNotification
        apiHelper.getApi(view: vc, url: url, isHeader: true, isLoader: false) { json, err in
            if err != nil {
                vc.displayAlert(title: "Alert!", msg: "something went wrong", ok: "Ok")
            } else {
                print(json)
                self.notificationModel = TherapistNotificationModel(json)
                if let model = self.notificationModel {
                    if model.success {
                        completion(true)
                    } else {
                        vc.displayAlert(title: "Alert!", msg: model.message, ok: "Ok")
                    }
                } else {
                    vc.displayAlert(title: "Alert!", msg: "something went wrong", ok: "Ok")
                }
                
            }
        }
    }
    
    func acknowledgeExercise(vc: UIViewController, id: String,parm: [String: Any], completion: @escaping (Bool) -> ()) {
        let url = API.baseURL + "update-completed-status/" + "\(id)"
        apiHelper.hitApi(view: vc, method: .put, parm: parm, url: url, isHeader: true, isLoader: true) { json, err in
            if err != nil {
                vc.displayAlert(title: "Alert!", msg: "something went wrong", ok: "Ok")
            } else {
                if json["success"].boolValue {
                    completion(true)
                } else {
                    vc.displayAlert(title: "Alert!", msg: json["message"].stringValue, ok: "Ok")
                }
            }
        }
    }
    
    func setCollectionCell(_ cell: TherapistHomeCVC, _ index: Int, vc: UIViewController) {
        if let model = self.notificationModel {
            let data = model.data[0].exerciseIds[index]
            cell.daysLbl.text = "Today"
            if let url = URL(string: data.patient_video_url) {
                vc.getThumbnailImageFromVideoUrl(url: url) { image in
                    cell.imgView.image = image
                }
            }
            cell.profileImgView.setImage(with: model.data[0].patientId.profilePhoto)
        }
    }
    
    func getCount() -> Int {
        if notificationModel?.data.count != 0 {
            return notificationModel?.data[0].exerciseIds.count ?? 0
        } else {
            return 0
        }
        
    }
    
}
