//
//  SplashVC.swift
//  PhysioSync
//
//  Created by Sanjeev Mehta on 12/07/24.
//

import UIKit
import AVKit

class SplashVC: UIViewController {
    
    @IBOutlet weak var imgView: UIImageView!
    
    var player: AVPlayer?
    var playerViewController: AVPlayerViewController?
    var currentScale: CGFloat = 3.9
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupVideoPlayer()
    }
    
    private func setupVideoPlayer() {
        guard let path = Bundle.main.path(forResource: "V_Logo_Animation", ofType: "mp4") else {
            print("Video file not found")
            return
        }
        
        let url = URL(fileURLWithPath: path)
        player = AVPlayer(url: url)
        playerViewController = AVPlayerViewController()
        playerViewController?.player = player
        playerViewController?.player?.isMuted = true
        // Remove playback controls
        playerViewController?.showsPlaybackControls = false
        
        // Add playerViewController as a child view controller
        addChild(playerViewController!)
        view.addSubview((playerViewController?.view)!)
        playerViewController?.view.frame = view.frame
        playerViewController?.didMove(toParent: self)
        playerViewController?.view.transform = CGAffineTransform(scaleX: currentScale, y: currentScale)

        // Observe the end of the video
        NotificationCenter.default.addObserver(self, selector: #selector(videoDidFinish), name: .AVPlayerItemDidPlayToEndTime, object: player?.currentItem)
        
        // Start playing the video
        player?.play()
    }
    
    @objc private func videoDidFinish() {
        // Redirect to another screen after the video ends
        self.performSegue(withIdentifier: "showWelcome", sender: nil)
    }
}
