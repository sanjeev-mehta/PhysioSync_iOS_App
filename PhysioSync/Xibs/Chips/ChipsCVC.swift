//
//  ChipsCVC.swift
//  PhysioSync
//
//  Created by Rohit on 2024-06-13.
//

import UIKit

class ChipsCVC: UICollectionViewCell {

    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var checkMarkImgView: UIImageView!
    @IBOutlet weak var checkMarkImgViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var checkMarkImgViewTrailingConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
