//
//  Predictor.swift
//  PhysioSync
//
//  Created by Sanjeev Mehta on 17/06/24.
//

import Foundation
import Vision
import UIKit

//Vision, AVFoundation, CreateML, MLModel
typealias SquatsModel = neckRotation

protocol PredictorDelegate: AnyObject {
    func predictor(_ predictor: Predictor, didFindNewRecognizedPoints points: [CGPoint])
    func predictor(_ predictor: Predictor, didLabelAction action: String, with confidence: Double)
}

class Predictor {
    
    weak var delegate: PredictorDelegate?
    
    let predictionWindowSize = 30
    var posesWindow: [VNHumanBodyPoseObservation] = []
    private var inactivityTimer: Timer?
    let squatsClassifier: SquatsModel

    init() {
        squatsClassifier = try! SquatsModel(configuration: MLModelConfiguration())
        posesWindow.reserveCapacity(predictionWindowSize)
    }
    
    func estimation(sampleBuffer: CMSampleBuffer) {
        let requestHandler = VNImageRequestHandler(cmSampleBuffer: sampleBuffer, orientation: .up)
        
        let request = VNDetectHumanBodyPoseRequest(completionHandler: bodyPoseHandler)
        
        do {
            try requestHandler.perform([request])
        } catch {
            print("Unable to perform the request: \(error)")
        }
    }
    
    func bodyPoseHandler(request: VNRequest, error: Error?) {
        guard let observation = request.results as? [VNHumanBodyPoseObservation] else { return }
        
        observation.forEach {
            processObservation($0)
        }
        
        if let result = observation.first {
            storeObservation(result)
            
            labelActionType()
        }
        
    }
    
    func labelActionType() {
        DispatchQueue.global(qos: .background).async {
            guard let poseMultiArray = self.prepareInputWithObservation(self.posesWindow) else { return }
            
            do {
                let predictions = try self.squatsClassifier.prediction(poses: poseMultiArray)
                let label = predictions.label
                let confidence = predictions.labelProbabilities[label] ?? 0
                DispatchQueue.main.async {
                    self.delegate?.predictor(self, didLabelAction: label, with: confidence)
                }
            } catch {
                print("Error predicting action: \(error)")
            }
        }
    }
    
    func prepareInputWithObservation (_ observations: [VNHumanBodyPoseObservation]) -> MLMultiArray? {
        let numAvailableFrames = observations.count
        let observationsNeeded = 30
        var multiArrayBuffer = [MLMultiArray]()
        
        for frameIndex in 0..<min(numAvailableFrames, observationsNeeded) {
            let pose = observations[frameIndex]
            do {
                let oneFrameMultiArray = try pose.keypointsMultiArray()
                multiArrayBuffer.append(oneFrameMultiArray)
            } catch {
                continue
            }
        }
        
        if numAvailableFrames < observationsNeeded {
            for _ in 0..<(observationsNeeded - numAvailableFrames) {
                do {
                    let oneFrameMultiArray = try MLMultiArray(shape: [1, 3, 18], dataType: .double)
                    try resetMultiArray(oneFrameMultiArray)
                    multiArrayBuffer.append(oneFrameMultiArray)
                } catch {
                    continue
                }
            }
        }
        return MLMultiArray(concatenating: [MLMultiArray](multiArrayBuffer), axis: 0, dataType: .float)
    }
    
    func resetMultiArray(_ predictionWindow: MLMultiArray, with value: Double = 0.0) throws {
        let pointer = try UnsafeMutableBufferPointer<Double>(predictionWindow)
        pointer.initialize(repeating: value)
    }
    
    func storeObservation(_ observation: VNHumanBodyPoseObservation) {
        if posesWindow.count >= predictionWindowSize {
            posesWindow.removeFirst()
        }
        
        posesWindow.append(observation)
    }
    
    func processObservation(_ observation: VNHumanBodyPoseObservation) {
        do {
            let recognizedPoints = try observation.recognizedPoints(forGroupKey: .all)
//            resetInactivityTimer()
            // Convert the points and update poseView only if points are detected
            if recognizedPoints.isEmpty {
                delegate?.predictor(self, didFindNewRecognizedPoints: [])
            } else {
                let displayedPoints = recognizedPoints.map {
                    CGPoint(x: $0.value.x, y: 1 - $0.value.y)
                }
                delegate?.predictor(self, didFindNewRecognizedPoints: displayedPoints)
            }
        } catch {
            print("Error finding points")
        }
    }
}

class PoseView: UIView {
    
    var points: [CGPoint] = [] {
        didSet {
            DispatchQueue.main.async {
                self.setNeedsDisplay()
            }
        }
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        context.clear(rect)
        
        // Draw points
        context.setFillColor(UIColor.white.cgColor)
        context.setLineWidth(10.0)
        
        for point in points {
//            print(point)
            context.addEllipse(in: CGRect(x: point.x - 5, y: point.y - 5, width: 10, height: 10))
        }
        context.fillPath()
        
        // Draw selective gradient lines between points
        let armShoulderChestConnections: [(Int, Int)] = [
            (2, 3), (3, 4), // Right arm: right shoulder to right elbow, right elbow to right wrist
            (5, 6), (6, 7), // Left arm: left shoulder to left elbow, left elbow to left wrist
            (2, 5),         // Chest: right shoulder to left shoulder
            (1, 2), (1, 5)  // Chest: neck to right shoulder, neck to left shoulder
        ]
        
//        for (start, end) in armShoulderChestConnections {
//            if start < points.count && end < points.count {
//                drawGradientLine(context: context, start: points[start], end: points[end])
//            }
//        }
    }
    
    private func drawGradientLine(context: CGContext, start: CGPoint, end: CGPoint) {
        let gradientColors = [UIColor.red.cgColor, UIColor.blue.cgColor] as CFArray
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        guard let gradient = CGGradient(colorsSpace: colorSpace, colors: gradientColors, locations: [0, 1]) else { return }
        
        context.saveGState()
        
        let path = CGMutablePath()
        path.move(to: start)
        path.addLine(to: end)
        
        context.addPath(path)
        context.replacePathWithStrokedPath()
        context.clip()
        
        let startPoint = start
        let endPoint = end
        
        context.drawLinearGradient(gradient, start: startPoint, end: endPoint, options: [])
        context.restoreGState()
    }
}
