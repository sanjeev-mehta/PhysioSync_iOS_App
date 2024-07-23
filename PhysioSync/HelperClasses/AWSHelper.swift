//
//  AWSHelper.swift
//  PhysioSync
//
//  Created by Gurmeet Singh on 2024-06-23.
//

import Foundation
import AWSS3
import AWSCore

class AWSHelper {
    
    static let shared = AWSHelper()
    
    private init() {
        let accessKey = UserDefaults.standard.value(forKey: "access_key") as? String ?? ""
        let secretKey = UserDefaults.standard.value(forKey: "secret_key") as? String ?? ""

        let credentialsProvider = AWSStaticCredentialsProvider(accessKey: accessKey, secretKey: secretKey)
        let configuration = AWSServiceConfiguration(region: .USWest1, credentialsProvider: credentialsProvider)
        AWSServiceManager.default().defaultServiceConfiguration = configuration
    }
    
    func uploadImageFile(url: URL, fileName: String, progress: @escaping (Float) -> Void, completion: @escaping (Bool, String?, Error?) -> Void) {
        let expression = AWSS3TransferUtilityUploadExpression()
        expression.progressBlock = { (task, awsProgress) in
            DispatchQueue.main.async {
                let progressPercentage = Float(awsProgress.fractionCompleted)
                progress(progressPercentage * 100) // convert to percentage
            }
        }
        
        // Set ACL to public-read
//        expression.setValue("public-read", forRequestParameter: "x-amz-acl")
        
        let completionHandler: AWSS3TransferUtilityUploadCompletionHandlerBlock = { (task, error) -> Void in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                completion(false, nil, error)
            } else {
                let imageUrl = "https://\(task.bucket).s3.us-west-1.amazonaws.com/\(task.key)"
                print("Upload successful, image URL: \(imageUrl)")
                completion(true, imageUrl, nil)
            }
        }
        
        let transferUtility = AWSS3TransferUtility.default()
        
        transferUtility.uploadFile(url, bucket: "physiosync", key: fileName, contentType: "image/jpeg", expression: expression, completionHandler: completionHandler).continueWith { (task) -> AnyObject? in
            if let error = task.error {
                print("Error: \(error.localizedDescription)")
                completion(false, nil, error)
            }
            if task.result != nil {
                print("Upload started...")
            }
            return nil
        }
    }
    
    // Upload video file
      func uploadVideoFile(url: URL, fileName: String, progress: @escaping (Float) -> Void, completion: @escaping (Bool, String?, Error?) -> Void) {
          let expression = AWSS3TransferUtilityUploadExpression()
          expression.progressBlock = { (task, awsProgress) in
              DispatchQueue.main.async {
                  let progressPercentage = Float(awsProgress.fractionCompleted)
                  progress(progressPercentage * 100)
              }
          }
          
          let completionHandler: AWSS3TransferUtilityUploadCompletionHandlerBlock = { (task, error) -> Void in
              if let error = error {
                  print("Error: \(error.localizedDescription)")
                  completion(false, nil, error)
              } else {
                  let videoUrl = "https://\(task.bucket).s3.us-west-1.amazonaws.com/\(task.key)"
                  print("Upload successful, video URL: \(videoUrl)")
                  completion(true, videoUrl, nil)
              }
          }
          
          let transferUtility = AWSS3TransferUtility.default()
          
          transferUtility.uploadFile(url, bucket: "physiosync", key: fileName, contentType: "video/mov", expression: expression, completionHandler: completionHandler).continueWith { (task) -> AnyObject? in
              if let error = task.error {
                  print("Error: \(error.localizedDescription)")
                  completion(false, nil, error)
              }
              if task.result != nil {
                  print("Upload started...")
              }
              return nil
          }
      }
}
