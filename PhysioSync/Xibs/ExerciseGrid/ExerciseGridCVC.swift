//
//  ExerciseGridCVC.swift
//  PhysioSync
//
//  Created by Rohit on 2024-06-06.
//

import UIKit
import UIView_Shimmer

class ExerciseGridCVC: UICollectionViewCell, ShimmeringViewProtocol {

    @IBOutlet weak var imgVW: UIImageView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var selectedView: UIView!
    
    var shimmeringAnimatedItems: [UIView] { [
        imgVW,
        titleLbl
        ]
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        imgVW.image = UIImage(named: "placeholder")!
        imgVW.cornerRadius = 22
        imgVW.clipsToBounds = true
        imgVW.contentMode = .redraw
        titleLbl.text = "Wrist"
    }

}
