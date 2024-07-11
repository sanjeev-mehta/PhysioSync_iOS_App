//
//  PatientHomeCVC.swift
//  PhysioSync
//
//  Created by Sanjeev Mehta on 14/06/24.
//

import UIKit
import UIView_Shimmer

class PatientHomeCVC: UICollectionViewCell, ShimmeringViewProtocol {
    
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var exerciseNameLbl: UILabel!

    var shimmeringAnimatedItems: [UIView] {[
    imgView,
    bottomView,
    titleLbl,
    exerciseNameLbl
    ]}
}
