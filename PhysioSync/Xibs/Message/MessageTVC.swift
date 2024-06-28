//
//  MessageTVC.swift
//  PhysioSync
//
//  Created by Gurmeet Singh on 2024-06-02.
//

import UIKit

class MessageTVC: UITableViewCell {

    // MARK: - Outlets
    @IBOutlet weak var badgeLbl: UILabel!
    @IBOutlet weak var profileImgView: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var msgLbl: UILabel!
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var onlineImgView: UIImageView!
    
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
