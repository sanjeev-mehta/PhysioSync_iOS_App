//
//  TherapistPatientViewModel.swift
//  PhysioSync
//
//  Created by Gurmeet Singh on 2024-06-19.
//

import Foundation
import UIKit
import SDWebImage


class TherapistPatientViewModel {
    
    // MARK: - Variables
    static let shareInstance = TherapistPatientViewModel()
    let apiHelper = ApiHelper.shareInstance
    var therapistPatientModel: TherapistPatientModel?
    
    func getPatient(vc: UIViewController, completion: @escaping(Bool) -> ()) {
        let url = URLS.BASE_URL + END_POINTS.GET_All_PATIENTS
        apiHelper.getApi(view: vc, url: url, isHeader: true, isLoader: true) { json, err in
            if err != nil {
                vc.displayAlert(title: "Alert!", msg: "Something went wrong", ok: "Ok")
            } else {
                print(json)
                self.therapistPatientModel = TherapistPatientModel(json)
                guard let model = self.therapistPatientModel else { 
                    vc.displayAlert(title: "Alert", msg: "Something went wrong", ok: "Ok")
                    return }
                if model.success {
                    completion(true)
                } else {
                    completion(false)
                }
            }
        }
    }
    
    // MARK: - Logic
    func getCount() -> Int {
        if let model = self.therapistPatientModel?.data {
            return model.count
        } else {
            return 0
        }
    }
    
    // MARK: - Update Cell UI
    func updateCellUI(tableCell: TherapistPatientListTVC?, collectionCell: ProfileGridCVC?, index: Int) {
        if let data = self.therapistPatientModel?.data {
            if let tvc = tableCell {
                // Table View Cell
                tvc.imgView.sd_setImage(with: URL(string: data[index].profilePhoto))
                tvc.nameLbl.text = data[index].firstName + " " + data[index].lastName
            } else {
                // Collection View Cell
                if let cvc = collectionCell {
                    cvc.imgView.sd_setImage(with: URL(string: data[index].profilePhoto))
                    cvc.nameLbl.text = data[index].firstName + " " + data[index].lastName
                }
            }
        }
    }
    
    func passData(index: Int) -> TherapistPatientData {
        return self.therapistPatientModel!.data![index]
    }
}
