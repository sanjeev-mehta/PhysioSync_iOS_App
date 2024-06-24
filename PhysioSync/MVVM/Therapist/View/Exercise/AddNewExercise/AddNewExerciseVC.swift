//
//  AddNewExerciseVC.swift
//  PhysioSync
//
//  Created by Rohit on 2024-06-13.
//

import UIKit

class AddNewExerciseVC: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionHeight: NSLayoutConstraint!
    @IBOutlet weak var nameTf: UITextField!
    @IBOutlet weak var videoFileNameLbl: UILabel!
    @IBOutlet weak var descTV: UITextView!
    
    // MARK: - Variables
    private var categoryArr = [categoryData]()
    private var videoPicker: ImagePickerHelper?
    private let vm = AddNewExerciseViewModel.shareInstance
    private var awsHelper = AWSHelper.shared
    private var videoUrl: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.videoPicker = ImagePickerHelper(viewController: self)
        setData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setHeader("Add New Exercise", isRightBtn: false) {
            self.dismissOrPopViewController()
        } rightButtonAction: {
            // not in use
        }
    }
    
    // MARK: - Set Data
    func setData() {
        collectionView.delegate = self
        collectionView.dataSource = self
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 5 // Adjust as needed for horizontal spacing
        layout.minimumLineSpacing = 5 // Adjust as needed for vertical spacing
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        collectionView.collectionViewLayout = layout
        collectionView.register(UINib(nibName: "ChipsCVC", bundle: nil), forCellWithReuseIdentifier: "ChipsCVC")
        categoryArr.append(categoryData(name: "Neck", isSelected: false))
        categoryArr.append(categoryData(name: "Core", isSelected: false))
        categoryArr.append(categoryData(name: "Arm", isSelected: false))
        categoryArr.append(categoryData(name: "Upper Back", isSelected: false))
        collectionView.reloadData()
        Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { _ in
            self.collectionHeight.constant = self.collectionView.contentSize.height
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionHeight.constant = collectionView.contentSize.height
    }
    
    // MARK: -  openActionSheet for select image
    func openSheet(sender: UIButton) {
        let actionSheet = UIAlertController(title: "Select Video", message: "Choose a source", preferredStyle: .actionSheet)
        
        let photoLibraryAction = UIAlertAction(title: "Photo Library", style: .default) { _ in
            self.videoPicker?.showVideoPicker(sourceType: .photoLibrary, completion: { url, name in
                print(url, name)
                self.videoUrl = url
                self.videoFileNameLbl.text = name
            })
        }
        
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { _ in
            self.videoPicker?.showVideoPicker(sourceType: .camera) { url, name in
                print(url, name)
                self.videoUrl = url
                self.videoFileNameLbl.text = name
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        actionSheet.addAction(photoLibraryAction)
        actionSheet.addAction(cameraAction)
        actionSheet.addAction(cancelAction)
        
        // For iPad compatibility
        if let popoverController = actionSheet.popoverPresentationController {
            popoverController.sourceView = sender
            popoverController.sourceRect = sender.bounds
        }
        
        self.present(actionSheet, animated: true, completion: nil)
    }

    //MARK: - Validation
    func validation() {
        if nameTf.text == "" {
            self.displayAlert(title: "Warning", msg: "Please enter video title", ok: "Ok")
        } else if videoFileNameLbl.text == "Select a video file" {
            self.displayAlert(title: "Warning", msg: "Please select video file", ok: "Ok")
        } else if descTV.text == "" {
            self.displayAlert(title: "Warning", msg: "Please enter description", ok: "Ok")
        } else {
            awsHelper.uploadVideoFile(url: self.videoUrl!, fileName: videoFileNameLbl.text!) { progress in
                print("Upload Progress: \(progress)%")
            } completion: { success, videoUrl, err in
                if success {
                    print("Upload successful, video URL: \(String(describing: videoUrl))")
                    DispatchQueue.main.async {
                        self.callApi(url: videoUrl!)
                    }
                } else {
                    print("Upload failed, error: \(String(describing: err?.localizedDescription))")
                }
            }

        }
    }
    
    func callApi(url: String) {
        let parm:[String: Any] = ["video_Url": url, "video_title": nameTf.text!, "description": descTV.text!]
        vm.addExerciseApi(vc: self, parm: parm) { status in
            if status {
                self.dismissOrPopViewController()
            }
        }
    }
    
    //MARK: - Button Actions
    @IBAction func selectFileBtnActn(_ sender: UIButton) {
        openSheet(sender: sender)
    }
    
    @IBAction func saveBtnActn(_ sender: UIButton) {
        validation()
    }
}

extension AddNewExerciseVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categoryArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ChipsCVC", for: indexPath) as! ChipsCVC
        let data = categoryArr[indexPath.item]
        cell.titleLbl.text = data.name
        if categoryArr[indexPath.item].isSelected {
            cell.bgView.backgroundColor = .black
        } else {
            cell.bgView.backgroundColor = .blue
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if categoryArr[indexPath.item].isSelected {
            categoryArr[indexPath.item].isSelected = false
        } else {
            categoryArr[indexPath.item].isSelected = true
        }
        collectionView.reloadData()
    }
    
}
