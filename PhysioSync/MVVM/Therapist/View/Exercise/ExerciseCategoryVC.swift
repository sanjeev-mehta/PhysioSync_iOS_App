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
    
    // MARK: -  Variables
    private var isLoading = true {
        didSet {
            collectionView.isUserInteractionEnabled = !isLoading
            collectionView.reloadData()
        }
    }
    
    let exerciseCategoryViewModel = ExerciseCategoryViewModel.shareInstance
    var isCreateSchedule = false
    var delegate: SelectedExerciseData?
    var selectedData = [SingleExerciseModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setCollectionView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isCreateSchedule {
            self.setHeader("Exercise Library", isBackBtn: true) {
                self.dismissOrPopViewController()
            } rightButtonAction: {}
        } else {
            self.setHeader("Exercise Library", isBackBtn: false)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.getExerciseCategoryApi()
    }
    
    // MARK: -  Call Get Exercise Category Api
    func getExerciseCategoryApi()  {
        exerciseCategoryViewModel.getAllCategories(vc: self) { status in
            self.isLoading = false
        }
    }
    
    // MARK: - Set Collection View
    func setCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "ExerciseGridCVC", bundle: nil), forCellWithReuseIdentifier: "SingleExerciseGridCVC")
    }
    
    func openSingleExerciseController(name: String) {
        if let vc = self.switchController(.singleExerciseVC, .exerciseTab) as? SingleExerciseVC {
            vc.header = name
            vc.isCreateSchedule = isCreateSchedule
            vc.delegate = self
            vc.selectedData = selectedData
            self.pushOrPresentViewController(vc, true)
        }
    }
    
}

// MARK: - Collection View Delegates and Data Source Methods
extension ExerciseCategoryVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.isLoading {
            return 10
        } else {
            return exerciseCategoryViewModel.getArrayCount()
        }
       
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SingleExerciseGridCVC", for: indexPath) as! ExerciseGridCVC
        if !self.isLoading {
            exerciseCategoryViewModel.setCell(cell, index: indexPath.item)
        }
        cell.selectedView.isHidden = true
        cell.imgVW.backgroundColor = Colors.primarySubtleClr
        cell.imgVW.layer.cornerRadius = 12
        cell.imgVW.layer.masksToBounds = true
        cell.imgVW.contentMode = .scaleAspectFit
//        cell.imgVW.addShadow()
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
        cell.setTemplateWithSubviews(isLoading, color: Colors.primaryClr, animate: true, viewBackgroundColor: Colors.darkGray)
        cell.alpha = 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // MARK: - Switch Controllers on tap
        if let cell = collectionView.cellForItem(at: indexPath) {
            cell.pressedAnimation {
                let data = self.exerciseCategoryViewModel.categoriesModel[indexPath.item]
                self.openSingleExerciseController(name: data.name ?? "")
            }
        }
        
    }

}

extension ExerciseCategoryVC: SelectedExerciseData {
    func selectedExerciseData(data: [SingleExerciseModel]) {
        delegate?.selectedExerciseData(data: data)
    }
    
}
