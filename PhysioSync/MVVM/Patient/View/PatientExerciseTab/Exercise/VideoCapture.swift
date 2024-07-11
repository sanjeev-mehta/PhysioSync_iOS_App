//
//  VideoCapture.swift
//  PhysioSync
//
//  Created by Sanjeev Mehta on 17/06/24.
//

import AVFoundation
import UIKit

class VideoCapture: NSObject {
    
    let captureSession = AVCaptureSession()
    let videoOutput = AVCaptureVideoDataOutput()
    
    let predictor = Predictor()
    var currentCamera: AVCaptureDevice?
    let movieOutput = AVCaptureMovieFileOutput()
    var startPredicting = false
    var videoUrl = ""
    weak var delegate: VideoCaptureDelegate?
    
    override init() {
        super.init()
        
        guard let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back), let input = try? AVCaptureDeviceInput(device: captureDevice) else { return }
        
        captureSession.sessionPreset = AVCaptureSession.Preset.high
        captureSession.addInput(input)
        
        captureSession.addOutput(videoOutput)
        videoOutput.alwaysDiscardsLateVideoFrames = true
        
        if captureSession.canAddOutput(movieOutput) {
            captureSession.addOutput(movieOutput)
        }
        // switchCameraInput(to: .back)
    }
    
    func switchCameraInput(to position: AVCaptureDevice.Position) {
        // Remove existing input
        if let currentInput = captureSession.inputs.first as? AVCaptureDeviceInput {
            captureSession.removeInput(currentInput)
        }
        
        // Find the desired camera
        guard let newCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: position),
              let newInput = try? AVCaptureDeviceInput(device: newCamera) else {
            print("Failed to create input device from specified camera.")
            return
        }
        
        // Add new input to session
        if captureSession.canAddInput(newInput) {
            captureSession.addInput(newInput)
            currentCamera = newCamera
        } else {
            print("Failed to add input device to capture session.")
        }
    }
    
    func startCaptureSession() {
        DispatchQueue.global(qos: .background).async {
            self.captureSession.startRunning()
            self.videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoDispatchQueue"))
        }
    }
    
    func startRecording() {
        let outputFilePath = NSTemporaryDirectory() + "tempMovie.mov"
        let outputURL = URL(fileURLWithPath: outputFilePath)
        movieOutput.startRecording(to: outputURL, recordingDelegate: self)
    }
    
    func stopRecording() {
        if movieOutput.isRecording {
            movieOutput.stopRecording()
        }
    }
}

extension VideoCapture: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        if startPredicting {
            predictor.estimation(sampleBuffer: sampleBuffer)
        }
    }
    
}

extension VideoCapture: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if let error = error {
            print("Error recording movie: \(error)")
        } else {
            self.videoUrl = outputFileURL.absoluteString
            print("Movie saved to: \(videoUrl)")
            delegate?.didFinishRecordingVideo(url: outputFileURL)
        }
    }
    
    func deleteFile(at url: URL) {
        do {
            try FileManager.default.removeItem(at: url)
            print("File deleted successfully.")
        } catch {
            print("Error deleting file: \(error.localizedDescription)")
        }
    }
}

protocol VideoCaptureDelegate: AnyObject {
    func didFinishRecordingVideo(url: URL?)
}
