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
    var data: Exercise?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
    }
    
    private func setUI() {
        self.bottomView.addTopCornerRadius(radius: 16)
        setupCustomVideoPlayer()
        self.isHeroEnabled = true
        self.setHeader(data?.exerciseIds[0].videoTitle ?? "", isBackBtn: true) {
            self.heroModalAnimationType = .zoomOut
            self.dismissOrPopViewController()
        } rightButtonAction: {}
    }
    
    private func setupCustomVideoPlayer() {
        let videoPlayerFrame = CGRect(x: 0, y: 0, width: self.videoView.bounds.width, height: self.videoView.frame.height)
        customVideoPlayer = CustomVideoPlayer(frame: videoPlayerFrame)
        self.videoView.addSubview(customVideoPlayer)
        guard let videoUrl = data?.exerciseIds[0].videoUrl else { return }
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
        self.present(vc, animated: true)
    }
    
}
