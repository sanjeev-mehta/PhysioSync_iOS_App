//
//  TherapistHomeCVC.swift
//  PhysioSync
//
//  Created by Sanjeev Mehta on 14/06/24.
//

import UIKit
import UIView_Shimmer

class TherapistHomeCVC: UICollectionViewCell, ShimmeringViewProtocol {
    
    @IBOutlet weak var daysLbl: UILabel!
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var acknowledgeBtn: UIButton!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var profileImgView: UIImageView!
    @IBOutlet weak var pendingReviewLbl: UILabel!
    
    var shimmeringAnimatedItems: [UIView] {[
        daysLbl, acknowledgeBtn, imgView, profileImgView, pendingReviewLbl]}
}
