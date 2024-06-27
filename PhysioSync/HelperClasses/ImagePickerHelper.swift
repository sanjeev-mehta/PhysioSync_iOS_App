//
//  ImagePickerHelper.swift
//  PhysioSync
//
//  Created by Gurmeet Singh on 2024-06-22.
//

import UIKit
import Photos

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
             
             // Present the image picker controller
             self.viewController?.present(self.imagePickerController, animated: true, completion: nil)
         } else {
             // Handle the error (e.g., show an alert)
             self.videoCompletion?(nil, nil)
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
