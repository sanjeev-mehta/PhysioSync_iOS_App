//
//  AnimatedTabBarController.swift
//  PhysioSync
//
//  Created by Sanjeev Mehta on 14/07/24.
//

import UIKit
import RAMAnimatedTabBarController

class AnimatedTabBarController: RAMAnimatedTabBarController, UITabBarControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
        
        if let items = tabBar.items as? [CustomTabBarItem] {
            for item in items {
                item.updateImage(isSelected: false)
            }
        }
        
        // Update the selected item
        if let selectedItem = tabBar.selectedItem as? CustomTabBarItem {
            selectedItem.updateImage(isSelected: true)
        }
    }
    
    // UITabBarControllerDelegate method
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if let items = tabBar.items as? [CustomTabBarItem] {
            for customItem in items {
                customItem.updateImage(isSelected: customItem == tabBar.selectedItem)
            }
        }
    }
    
    func setProfileImage(_ profileImage: UIImage) {
        if let items = tabBar.items as? [CustomTabBarItem] {
            for item in items {
                if item.selectedImageName == "profile" {
                    item.updateProfileImage(profileImage)
                    item.updateImage(isSelected: item == tabBar.selectedItem)
                    break
                }
            }
        }
    }
}

class CustomTabBarItem: RAMAnimatedTabBarItem {
    @IBInspectable var selectedImageName: String?
    @IBInspectable var unselectedImageName: String?
    @IBInspectable var iconWidth: CGFloat = 25
    @IBInspectable var iconHeight: CGFloat = 25

    private var profileImage: UIImage?

    override func awakeFromNib() {
        super.awakeFromNib()
        setAnimation()
        updateImage(isSelected: false)
    }

    func updateImage(isSelected: Bool) {
        let image: UIImage?
        if let profileImage = profileImage {
            image = profileImage
            makeIconCircular()
        } else {
            image = isSelected ? UIImage(named: selectedImageName ?? "") : UIImage(named: unselectedImageName ?? "")
        }
        
        self.iconView?.icon.image = image
        resizeIcon()
    }

    func updateProfileImage(_ profileImage: UIImage) {
        self.profileImage = profileImage
        updateImage(isSelected: false)
    }

    private func setAnimation() {
        let animation = RAMBounceAnimation()
        animation.iconSelectedColor = Colors.primaryClr
        animation.textSelectedColor = Colors.primaryClr
        self.animation = animation
    }

    private func resizeIcon() {
        guard let iconImageView = self.iconView?.icon else { return }
        iconImageView.frame.size = CGSize(width: iconWidth, height: iconHeight)
    }
    
    private func makeIconCircular() {
        guard let iconImageView = self.iconView?.icon else { return }
        iconImageView.layer.cornerRadius = 8
        iconImageView.clipsToBounds = true
    }
}
