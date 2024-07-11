//
//  ExerciseVC.swift
//  PhysioSync
//
//  Created by Sanjeev Mehta on 01/07/24.
//

import UIKit
import AVFoundation

class ExerciseVC: UIViewController {
    
    //MARK: - Outlets
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var repLbl: UILabel!
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var sendVideoBtn: UIButton!
    @IBOutlet weak var startBtn: UIButton!
    @IBOutlet weak var statusLbl: UILabel!
    @IBOutlet weak var categoriesLbl: UILabel!
    @IBOutlet weak var exerciseNameLbl: UILabel!
    
    var previewLayer: AVCaptureVideoPreviewLayer?
    let videoCapture = VideoCapture()
    
    var poseView = PoseView()
    var customVideoPlayer: CustomVideoPlayer?
    var categories = ""
    var exercise = ""
    var id = ""
    
    enum ExerciseStage {
        case still, right, left
    }
    
    var currentStage: ExerciseStage = .still
    var repCount = 0
    var halfRep = 0
    let synthesizer = AVSpeechSynthesizer()
    var currentCameraPosition: AVCaptureDevice.Position = .back
    let vm = ExerciseViewModel.shareInstance
    var secondsElapsed = 0
    var timer: Timer?
    var videoUrl: URL!
    var modelType: ModelType?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpVideoPreview()
        videoCapture.predictor.delegate = self
        videoCapture.delegate = self
        videoCapture.switchModel(to: modelType ?? .neckRotation)
        
        //MARK: - Add double tap gesture recognizer to switch Camera
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        doubleTapGesture.numberOfTapsRequired = 2
        cameraView.addGestureRecognizer(doubleTapGesture)
        self.categoriesLbl.text = categories
        self.exerciseNameLbl.text = exercise
    }
    
    private func setUpVideoPreview() {
        
        videoCapture.startCaptureSession()
        previewLayer = AVCaptureVideoPreviewLayer(session: videoCapture.captureSession)
        
        guard let previewLayer = previewLayer else {return}
        
        cameraView.layer.addSublayer(previewLayer)
        previewLayer.frame = CGRect(x: 0, y:16, width: self.cameraView.frame.width, height: self.cameraView.frame.height)
        
        cameraView.addSubview(poseView)
        poseView.frame = cameraView.bounds
        poseView.backgroundColor = .clear
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = cameraView.bounds
        poseView.frame = cameraView.bounds
    }
    
    func uploadRecordedVideo(url: URL) {
        let timestamp = Int(Date().timeIntervalSince1970)
        AWSHelper.shared.uploadVideoFile(url: url, fileName: "\(timestamp)") { progress in
            print(progress)
        } completion: { status, url, err in
            if err != nil {
                print(status, err)
                self.displayAlert(title: "Alert!", msg: "something went wrong", ok: "Ok")
            } else {
                print(url)
                if let url = url {
                    DispatchQueue.main.async {
                        self.callApi(url: url)
                    }
                }
            }
        }
        
    }
    
    func callApi(url: String) {
        let today = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-dd-mm"
        let todayStr = formatter.string(from: today)
        let parm = ["status": "completed", "patient_video_url": url, "patient_exercise_completion_date_time": todayStr]
        
        vm.updateAssignExercise(self, id: id, parm: parm) { _ in
            self.popController()
        }
    }
    
    @objc func handleDoubleTap(_ gesture: UITapGestureRecognizer) {
        self.view.hapticFeedback(style: .soft)
        // Toggle camera position
        currentCameraPosition = (currentCameraPosition == .back) ? .front : .back
        
        // Restart capture session with new camera input
        videoCapture.switchCameraInput(to: currentCameraPosition)
    }
    
    func startTimer() {
        // Invalidate any existing timer before creating a new one
        timer?.invalidate()
        
        // Schedule a timer to call the `updateTimer` method every second
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }
    
    @objc func updateTimer() {
        secondsElapsed += 1
        let minutes = secondsElapsed / 60
        let seconds = secondsElapsed % 60
        let newTime = String(format: "%02d:%02d", minutes, seconds)
        // timeLbl.text = String(format: "%02d:%02d", minutes, seconds)
        UIView.transition(with: timeLbl, duration: 0.2, options: .transitionCrossDissolve, animations: {
            self.timeLbl.text = newTime
        }, completion: nil)
    }
    
    deinit {
        // Invalidate the timer when the view controller is deallocated
        timer?.invalidate()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if videoCapture.videoUrl != "" {
            self.videoCapture.deleteFile(at: videoUrl)
        }
    }
    
    func popController() {
        if let viewControllers = navigationController?.viewControllers {
            // Get the view controller at index 4
            if viewControllers.count > 3 {
                // Get the view controller at index 3
                let targetViewController = viewControllers[3]
                navigationController?.popToViewController(targetViewController, animated: true)
            }
        } else {
            print("Not enough view controllers in the navigation stack.")
        }
    }
    
    @IBAction func startBtnActn(_ sender: UIButton) {
        if sender.tag == 0 {
            repCount = 0
            sender.tag = 1
            startTimer()
            sender.setTitle("Stop", for: .normal)
            sender.backgroundColor = .clear
            sender.layer.borderColor = UIColor.black.cgColor
            sender.layer.borderWidth = 0.7
            sender.setTitleColor(.black, for: .normal)
            sendVideoBtn.isHidden = true
            repLbl.isHidden = false
            videoCapture.startPredicting = true
            videoCapture.startRecording()
        } else {
            sender.tag = 0
            sender.setTitle("Restart", for: .normal)
            sender.backgroundColor = .clear
            sender.layer.borderColor = UIColor.black.cgColor
            sender.layer.borderWidth = 0.7
            timer?.invalidate()
            sendVideoBtn.isHidden = false
            videoCapture.startPredicting = false
            videoCapture.stopRecording()
        }
    }
    
    @IBAction func sendVideo(_ sender: UIButton) {
        self.uploadRecordedVideo(url: self.videoUrl)
    }
    
    @IBAction func backBtnActn(_ sender: UIButton) {
        if timeLbl.text != "00:00" {
            self.displayAlert3(title: "Alert!", msg: "Are you sure you want to go back? Recorded video will be lost.", ok: "Ok") {
                self.dismissOrPopViewController()
            }
        } else {
            self.dismissOrPopViewController()
        }
    }
    
}

