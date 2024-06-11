//
//  ExerciseCategoryVC.swift
//  PhysioSync
//
//  Created by Rohit on 2024-06-06.
//

import UIKit

class ExerciseCategoryVC: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setCollectionView()
    }
    
    func setCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "ExerciseGridCVC", bundle: nil), forCellWithReuseIdentifier: "ExerciseGridCVC")
    }
    
}

extension ExerciseCategoryVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 6
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ExerciseGridCVC", for: indexPath) as! ExerciseGridCVC
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // MARK: - Switch Controllers on tap
    }
    
}
