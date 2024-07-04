//
//  MessageTVC.swift
//  PhysioSync
//
//  Created by Gurmeet Singh on 2024-06-02.
//

import UIKit
import UIView_Shimmer

class MessageTVC: UITableViewCell, ShimmeringViewProtocol {

    // MARK: - Outlets
    @IBOutlet weak var badgeLbl: UILabel!
    @IBOutlet weak var profileImgView: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var msgLbl: UILabel!
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var onlineImgView: UIImageView!
    
    var shimmeringAnimatedItems: [UIView] {
        [profileImgView, nameLbl, msgLbl, timeLbl, onlineImgView]
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        badgeLbl.layer.cornerRadius = 11.5
        badgeLbl.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
