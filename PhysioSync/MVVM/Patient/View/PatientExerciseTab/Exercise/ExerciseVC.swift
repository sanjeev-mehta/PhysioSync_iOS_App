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
    
    var previewLayer: AVCaptureVideoPreviewLayer?
    let videoCapture = VideoCapture()
    
    var poseView = PoseView()
    var customVideoPlayer: CustomVideoPlayer?
    
    enum ExerciseStage {
        case still, right, left
    }
    
    var currentStage: ExerciseStage = .still
    var repCount = 0
    var halfRep = 0
    let synthesizer = AVSpeechSynthesizer()
    var currentCameraPosition: AVCaptureDevice.Position = .back
    let vm = ExerciseViewModel.shareInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpVideoPreview()
        videoCapture.predictor.delegate = self
        videoCapture.delegate = self
        
        //MARK: - Add double tap gesture recognizer to switch Camera
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        doubleTapGesture.numberOfTapsRequired = 2
        cameraView.addGestureRecognizer(doubleTapGesture)
    }
    
    private func setUpVideoPreview() {
        
        videoCapture.startCaptureSession()
        previewLayer = AVCaptureVideoPreviewLayer(session: videoCapture.captureSession)
        
        guard let previewLayer = previewLayer else {return}
        
        cameraView.layer.addSublayer(previewLayer)
        previewLayer.frame = cameraView.bounds
        
        cameraView.addSubview(poseView)
        poseView.frame = cameraView.bounds
        poseView.backgroundColor = .clear
        
    }
    
    func uploadRecordedVideo(url: URL) {
        let timestamp = Int(Date().timeIntervalSince1970)
        AWSHelper.shared.uploadVideoFile(url: url, fileName: "\(timestamp)") { progress in
            print(progress)
        } completion: { status, url, err in
            if err != nil {
                print(status, err)
            } else {
                print(url)
                if let url = url {
                    self.callApi(url: url)
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
        
        vm.updateAssignExercise(self, id: "668b10534a81f57c38d2c081", parm: parm) { _ in
            
        }
    }
    
    @objc func handleDoubleTap(_ gesture: UITapGestureRecognizer) {
        self.view.hapticFeedback(style: .soft)
        // Toggle camera position
        currentCameraPosition = (currentCameraPosition == .back) ? .front : .back
        
        // Restart capture session with new camera input
        videoCapture.switchCameraInput(to: currentCameraPosition)
    }
    
    @IBAction func startBtnActn(_ sender: UIButton) {
        if sender.tag == 0 {
            sender.tag = 1
            sender.setTitle("Stop", for: .normal)
            videoCapture.startPredicting = true
            videoCapture.startRecording()
        } else {
            sender.tag = 0
            sender.setTitle("Start", for: .normal)
            videoCapture.startPredicting = false
            videoCapture.stopRecording()
        }
    }
    
    @IBAction func sendVideo(_ sender: UIButton) {
      
    }
    
}

extension ExerciseVC: PredictorDelegate {
    
    func predictor(_ predictor: Predictor, didLabelAction action: String, with confidence: Double) {
        print("=====>>>>>",action, confidence)
        guard confidence > 0.85 else { return }
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
            self.repLbl.text = "REPS\n \(self.repCount)"
        }
        print("Reps: \(repCount)")
    }
    
    //MARK: - Function to speak instructions
    func speakInstruction(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.5
        self.synthesizer.speak(utterance)
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
            self.uploadRecordedVideo(url: url)
        }
    }
    
    
}
