//
//  TherapistHomeVC.swift
//  PhysioSync
//
//  Created by Sanjeev Mehta on 14/06/24.
//

import UIKit
import CHIPageControl

class TherapistHomeVC: UIViewController {

    // MARK: -  IBOutlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var messageTableView: UITableView!
    @IBOutlet weak var patientListTableView: UITableView!
    @IBOutlet var shadowViews: [UIView]!
    @IBOutlet weak var pageControl: CHIPageControlChimayo!
    
    // MARK: -  Variables
    var cellCount = 6
    var currentIndex = 0
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        setTableViews()
    }
    
    func setUI() {
        for i in shadowViews {
            i.layer.cornerRadius = 12
            i.addShadow()
        }
        pageControl.numberOfPages = cellCount
        pageControl.set(progress: 0, animated: false)
    }
    
    func setTableViews() {
        messageTableView.delegate = self
        messageTableView.dataSource = self
        messageTableView.register(UINib(nibName: "MessageTVC", bundle: nil), forCellReuseIdentifier: "MessageCell")
        patientListTableView.delegate = self
        patientListTableView.dataSource = self
    }

}

// MARK: -  UICollection View Delegates and datasource methods

extension TherapistHomeVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 6
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TherapistHomeCVC", for: indexPath) as! TherapistHomeCVC
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: collectionView.bounds.width, height: 200)
        
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

extension TherapistHomeVC: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == collectionView {
            let pageIndex = round(scrollView.contentOffset.x / scrollView.frame.width)
            pageControl.set(progress: Int(pageIndex), animated: true)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == collectionView {
            currentIndex = Int(scrollView.contentOffset.x / scrollView.frame.size.width)
        }
    }
}

// MARK: -  Uitable View Delegates and data source methods

extension TherapistHomeVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == messageTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath) as! MessageTVC
            cell.selectionStyle = .none
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TherapistHomeTVC", for: indexPath) as! TherapistHomeTVC
            cell.selectionStyle = .none
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}
