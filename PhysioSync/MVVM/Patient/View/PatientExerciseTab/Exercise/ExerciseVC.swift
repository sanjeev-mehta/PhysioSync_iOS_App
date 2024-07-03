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
    
    var previewLayer: AVCaptureVideoPreviewLayer?
    let videoCapture = VideoCapture()

    var poseView = PoseView()
    
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
        previewLayer.frame = view.frame
        
        cameraView.addSubview(poseView)
        poseView.frame = view.frame
        poseView.backgroundColor = .clear
        
    }

}

extension ExerciseVC: PredictorDelegate {
    
    func predictor(_ predictor: Predictor, didLabelAction action: String, with confidence: Double) {
//        print("=====>>>>>",action, confidence)
    }
    
    func predictor(_ predictor: Predictor, didFindNewRecognizedPoints points: [CGPoint]) {
        guard let previewLayer = previewLayer else { return }
        
        let convertedPoints = points.map {
            previewLayer.layerPointConverted(fromCaptureDevicePoint: $0)
        }
        
        poseView.points = convertedPoints
    }
    
}

