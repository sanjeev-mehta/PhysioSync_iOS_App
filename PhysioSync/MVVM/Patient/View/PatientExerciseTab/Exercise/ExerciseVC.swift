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
    
    enum ExerciseStage {
        case still, right, left
    }
    
    var currentStage: ExerciseStage = .still
    var repCount = 0
    var halfRep = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpVideoPreview()
        videoCapture.predictor.delegate = self
        
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
                currentStage = .still
            }
        case "right1":
            if currentStage == .still {
                halfRep += 1
                currentStage = .right
            }
        case "left1":
            if currentStage == .still {
                halfRep += 1
                currentStage = .left
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
}

