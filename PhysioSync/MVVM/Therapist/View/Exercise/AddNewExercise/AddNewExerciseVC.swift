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
    private let exerciseVM = ExerciseCategoryViewModel.shareInstance
    var isEdit = false
    var data: SingleExerciseModel2?
    var isVideoChange = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.videoPicker = ImagePickerHelper(viewController: self)
        self.descTV.delegate = self
        self.descTV.text = "Enter a brief description"
        self.descTV.textColor = .lightGray
        setData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setHeader("Add New Exercise", isRightBtn: false) {
            if self.isEdit {
                let alertController = UIAlertController(title: "Discard Changes?", message: "Are you sure you want to discard your changes?", preferredStyle: .alert)
                
                let discardAction = UIAlertAction(title: "Discard", style: .destructive) { _ in
                    // Handle discard action here
                    self.dismissOrPopViewController()
                }
                
                let keepEditingAction = UIAlertAction(title: "Keep Editing", style: .default) { _ in
                    print("Continuing to edit")
                }
                
                alertController.addAction(discardAction)
                alertController.addAction(keepEditingAction)
                
                self.present(alertController, animated: true, completion: nil)
            } else {
                self.dismissOrPopViewController()
            }
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
        Timer.scheduledTimer(withTimeInterval: 0.6, repeats: false) { _ in
            self.collectionHeight.constant = self.collectionView.contentSize.height
        }
        
        if let data = self.data {
            if isEdit {
                nameTf.text = data.videoTitle
                videoFileNameLbl.text = data.videoTitle + ".mov"
                descTV.text = data.description
                for i in self.exerciseVM.categoriesModel {
                    for v in self.data!.categoryName {
                        if i.name == v {
                            i.isSelected = true
                        }
                    }
                }
                self.collectionView.reloadData()
            }
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
            //            self.videoPicker?.showCustomVideoPicker(from: self, completion: { url in
            //                DispatchQueue.main.async {
            //                    self.isVideoChange = true
            //                    self.videoUrl = url
            //                    self.videoFileNameLbl.text = "Default"
            //                }
            //            })
            self.videoPicker?.showVideoPicker(sourceType: .photoLibrary, completion: { url, name in
                print(url, name)
                DispatchQueue.main.async {
                    guard let videoUrl = url else {
                        print("Failed to retrieve video from photo library.")
                        return
                    }
                    
                    self.copyVideoToPermanentLocation(videoURL: videoUrl) { permanentURL in
                        guard let finalURL = permanentURL else {
                            print("Failed to copy video to permanent location.")
                            return
                        }
                        
                        self.isVideoChange = true
                        self.videoUrl = finalURL
                        self.videoFileNameLbl.text = finalURL.lastPathComponent
                        print("Selected video URL: \(finalURL)")
                        
                        // Proceed with your AWS upload logic here
                    }
                }
            })
        }
        
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { _ in
            self.videoPicker?.showVideoPicker(sourceType: .camera) { url, name in
                print(url, name)
                self.isVideoChange = true
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
        var isSelected = false
        for i in exerciseVM.categoriesModel {
            if i.isSelected {
                isSelected = true
                break
            }
        }
        
        if nameTf.text == "" {
            self.displayAlert(title: "Warning", msg: "Please enter video title", ok: "Ok")
        } else if videoFileNameLbl.text == "Select a video file" {
            self.displayAlert(title: "Warning", msg: "Please select video file", ok: "Ok")
        } else if descTV.text == "Enter a brief description" {
            self.displayAlert(title: "Warning", msg: "Please enter description", ok: "Ok")
        } else if !isSelected {
            self.displayAlert(title: "Warning", msg: "Please select atleast 1 category", ok: "Ok")
        } else {
            if isVideoChange {
                var av = UIView()
                av = Loader.start(view: self.view)
                awsHelper.uploadVideoFile(url: self.videoUrl!,fileName: videoFileNameLbl.text!) { progress in
                    print("Upload Progress: \(progress)%")
                } completion: { success, videoUrl, err in
                    if success {
                        print("Upload successful, video URL: \(String(describing: videoUrl))")
                        DispatchQueue.main.async {
                            self.uploadThumbnailImage(videoUrl: videoUrl ?? "", loaderView: av)
                        }
                    } else {
                        print("Upload failed, error: \(String(describing: err?.localizedDescription))")
                    }
                }
            } else {
                self.callApi(url: data!.videoUrl, imgUrl: data!.video_thumbnail)
            }
        }
    }
    
    func uploadThumbnailImage(videoUrl: String, loaderView: UIView) {
        self.getThumbnailImageFromVideoUrl(url: URL(string: videoUrl)!) { [weak self] img in
            guard let self = self, let thumbnailImage = img else {
                print("Failed to generate thumbnail image")
                return
            }
            let timestamp = Int(Date().timeIntervalSince1970)
            if let thumbnailImageUrl = self.saveImageToTemporaryDirectory(image: thumbnailImage) {
                // Pass the thumbnail image URL to awsHelper.uploadImageFile
                
                self.awsHelper.uploadImageFile(url: thumbnailImageUrl, fileName: "\(timestamp).jpg", progress: { progress in
                    print("Upload progress: \(progress)")
                }) { success, url, error in
                    if success {
                        print("Image uploaded successfully. URL: \(url ?? "No URL")")
                        DispatchQueue.main.async {
                            loaderView.removeFromSuperview()
                            self.callApi(url: videoUrl, imgUrl: url ?? "")
                        }
                    } else {
                        print("Image upload failed. Error: \(String(describing: error))")
                    }
                }
            } else {
                print("Failed to save thumbnail image to temporary directory")
            }
            
        }
        
    }
    
    private func copyVideoToPermanentLocation(videoURL: URL, completion: @escaping (URL?) -> Void) {
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let destinationURL = documentsDirectory.appendingPathComponent(videoURL.lastPathComponent)
        
        do {
            if fileManager.fileExists(atPath: destinationURL.path) {
                try fileManager.removeItem(at: destinationURL)
            }
            try fileManager.copyItem(at: videoURL, to: destinationURL)
            completion(destinationURL)
        } catch {
            print("Error copying video to permanent location: \(error.localizedDescription)")
            completion(nil)
        }
    }
    
    func saveImageToTemporaryDirectory(image: UIImage) -> URL? {
        guard let imageData = image.jpegData(compressionQuality: 1.0) else {
            print("Failed to convert image to JPEG data")
            return nil
        }
        
        let tempDirectory = FileManager.default.temporaryDirectory
        let fileName = UUID().uuidString + ".jpg"
        let fileURL = tempDirectory.appendingPathComponent(fileName)
        
        do {
            try imageData.write(to: fileURL)
            return fileURL
        } catch {
            print("Error saving image to temporary directory: \(error)")
            return nil
        }
    }
    
    func callApi(url: String, imgUrl: String) {
        var exerciseId = [String]()
        var exerciseName = [String]()
        for i in exerciseVM.categoriesModel {
            if i.isSelected {
                exerciseId.append(i.Id!)
                exerciseName.append(i.name!)
            }
        }
        let parm:[String: Any] = ["video_Url": url, "video_title": nameTf.text!, "description": descTV.text!, "video_thumbnail": imgUrl, "category_name": exerciseName, "category_id": exerciseId]
        var id = ""
        if isEdit {
            id = data!.id
        }
        vm.addExerciseApi(vc: self, id: id ,isEdit: self.isEdit, parm: parm) { status in
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
        return exerciseVM.getArrayCount()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ChipsCVC", for: indexPath) as! ChipsCVC
        let data = exerciseVM.categoriesModel[indexPath.item]
        cell.titleLbl.text = data.name?.capitalized 
        if data.isSelected {
            cell.bgView.backgroundColor = Colors.primaryClr
            cell.titleLbl.textColor = .white
        } else {
            cell.bgView.backgroundColor = Colors.chipsClr1
            cell.titleLbl.textColor = Colors.primaryClr
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let data = exerciseVM.categoriesModel[indexPath.item]
        if data.isSelected {
            data.isSelected = false
        } else {
            data.isSelected = true
        }
        collectionView.reloadData()
    }
    
}

extension AddNewExerciseVC: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.text = ""
        textView.textColor = .black
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            textView.text = "Enter a brief description"
            textView.textColor = .lightGray
        }
    }
}
