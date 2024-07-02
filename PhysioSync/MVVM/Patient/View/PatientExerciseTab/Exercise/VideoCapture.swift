//
//  VideoCapture.swift
//  befikar Ho jao
//
//  Created by Sanjeev Mehta on 17/06/24.
//

import AVFoundation
import UIKit

class VideoCapture: NSObject {
    let captureSession = AVCaptureSession()
    let videoOutput = AVCaptureVideoDataOutput()
    
    let predictor = Predictor()
    
    override init() {
        super.init()
        
        guard let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back), let input = try? AVCaptureDeviceInput(device: captureDevice) else { return }
        
        captureSession.sessionPreset = AVCaptureSession.Preset.high
        captureSession.addInput(input)
        
        captureSession.addOutput(videoOutput)
        videoOutput.alwaysDiscardsLateVideoFrames = true
        
    }
    
    func startCaptureSession() {
        DispatchQueue.main.async {
            self.captureSession.startRunning()
            self.videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoDispatchQueue"))
        }
        
    }
}

extension VideoCapture: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        predictor.estimation(sampleBuffer: sampleBuffer)
    }
        
}