extension ExerciseVC: PredictorDelegate {
    
    func predictor(_ predictor: Predictor, didLabelAction action: String, with confidence: Double) {
        guard confidence > 0.85 else { return }
        print("=====>>>>>",action, confidence)
        leftRightRepCount(action: action)
    }
    
    func predictor(_ predictor: Predictor, didFindNewRecognizedPoints points: [CGPoint]) {
        guard let previewLayer = previewLayer else { return }
        
        if points.isEmpty {
            poseView.points = []
        } else {
            let convertedPoints = points.map {
                previewLayer.layerPointConverted(fromCaptureDevicePoint: $0)
            }
            poseView.points = convertedPoints
        }
    }
    
    func leftRightRepCount(action: String) {
        switch action {
        case "still1":
            if currentStage == .right || currentStage == .left {
                if currentStage == .right {
                    speakInstruction("Move to the left")
                } else {
                    speakInstruction("Move to the right")
                }
                currentStage = .still
            }
        case "right1":
            if currentStage == .still {
                halfRep += 1
                currentStage = .right
                speakInstruction("Move back to still")
            }
        case "left1":
            if currentStage == .still {
                halfRep += 1
                currentStage = .left
                speakInstruction("Move back to still")
            }
        default:
            break
        }
        
        if halfRep == 2 {
            repCount += 1
            halfRep = 0
        }
        DispatchQueue.main.async {
            let myString = "REPS\n \(self.repCount)"
            let attributedString = NSMutableAttributedString(string: myString)
            attributedString.setColor(forText: ["REPS": .white, "\(self.repCount)": .white])
            self.repLbl.attributedText = attributedString
        }
        print("Reps: \(repCount)")
    }
    
    //MARK: - Function to speak instructions
    func speakInstruction(_ text: String) {
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
            let utterance = AVSpeechUtterance(string: text)
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
            utterance.rate = 0.5
            self.synthesizer.speak(utterance)
        }
    }
    
    func playVideo() {
        customVideoPlayer = CustomVideoPlayer(frame: CGRect(x: 20, y: 100, width: 300, height: 200))
        print("*****", videoCapture.videoUrl)
        customVideoPlayer?.configure(url: URL(fileURLWithPath: videoCapture.videoUrl))
        
        if let customVideoPlayer = customVideoPlayer {
            view.addSubview(customVideoPlayer)
        }
        
        // Optionally, play the video
        customVideoPlayer?.play()
    }
}

extension ExerciseVC: VideoCaptureDelegate {
    func didFinishRecordingVideo(url: URL?) {
        if let url = url {
            self.videoUrl = url
        }
    }
    
    
}
