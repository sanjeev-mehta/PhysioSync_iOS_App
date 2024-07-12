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
        let url = API.Endpoints.updateAssignExercise + "\(id)"
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
            let data = model.data[index]
            cell.daysLbl.text = data.days
            vc.getThumbnailImageFromVideoUrl(url: URL(string: data.patientVideoUrl)!) { image in
                cell.imgView.image = image
            }
        }
    }
    
    func getCount() -> Int {
        return notificationModel?.data.count ?? 0
    }
    
}
