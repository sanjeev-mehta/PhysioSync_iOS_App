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
    var header = "Neck"
    let vm = SingleExerciseViewModel.shareInstance
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setCollectionView()
        callGetExerciseApi()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setHeader(header,rightImg: UIImage(named: "addIcon")!, isRightBtn: true) {
            self.dismissOrPopViewController()
        } rightButtonAction: {
            self.openAddExerciseController()
        }
    }
    
    // MARK: - Methods
    
    func callGetExerciseApi() {
        vm.getSingleExercise(vc: self, name: header) { status in
            self.isLoading = false
        }
    }
    func openAddExerciseController() {
        if let vc = self.switchController(.addNewExerciseVC, .exerciseTab) as? AddNewExerciseVC {
            self.pushOrPresentViewController(vc, true)
        }
    }
    
    func openExerciseDetailController(_ data: SingleExerciseModel) {
        if let vc = self.switchController(.singleExerciseDetailVC, .exerciseTab) as? SingleExerciseDetailVC {
            self.pushOrPresentViewController(vc, true)
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
        if self.isLoading {
            return 10
        } else {
            return vm.getArrayCount()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SingleExerciseGridCVC", for: indexPath) as! ExerciseGridCVC
        if !self.isLoading {
            vm.setCell(cell, index: indexPath.item)
        }
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
        if let cell = collectionView.cellForItem(at: indexPath) {
            cell.pressedAnimation {
                let data = self.vm.exerciseModel[indexPath.item]
                self.openExerciseDetailController(data)
            }
        }
    }
    
   

}
