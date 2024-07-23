//
//  SingleExerciseVideoVC.swift
//  PhysioSync
//
//  Created by Rohit on 2024-06-13.
//

import UIKit
import FTPopOverMenu_Swift

class SingleExerciseVC: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var addExerciseBtn: UIButton!
    
    // MARK: -  Variables
    private var isLoading = true {
        didSet {
            collectionView.isUserInteractionEnabled = !isLoading
            collectionView.reloadData()
        }
    }
    var header = "Neck"
    let vm = SingleExerciseViewModel.shareInstance
    var isCreateSchedule = false
    var delegate: SelectedExerciseData?
    var selectedData = [SingleExerciseModel2]()
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setCollectionView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isCreateSchedule {
            self.setHeader(header, isBackBtn: true) {
                self.dismissOrPopViewController()
            } rightButtonAction: {}
            collectionViewBottomConstraint.constant = 150
            addExerciseBtn.isHidden = false
        } else {
            self.setHeader(header, isRightBtn: false) {
                self.dismissOrPopViewController()
            } rightButtonAction: {}
        }
        callGetExerciseApi()
    }
    
    func callGetExerciseApi() {
        vm.getSingleExercise(vc: self, name: header) { status in
            for i in self.vm.exerciseModel {
                for v in self.selectedData {
                    if i.id == v.id {
                        i.isSelected = true
                    }
                }
            }
            self.isLoading = false
        }
    }
    func openAddExerciseController() {
        if let vc = self.switchController(.addNewExerciseVC, .exerciseTab) as? AddNewExerciseVC {
            self.pushOrPresentViewController(vc, true)
        }
    }
    
    func openExerciseDetailController(_ data: SingleExerciseModel2) {
        if let vc = self.switchController(.singleExerciseDetailVC, .exerciseTab) as? SingleExerciseDetailVC {
            vc.data = data
            vc.name = header
            self.pushOrPresentViewController(vc, true)
        }
    }
    
    func setCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "ExerciseGridCVC", bundle: nil), forCellWithReuseIdentifier: "SingleExerciseGridCVC")
    }
    
    //MARK: - Buttons Action
    @IBAction func addExercseBtnActn(_ sender: UIButton) {
        var data = [SingleExerciseModel2]()
        for i in self.vm.exerciseModel {
            if i.isSelected {
                data.append(i)
            }
        }
        delegate?.selectedExerciseData(data: data)
        if let navigationController = self.navigationController {
            let viewControllers = navigationController.viewControllers
            for (index, viewController) in viewControllers.enumerated() {
                if let vc = viewController as? CreateScheduleVC {
                    navigationController.popToViewController(vc, animated: true)
                }
            }
        } else {
            print("Controller is not in a navigation controller")
        }
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
            vm.setCell(cell, index: indexPath.item, isCreateSchedule: isCreateSchedule)
        }
        cell.bgView.cornerRadius = 12
        cell.imgVW.backgroundColor = .blue
        cell.imgVW.layer.cornerRadius = 12
        cell.imgVW.layer.masksToBounds = true
        cell.imgVW.contentMode = .scaleToFill
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
        cell.setTemplateWithSubviews(isLoading, color: Colors.primaryClr, animate: true, viewBackgroundColor: Colors.darkGray)
        cell.alpha = 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // MARK: - Switch Controllers on tap
        if let cell = collectionView.cellForItem(at: indexPath) {
            cell.pressedAnimation {
                if indexPath.item == 0 {
                    self.openAddExerciseController()
                } else {
                    if self.isCreateSchedule {
                        let data = self.vm.exerciseModel[indexPath.item - 1]
                        if data.isSelected {
                            data.isSelected = false
                        } else {
                            data.isSelected = true
                        }
                        self.collectionView.reloadData()
                        self.setBtnTitle()
                    } else {
                        let data = self.vm.exerciseModel[indexPath.item - 1]
                        self.openExerciseDetailController(data)
                    }
                }
            }
        }
    }
    
    func setBtnTitle() {
        var count = 0
        for i in self.vm.exerciseModel {
            if i.isSelected {
                count += 1
            }
        }
        
        if count != 0 {
            self.addExerciseBtn.isEnabled = true
            self.addExerciseBtn.setTitle("Add \(count) Exercise(s)", for: .normal)
        } else {
            self.addExerciseBtn.isEnabled = false
        }
    }
}

protocol SelectedExerciseData {
    func selectedExerciseData(data: [SingleExerciseModel2])
}
