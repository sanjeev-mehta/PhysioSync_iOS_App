//
//  PatientLoginViewModel.swift
//  PhysioSync
//
//  Created by Sanjeev Mehta on 20/06/24.
//

import UIKit

class PatientLoginViewModel {
    
    static let shareInstance = PatientLoginViewModel()
    let apiHelper = ApiHelper.shareInstance
    
    func callVerifyEmail(vc: UIViewController, completion: @escaping(Bool) -> ()) {
        
    }
}
