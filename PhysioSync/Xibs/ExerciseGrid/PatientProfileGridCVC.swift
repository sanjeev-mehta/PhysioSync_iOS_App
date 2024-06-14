//
//  PatientProfileGridCVC.swift
//  PhysioSync
//
//  Created by Gurmeet Singh on 2024-06-10.
//

import UIKit
import UIView_Shimmer

class PatientProfileGridCVC: UICollectionViewCell, ShimmeringViewProtocol {

    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var nameLbl: UILabel!
    
    var shimmeringAnimatedItems: [UIView] {
        [imgView, nameLbl]
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
