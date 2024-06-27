//
//  NotificationTVC.swift
//  PhysioSync
//
//  Created by Gurmeet Singh on 2024-06-10.
//

import UIKit
import UIView_Shimmer

class NotificationTVC: UITableViewCell {

    @IBOutlet weak var watchVideoBtn: UIButton!
    @IBOutlet weak var daysLbl: UILabel!
    @IBOutlet weak var acknowledgeBtn: UIButton!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var msgLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
