//
//  PatientOnboardingVC.swift
//  PhysioSync
//
//  Created by Sanjeev Mehta on 22/05/24.
//

import UIKit
import NVActivityIndicatorView

class Loader{
    
    public static func start(view:UIView) -> UIView {
        
        let bgView = UIView()
        bgView.frame = view.frame
        bgView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.6)
        let activityIndicator = NVActivityIndicatorView(frame: CGRect(x: 0, y:0, width: 80, height: 80), type: .ballClipRotateMultiple, color:  .white, padding: NVActivityIndicatorView.DEFAULT_PADDING)
       activityIndicator.center.x = bgView.center.x
        activityIndicator.center.y = bgView.center.y
        view.addSubview(bgView)
        bgView.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        return bgView
    }
}


