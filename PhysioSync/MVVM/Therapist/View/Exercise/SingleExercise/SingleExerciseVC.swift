//
//  SingleExerciseVideoVC.swift
//  PhysioSync
//
//  Created by Rohit on 2024-06-13.
//

import UIKit

class SingleExerciseVC: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: -  Variables
    private var isLoading = true {
        didSet {
            collectionView.isUserInteractionEnabled = !isLoading
            collectionView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setCollectionView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            self.isLoading = false
        }
    }
    
    func setCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "ExerciseGridCVC", bundle: nil), forCellWithReuseIdentifier: "SingleExerciseGridCVC")
    }
    
}

extension SingleExerciseVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 6
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SingleExerciseGridCVC", for: indexPath) as! ExerciseGridCVC
        cell.imgVW.backgroundColor = .blue
        cell.imgVW.layer.cornerRadius = 12
        cell.imgVW.layer.masksToBounds = true
        cell.imgVW.addShadow()
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: collectionView.bounds.width/2, height: 200)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
        
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        // MARK: - Initial state for the animation
        cell.setTemplateWithSubviews(isLoading, animate: true, viewBackgroundColor: .systemBackground)
        cell.alpha = 0
        
        // MARK: -  Apply animation
        UIView.animate(withDuration: 0.5) {
            cell.alpha = 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // MARK: - Switch Controllers on tap
    }

}
