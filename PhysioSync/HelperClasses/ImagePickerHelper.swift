//
//  ImagePickerHelper.swift
//  PhysioSync
//
//  Created by Gurmeet Singh on 2024-06-22.
//

import UIKit
import Photos
import AVKit

class ImagePickerHelper: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    private var imagePickerController: UIImagePickerController!
    private weak var viewController: UIViewController?
    private var completion: ((UIImage?) -> Void)?
    private var videoCompletion: ((URL?, String?) -> Void)?
    
    // Initialization
    init(viewController: UIViewController) {
        self.viewController = viewController
        super.init()
        self.imagePickerController = UIImagePickerController()
        self.imagePickerController.delegate = self
    }

    // Show Image Picker
    func showImagePicker(sourceType: UIImagePickerController.SourceType, completion: @escaping (UIImage?) -> Void) {
        self.completion = completion
        
        // Check if the source type is available
        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
            self.imagePickerController.sourceType = sourceType
            self.imagePickerController.mediaTypes = ["public.image"]
            // Present the image picker controller
            self.viewController?.present(self.imagePickerController, animated: true, completion: nil)
        } else {
            // Handle the error (e.g., show an alert)
            self.completion?(nil)
        }
    }
    
    // Show Video Picker
     func showVideoPicker(sourceType: UIImagePickerController.SourceType, completion: @escaping (URL?, String?) -> Void) {
         self.videoCompletion = completion
         self.completion = nil

         // Check if the source type is available
         if UIImagePickerController.isSourceTypeAvailable(sourceType) {
             self.imagePickerController.sourceType = sourceType
             self.imagePickerController.mediaTypes = ["public.movie"]
             self.imagePickerController.allowsEditing = false
             self.imagePickerController.videoQuality = .typeHigh
             // Present the image picker controller
             self.viewController?.present(self.imagePickerController, animated: true, completion: nil)
         } else {
             // Handle the error (e.g., show an alert)
             self.videoCompletion?(nil, nil)
         }
     }
    
    func showCustomVideoPicker(from viewController: UIViewController, completion: @escaping (URL?) -> Void) {
        let status = PHPhotoLibrary.authorizationStatus()
        
        if status == .authorized {
            presentVideoPicker(viewController: viewController, completion: completion)
        } else {
            PHPhotoLibrary.requestAuthorization { newStatus in
                DispatchQueue.main.async {
                    if newStatus == .authorized {
                        self.presentVideoPicker(viewController: viewController, completion: completion)
                    } else {
                        completion(nil)
                    }
                }
            }
        }
    }

    
    private func presentVideoPicker(viewController: UIViewController, completion: @escaping (URL?) -> Void) {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let fetchResult = PHAsset.fetchAssets(with: .video, options: fetchOptions)
        
        guard let asset = fetchResult.firstObject else {
            completion(nil)
            return
        }
        
        let options = PHVideoRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true
        
        PHImageManager.default().requestAVAsset(forVideo: asset, options: options) { (avAsset, audioMix, info) in
            guard let urlAsset = avAsset as? AVURLAsset else {
                completion(nil)
                return
            }
            
            // Debugging: Print the video URL and check file existence
            let videoURL = urlAsset.url
            print("Selected video URL: \(videoURL)")
            
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: videoURL.path) {
                print("File exists at path: \(videoURL.path)")
                completion(videoURL)
            } else {
                print("File does not exist at path: \(videoURL.path)")
                completion(nil)
            }
        }
    }

    // MARK: - UIImagePickerControllerDelegate Methods
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            self.completion?(image)
        } else if let videoURL = info[.mediaURL] as? URL {
            let fileName = videoURL.lastPathComponent
            self.videoCompletion?(videoURL, fileName)
        }
        
        self.viewController?.dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.completion?(nil)
        self.videoCompletion?(nil, nil)
        self.viewController?.dismiss(animated: true, completion: nil)
    }
}
