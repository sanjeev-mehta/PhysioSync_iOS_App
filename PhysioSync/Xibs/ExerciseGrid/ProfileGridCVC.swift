//
//  ProfileGridCVC.swift
//  PhysioSync
//
//  Created by Sanjeev Mehta on 13/06/24.
//

import UIKit
import UIView_Shimmer

class ProfileGridCVC: UICollectionViewCell, ShimmeringViewProtocol {
    
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var nameLbl: UILabel!
    
    var shimmeringAnimatedItems: [UIView] {
        [bgView, imgView, nameLbl]
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        imgView.image = UIImage(named: "patient")!
        

    }
    
}
