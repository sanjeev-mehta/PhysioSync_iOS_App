//
//  TherapistPatientListTVC.swift
//  PhysioSync
//
//  Created by Gurmeet Singh on 2024-06-10.
//


import UIKit
import UIView_Shimmer

class TherapistPatientListTVC: UITableViewCell, ShimmeringViewProtocol {

    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    
    var shimmeringAnimatedItems: [UIView] {
        [imgView, nameLbl]
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
