import UIKit
import AVKit
import AVFoundation

class CustomVideoPlayer: UIView, AVPlayerViewControllerDelegate {

    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private var playerViewController: AVPlayerViewController?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupPlayerView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupPlayerView()
    }

    private func setupPlayerView() {
        playerViewController = AVPlayerViewController()
        playerViewController?.allowsPictureInPicturePlayback = true
        playerViewController?.canStartPictureInPictureAutomaticallyFromInline = true
        playerViewController?.delegate = self

        guard let playerViewController = playerViewController else { return }
        playerViewController.view.frame = self.bounds
        playerViewController.view.layer.cornerRadius = 16
        playerViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        self.addSubview(playerViewController.view)
    }

    func configure(url: URL) {
        player = AVPlayer(url: url)
        playerViewController?.player = player
    }

    func play() {
        player?.play()
    }

    func pause() {
        player?.pause()
    }

    // MARK: - AVPlayerViewControllerDelegate

    func playerViewControllerWillStartPictureInPicture(_ playerViewController: AVPlayerViewController) {
        print("Will Start PiP")
    }

    func playerViewControllerDidStartPictureInPicture(_ playerViewController: AVPlayerViewController) {
        print("Did Start PiP")
    }

    func playerViewController(_ playerViewController: AVPlayerViewController, failedToStartPictureInPictureWithError error: Error) {
        print("Failed to start PiP: \(error.localizedDescription)")
    }

    func playerViewControllerWillStopPictureInPicture(_ playerViewController: AVPlayerViewController) {
        print("Will Stop PiP")
    }

    func playerViewControllerDidStopPictureInPicture(_ playerViewController: AVPlayerViewController) {
        print("Did Stop PiP")
    }

    func playerViewControllerShouldAutomaticallyDismissAtPictureInPictureStart(_ playerViewController: AVPlayerViewController) -> Bool {
        return true
    }

    func playerViewController(_ playerViewController: AVPlayerViewController, restoreUserInterfaceForPictureInPictureStopWithCompletionHandler completionHandler: @escaping (Bool) -> Void) {
        // Restore the UI as needed
        completionHandler(true)
    }
}
