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
    var filteredPatients: [TherapistPatientData] = [] // Filtered data for search

    
    func getPatient(vc: UIViewController, completion: @escaping(Bool) -> ()) {
        let url = API.Endpoints.getAllPatients
        apiHelper.getApi(view: vc, url: url, isHeader: true, isLoader: false) { json, err in
            if err != nil {
                vc.displayAlert(title: "Alert!", msg: "Something went wrong", ok: "Ok")
            } else {
                self.therapistPatientModel = TherapistPatientModel(json)
                guard let model = self.therapistPatientModel else { 
                    vc.displayAlert(title: "Alert", msg: "Something went wrong", ok: "Ok")
                    return }
                if model.success {
                    self.filteredPatients = model.data ?? []
                    completion(true)
                } else {
                    completion(false)
                }
            }
        }
    }
    
    // MARK: - Logic
//    func getCount() -> Int {
//        if let model = self.therapistPatientModel?.data {
//            return model.count
//        } else {
//            return 0
//        }
//    }
    
    func getCount() -> Int {
            return filteredPatients.count
        }
    
    // MARK: - Update Cell UI
    func updateCellUI(tableCell: TherapistPatientListTVC?, collectionCell: ProfileGridCVC?, index: Int) {
        let data = filteredPatients
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
    
//    func passData(index: Int) -> TherapistPatientData {
//        return self.therapistPatientModel!.data![index]
//    }
    
    func passData(index: Int) -> TherapistPatientData {
        return filteredPatients[index]
    }
    
    // MARK: - Search Logic
    func searchPatients(query: String) {
            guard let allPatients = therapistPatientModel?.data else { return }
            if query.isEmpty {
                filteredPatients = allPatients
            } else {
                filteredPatients = allPatients.filter { patient in
                    return patient.firstName.lowercased().contains(query.lowercased())
                }
                // Print each patient's properties
                    for patient in filteredPatients {
                        print("First Name: \(patient.firstName)")
                    }
            }
        }
    
}
