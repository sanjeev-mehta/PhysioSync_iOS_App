//
//  ExerciseDetailVC.swift
//  PhysioSync
//
//  Created by Sanjeev Mehta on 07/06/24.
//

import UIKit

class PatientExerciseDetailVC: UIViewController {
    
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var categoryLbl: UILabel!
    @IBOutlet weak var videoTitleLbl: UILabel!
    @IBOutlet weak var videoDescLbl: UITextView!
    
    private var customVideoPlayer: CustomVideoPlayer!
    var data: SingleExerciseModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
    }
    
    private func setUI() {
        self.bottomView.addTopCornerRadius(radius: 16)
        setupCustomVideoPlayer()
        self.isHeroEnabled = true
        self.setHeader(data?.videoTitle ?? "", isBackBtn: true) {
            self.heroModalAnimationType = .zoomOut
            self.dismissOrPopViewController()
        } rightButtonAction: {}
        setData()
    }
    
    private func setData() {
        if let data = self.data {
            categoryLbl.text = data.categoryName.joined(separator: ", ")
            videoTitleLbl.text = "Exercise - " + data.videoTitle
            videoDescLbl.text = data.description
        }
    }
    
    private func setupCustomVideoPlayer() {
        let videoPlayerFrame = CGRect(x: 0, y: 0, width: self.videoView.frame.width, height: self.videoView.frame.height - 8)
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
    
    // MARK: -  Buttons Action
    
    @IBAction func startBtnActn(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ExerciseVC") as! ExerciseVC
        vc.categories = categoryLbl.text ?? ""
        vc.exercise = videoTitleLbl.text ?? ""
        vc.id = data?.id ?? ""
        if data!.categoryName.contains("neck") {
            vc.modelType = .neckRotation
        } else {
            vc.modelType = .shoulderModel
        }
        self.pushOrPresentViewController(vc, true)
    }
    
}
