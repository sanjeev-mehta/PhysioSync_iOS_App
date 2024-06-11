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
    
    private var customVideoPlayer: CustomVideoPlayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUI()
    }
    
    private func setUI() {
        self.bottomView.addTopCornerRadius(radius: 16)
        setupCustomVideoPlayer()
        self.isHeroEnabled = true
    }
    
    private func setupCustomVideoPlayer() {
        let videoPlayerFrame = CGRect(x: 0, y: 0, width: self.videoView.frame.width, height: self.videoView.frame.height)
        customVideoPlayer = CustomVideoPlayer(frame: videoPlayerFrame)
        self.videoView.addSubview(customVideoPlayer)
        
        // URL of the video you want to play
        guard let videoURL = URL(string: "https://www.taxmann.com/emailer/images/CompaniesAct.mp4") else {
            print("Invalid URL")
            return
        }
        customVideoPlayer.configure(url: videoURL)
    }
    
    // MARK: -  Buttons Action
    @IBAction func backBtnActn(_ sender: UIButton) {
        self.heroModalAnimationType = .zoomOut
        self.dismissOrPopViewController()
    }
    
}
