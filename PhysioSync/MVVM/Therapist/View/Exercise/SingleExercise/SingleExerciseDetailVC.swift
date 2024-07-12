//
//  SingleExerciseDetailVC.swift
//  PhysioSync
//
//  Created by Rohit on 2024-06-13.
//

import UIKit
import FTPopOverMenu_Swift

class SingleExerciseDetailVC: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionHeight: NSLayoutConstraint!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var videoDesc: UILabel!
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var menuBtn: UIButton!
    @IBOutlet weak var bottomView: UIView!
    
    // MARK: - Variables
    var categoryArr = [categoryData]()
    var headerTitle = "Exercise 1"
    var data: SingleExerciseModel?
    private var customVideoPlayer: CustomVideoPlayer!
    private let vm = ExerciseCategoryViewModel.shareInstance
    private let singleExerciseVM = SingleExerciseViewModel.shareInstance
    var name = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setCollectionView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.bottomView.addTopCornerRadius(radius: 16)
        callGetDetailExercise()
    }
    
    // MARK: - Methods
    
    func callGetDetailExercise() {
        self.singleExerciseVM.getSingleExercise(vc: self, name: name) { [self] status in
            for i in self.singleExerciseVM.exerciseModel {
                if i.id == data?.id {
                    data = i
                    break
                }
            }
            setupCustomVideoPlayer()
            setData()
        }
    }
    
    func openPopUpMenu() {
        let configuration = FTConfiguration.shared
        configuration.menuRowHeight = 30
        configuration.menuWidth = 100
        configuration.localShadow = true
        FTPopOverMenu.showForSender(sender: self.menuBtn, with: ["Edit", "Delete"]) { (selectedIndex) -> () in
            print(selectedIndex)
            if selectedIndex == 0 {
                self.openAddExerciseController()
            } else {
                self.displayAlert3(title: "Alert!", msg: "Are you sure, you want to delete this exercise", ok: "Yes") {
                    self.callDeleteApi()
                }
            }
        } cancel: {
            
        }
    }
    
    private func setupCustomVideoPlayer() {
        let videoPlayerFrame = CGRect(x: 0, y: 0, width: self.videoView.bounds.width, height: self.videoView.frame.height)
        customVideoPlayer = CustomVideoPlayer(frame: videoPlayerFrame)
        self.videoView.addSubview(customVideoPlayer)
        guard let videoUrl = data?.videoUrl else { return }
        // URL of the video you want to play
        guard let videoURL = URL(string: videoUrl) else {
            print("Invalid URL")
            return
        }
        customVideoPlayer.configure(url: videoURL)
    }
    
    func openAddExerciseController() {
        if let vc = self.switchController(.addNewExerciseVC, .exerciseTab) as? AddNewExerciseVC {
            vc.isEdit = true
            vc.data = self.data
            self.pushOrPresentViewController(vc, true)
        }
    }
    
    func callDeleteApi() {
        vm.deleteExercises(vc: self, id: data!.id) { status in
            self.dismissOrPopViewController()
        }
    }
    
    //MARK: - Set Collection View
    func setCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 5
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        collectionView.collectionViewLayout = layout
        collectionView.register(UINib(nibName: "ChipsCVC", bundle: nil), forCellWithReuseIdentifier: "ChipsCVC")
    }
    // MARK: - Set Data
    func setData() {
        if let data = data {
            self.videoDesc.text = data.description
        }
        self.setHeader(data?.videoTitle ?? "",rightImg: UIImage(named: "threeDots")!, isRightBtn: true) {
            self.dismissOrPopViewController()
        } rightButtonAction: {
            self.openPopUpMenu()
        }
        self.collectionView.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionHeight.constant = collectionView.contentSize.height
    }
}

extension SingleExerciseDetailVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data?.categoryName.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ChipsCVC", for: indexPath) as! ChipsCVC
        let data = data!.categoryName[indexPath.item]
        cell.titleLbl.text = data
        cell.bgView.backgroundColor = .blue
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        if categoryArr[indexPath.item].isSelected {
//            categoryArr[indexPath.item].isSelected = false
//        } else {
//            categoryArr[indexPath.item].isSelected = true
//        }
//        collectionView.reloadData()
    }
    
}


// MARK: -  Struct
struct categoryData {
    var name = ""
    var isSelected = false
    
    init(name: String = "", isSelected: Bool = false) {
        self.name = name
        self.isSelected = isSelected
    }
}
