//
//  TherapistHomeTVC.swift
//  PhysioSync
//
//  Created by Sanjeev Mehta on 14/06/24.
//

import UIKit
import UIView_Shimmer

class TherapistHomeTVC: UITableViewCell, ShimmeringViewProtocol {

    @IBOutlet weak var imgVW: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var onlineImgView: UIImageView!
    
    var shimmeringAnimatedItems: [UIView] {
        [imgVW, nameLbl, onlineImgView]
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
