//
//  PatientExerciseTabTVC.swift
//  PhysioSync
//
//  Created by Sanjeev Mehta on 07/06/24.
//

import UIKit
import UIView_Shimmer

class PatientExerciseTabTVC: UITableViewCell, ShimmeringViewProtocol {
    
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var exerciseNameLbl: UILabel!
    @IBOutlet weak var repsCountLbl: UILabel!
    @IBOutlet weak var arrowImgView: UIImageView!
    
    var shimmeringAnimatedItems: [UIView] { [
        imgView,
        titleLbl,
        exerciseNameLbl,
        repsCountLbl,
        arrowImgView
    ]
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        bgView.addCornerRadius(radius: 12)
        imgView.addTopCornerRadius(radius: 12)
        bottomView.addBottomCornerRadius(radius: 12)
        bgView.layer.borderColor = UIColor.black.cgColor
        bgView.layer.borderWidth = 0.5
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}


class PatientExerciseTabTVC2: UITableViewCell {
    
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var bottomView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        bgView.addShadow(color: .blue, opacity: 1.0, offset: CGSize(width: 3, height: 3), radius: 12)
        bgView.layer.borderColor = UIColor.black.cgColor
        bgView.layer.borderWidth = 0.5
        bgView.addCornerRadius(radius: 12)
        imgView.addTopCornerRadius(radius: 12)
        bottomView.addBottomCornerRadius(radius: 12)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
