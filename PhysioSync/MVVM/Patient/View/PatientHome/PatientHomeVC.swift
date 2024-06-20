//
//  PatientHomeVC.swift
//  PhysioSync
//
//  Created by Sanjeev Mehta on 14/06/24.
//

import UIKit
import CHIPageControl

class PatientHomeVC: UIViewController {

    // MARK: -  IBOutlets
    @IBOutlet weak var sessionCollectionView: UICollectionView!
    @IBOutlet weak var completedCollectionView: UICollectionView!
    @IBOutlet var messageViewConstraints: [NSLayoutConstraint]!
    @IBOutlet weak var sessionPageControl: CHIPageControlJaloro!
    @IBOutlet weak var completedPageControl: CHIPageControlJaloro!
    @IBOutlet weak var messageView: UIView!
    
    // MARK: -  Variable
    var cellCount = 4
    var sessionCurrentIndex = 0
    var completedCurrentIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUI()
    }
    
    func setUI() {
        sessionCollectionView.delegate = self
        sessionCollectionView.dataSource = self
        completedCollectionView.delegate = self
        completedCollectionView.dataSource = self
        sessionPageControl.numberOfPages = cellCount
        sessionPageControl.set(progress: 0, animated: false)
        completedPageControl.numberOfPages = cellCount
        completedPageControl.set(progress: 0, animated: false)
        messageView.addShadow()
    }
    
    func hideMessageView() {
        for i in messageViewConstraints {
            i.constant = 0
        }
        self.messageView.isHidden = true
    }

}

// MARK: -  UICollection View Delegates and datasource methods

extension PatientHomeVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cellCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == sessionCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PatientHomeCVC1", for: indexPath) as! PatientHomeCVC
            cell.imgView.addTopCornerRadius(radius: 16)
            cell.bottomView.addBottomCornerRadius(radius: 16)
            cell.bgView.layer.cornerRadius = 16
            cell.bgView.addShadow()
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PatientHomeCVC2", for: indexPath) as! PatientHomeCVC
            cell.imgView.addTopCornerRadius(radius: 16)
            cell.bottomView.addBottomCornerRadius(radius: 16)
            cell.bgView.layer.cornerRadius = 16
            cell.bgView.addShadow()
            return cell
        }
       
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: collectionView.bounds.width, height: 260)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
        
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        //        cell.setTemplateWithSubviews(isLoading, animate: true, viewBackgroundColor: .systemBackground)
        cell.alpha = 0
        cell.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        
        // Apply animation
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: {
            cell.alpha = 1
            cell.transform = CGAffineTransform(scaleX: 1, y: 1)
        }, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // MARK: - Switch Controllers on tap
        
    }
    
}

// MARK: - UIScrollViewDelegate

extension PatientHomeVC: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == sessionCollectionView {
            let pageIndex = round(scrollView.contentOffset.x / scrollView.frame.width)
            sessionPageControl.set(progress: Int(pageIndex), animated: true)
        }
        
        if scrollView == completedCollectionView {
            let pageIndex = round(scrollView.contentOffset.x / scrollView.frame.width)
            completedPageControl.set(progress: Int(pageIndex), animated: true)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == sessionCollectionView {
            sessionCurrentIndex = Int(scrollView.contentOffset.x / scrollView.frame.size.width)
        }
        
        if scrollView == completedCollectionView {
            completedCurrentIndex = Int(scrollView.contentOffset.x / scrollView.frame.size.width)
        }
    }
}
