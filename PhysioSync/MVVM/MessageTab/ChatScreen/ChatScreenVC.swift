//
//  ChatScreenVC.swift
//  PhysioSync
//
//  Created by Gurmeet Singh on 2024-06-07.
//

import UIKit
import SwiftyJSON

class ChatScreenVC: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTf: UITextField!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var backImgVW: UIImageView!
    @IBOutlet weak var mediaView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var sendView: UIView!
    @IBOutlet weak var cancelBtn: UIButton!
    
    // MARK: - variables
    let chatVM = ChatViewModel.shareInstance
    var recieverId = ""
    var name = ""
    var profileImgLink = ""
    var currentUserId = ""
    var isPatient = false
    var timer: Timer?
    var imagePicker: ImagePickerHelper?
    var videoPicker: ImagePickerHelper?
    private var videoPlayer: CustomVideoPlayer?
    let awsHelper = AWSHelper.shared
    private var isScrollFirstTime = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        chatVM.delegate = self
        self.imagePicker = ImagePickerHelper(viewController: self)
        self.videoPicker = ImagePickerHelper(viewController: self)
        self.closeMediaView()
        
        if UserDefaults.standard.getUsernameToken() == "" {
            self.isPatient = true
            self.nameLbl.text = UserDefaults.standard.getTherapistName()
            self.profileImg.setImage(with: UserDefaults.standard.getTherapistProfileImage())
            self.currentUserId = UserDefaults.standard.getPatientLoginId()
            self.recieverId = UserDefaults.standard.getTherapistId()
            self.backBtn.isHidden = true
            self.backImgVW.isHidden = true
            chatVM.currentUser = currentUserId
            timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
                PatientHomeVC.socketHandler.fetchPreviousMessage(self.currentUserId, self.recieverId)
            }
        } else {
            self.currentUserId = UserDefaults.standard.getTherapistId()
            chatVM.currentUser = currentUserId
            self.nameLbl.text = name
            self.profileImg.setImage(with: profileImgLink)
            self.isPatient = false
            timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
                TherapistHomeVC.socketHandler.fetchPreviousMessage(self.currentUserId, self.recieverId)
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.timer?.invalidate()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        chatVM.readMessage(isPatienSide: isPatient)
    }
    
    private func setupVideoPlayer(url: URL?) {
        videoPlayer = CustomVideoPlayer(frame: videoView.bounds)
        videoPlayer?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        if let videoPlayer = videoPlayer {
            videoView.addSubview(videoPlayer)
            if let videoURL = url {
                videoPlayer.configure(url: videoURL)
                videoPlayer.play()
            }
        }
    }
    
    func sendMessage() {
        let newMessage = ChatModel(
            _id: (JSON(rawValue: UUID().uuidString) ?? "").rawValue as! String,
            createdAt: Date().iso8601String,
            is_read: false,
            message_text:  messageTf.text!,
            receiver_id: recieverId,
            sender_id: currentUserId,
            updatedAt: Date().iso8601String,
            is_media: false
        )
        
        // Append the new message to the local array
        chatVM.chatArr.append(newMessage)
        tableView.reloadData()
        if isPatient {
            PatientHomeVC.socketHandler.sendMessage(userId: currentUserId, receiverId: recieverId, message: messageTf.text!, isMedia: false)
        } else {
            TherapistHomeVC.socketHandler.sendMessage(userId: currentUserId, receiverId: recieverId, message: messageTf.text!, isMedia: false)
        }
        messageTf.text = ""
        self.tableView.scrollToRow(at: IndexPath(row: self.chatVM.chatArr.count - 1, section: 0), at: .bottom, animated: false)
    }
    
    func sendMediaMessage(isVideo: Bool, url: String, isAwsUpload: Bool) {
        if !isAwsUpload {
            let newMessage = ChatModel(
                _id: (JSON(rawValue: UUID().uuidString) ?? "").rawValue as! String,
                createdAt: Date().iso8601String,
                is_read: false,
                message_text:  messageTf.text ?? "",
                receiver_id: recieverId,
                sender_id: currentUserId,
                updatedAt: Date().iso8601String,
                media_link: url,
                is_media: true,
                is_video: isVideo
            )
            
            chatVM.chatArr.append(newMessage)
            tableView.reloadData()
        } else {
            DispatchQueue.main.async { [self] in
                if self.isPatient {
                    PatientHomeVC.socketHandler.sendMediaMessage(userId: currentUserId, receiverId: recieverId, message: messageTf.text ?? "", isMedia: true, media_link: url, is_video: isVideo)
                } else {
                    TherapistHomeVC.socketHandler.sendMediaMessage(userId: currentUserId, receiverId: recieverId, message: messageTf.text ?? "", isMedia: true, media_link: url, is_video: isVideo)
                }
            }
        }
    }
    
    func uploadImage(profileImage: UIImage?,completion: @escaping(String) -> ()) {
        guard let image = profileImage, let imageData = image.jpegData(compressionQuality: 0.8) else { return }
        let tempDirectory = NSTemporaryDirectory()
        let fileName = UUID().uuidString + ".jpg"
        let fileURL = URL(fileURLWithPath: tempDirectory).appendingPathComponent(fileName)
        self.sendMediaMessage(isVideo: false, url: "\(fileURL)", isAwsUpload: false)
        
        do {
            try imageData.write(to: fileURL)
            AWSHelper.shared.uploadImageFile(url: fileURL, fileName: fileName, progress: { progress in
                if let index = self.chatVM.chatArr.firstIndex(where: { $0.media_link == "\(fileURL)" }) {
                    self.chatVM.chatArr[index].progress = Float(progress)
                    DispatchQueue.main.async {
                        self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
                    }
                }
                print("Upload Progress: \(progress)%")
            }) { success, imageUrl, error in
                if success {
                    print("File uploaded successfully, URL: \(imageUrl ?? "")")
                    completion(imageUrl!)
                } else if let error = error {
                    print("Error uploading file: \(error.localizedDescription)")
                }
            }
        } catch {
            print("Error saving image: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Buttons Action
    @IBAction func backBtnActn(_ sender: UIButton) {
        self.dismissOrPopViewController()
    }
    
    @IBAction func sendBtnActn(_ sender: UIButton) {
        if messageTf.text != "" {
            sendMessage()
        } else {
            // show alert
        }
    }
    
    @IBAction func selectMediaBtnActn(_ sender: UIButton) {
        self.openSheet(sender: sender)
    }
    
    @IBAction func closeMediaViewBtnActn(_ sender: UIButton) {
        sender.pressedAnimation {
            self.videoPlayer?.pause()
            self.closeMediaView()
        }
    }
    
    @IBAction func sendMediaBtnActn(_ sender: UIButton) {
        self.closeMediaView()
        self.uploadImage(profileImage: self.imageView.image) { url in
            self.sendMediaMessage(isVideo: false, url: url, isAwsUpload: true)
        }
    }
    
    // MARK: - TableView delegate & DataSource functions
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        print(chatVM.chatArr.count)
        return chatVM.chatArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = chatVM.chatArr[indexPath.row]
        if data.sender_id == currentUserId {
            
            if data.is_media {
                let cell = tableView.dequeueReusableCell(withIdentifier: "RightVideoChatTVC", for: indexPath) as! RightVideoChatTVC
                cell.selectionStyle = .none
                self.setCornerRadius(radius: 16, view: cell.bgView, isLeftCell: false)
                cell.dateLbl.text = data.time
                if !data.is_video {
                    cell.playBtn.isHidden = true
                    cell.imgView.setImage(with: data.media_link)
                    cell.visualEffectView.isHidden = true
                } else {
                    cell.visualEffectView.isHidden = false
                    cell.playBtn.isHidden = false
                    cell.imgView.image = UIImage(named: "videoBg")!
                }
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "RightChatTVC", for: indexPath) as! RightChatTVC
                cell.selectionStyle = .none
                cell.messageLbl.text = data.message_text
                self.setCornerRadius(radius: 16, view: cell.bgView, isLeftCell: false)
                cell.dateLbl.text = data.time
                cell.dateLbl.textColor = UIColor.white
                return cell
            }
        } else {
            if data.is_media {
                let cell = tableView.dequeueReusableCell(withIdentifier: "LeftVideoChatTVC", for: indexPath) as! LeftVideoChatTVC
                cell.selectionStyle = .none
                self.setCornerRadius(radius: 16, view: cell.bgView, isLeftCell: true)
                cell.dateLbl.text = data.time
                if !data.is_video {
                    cell.playBtn.isHidden = true
                    cell.imgView.setImage(with: data.media_link)
                    cell.visualEffectView.isHidden = true
                } else {
                    cell.visualEffectView.isHidden = false
                    cell.playBtn.isHidden = false
                    cell.imgView.image = UIImage(named: "videoBg")!
                }
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "LeftChatTVC", for: indexPath) as! LeftChatTVC
                cell.selectionStyle = .none
                cell.messageLbl.text = data.message_text
                self.setCornerRadius(radius: 16, view: cell.bgView, isLeftCell: true)
                cell.dateLbl.text = data.time
                return cell
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let data = chatVM.chatArr[indexPath.row]
        if data.is_media {
            return 200
        } else {
            return UITableView.automaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = chatVM.chatArr[indexPath.row]
        if data.is_media {
            if data.is_video {
                self.setupVideoPlayer(url: URL(string: data.media_link)!)
                self.openMediaView(isImage: false, isSendBtn: true, cancelTxt: "Close")

            } else {
                self.imageView.setImage(with: data.media_link)
                self.openMediaView(isImage: true, isSendBtn: true, cancelTxt: "Close")
            }
        }
    }
    // MARK: - Corner radius
    
    func setCornerRadius(radius: CGFloat, view: UIView, isLeftCell: Bool) {
        view.clipsToBounds = true
        view.layer.cornerRadius = radius
        if isLeftCell {
            view.layer.maskedCorners = [.layerMaxXMinYCorner ,.layerMaxXMaxYCorner,.layerMinXMaxYCorner ]
            
        } else {
            view.layer.maskedCorners = [.layerMaxXMinYCorner,.layerMinXMinYCorner, .layerMinXMaxYCorner,]
        }
        
    }
}

extension ChatScreenVC: ChatViewModelDelegate {
    func didReceiveMessages() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
            if self.chatVM.chatArr.count != 0 {
                if self.isScrollFirstTime == 0 {
                    self.isScrollFirstTime = 1
                    self.tableView.scrollToRow(at: IndexPath(row: self.chatVM.chatArr.count - 1, section: 0), at: .bottom, animated: false)
                }
               
            }
        }
    }
}

extension Date {
    var iso8601String: String {
        let formatter = ISO8601DateFormatter()
        return formatter.string(from: self)
    }
}

extension ChatScreenVC: SocketIOHandlerDelegate {
    
    func didReceiveMessage() {
        self.tableView.reloadData()
        chatVM.readMessage(isPatienSide: isPatient)
    }
    
    func updatePatientList() {
        
    }
    
    func fetchMessage(unreadCount: Int) {
        chatVM.readMessage(isPatienSide: isPatient)
    }
}

extension ChatScreenVC {
    // MARK: -  openActionSheet for select image
    
    func openSheet(sender: UIButton) {
        let actionSheet = UIAlertController(title: "Select Source", message: "", preferredStyle: .actionSheet)
        let imageAction = UIAlertAction(title: "Image", style: .default) { _ in
            self.openImageSheet(sender: sender)
        }
        
        let cameraAction = UIAlertAction(title: "Video", style: .default) { _ in
            self.openCameraSheet(sender: sender)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        actionSheet.addAction(imageAction)
        actionSheet.addAction(cameraAction)
        actionSheet.addAction(cancelAction)
        
        // For iPad compatibility
        if let popoverController = actionSheet.popoverPresentationController {
            popoverController.sourceView = sender
            popoverController.sourceRect = sender.bounds
        }
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    func openImageSheet(sender: UIButton) {
        let actionSheet = UIAlertController(title: "Select Image", message: "Choose a source", preferredStyle: .actionSheet)
        
        let photoLibraryAction = UIAlertAction(title: "Photo Library", style: .default) { _ in
            self.imagePicker?.showImagePicker(sourceType: .photoLibrary) { image in
                if let selectedImage = image {
                    self.imageView.image = selectedImage
                    self.openMediaView(isImage: true)
                    } else {
                    // Handle the case where no image was selected
                    print("Image selection canceled.")
                }
            }
        }
        
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { _ in
            self.imagePicker?.showImagePicker(sourceType: .camera) { image in
                if let capturedImage = image {
                    self.imageView.image = capturedImage
                    self.openMediaView(isImage: true)
                } else {
                    // Handle the case where no image was captured
                    print("Image capture canceled.")
                }
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        actionSheet.addAction(photoLibraryAction)
        actionSheet.addAction(cameraAction)
        actionSheet.addAction(cancelAction)
        
        // For iPad compatibility
        if let popoverController = actionSheet.popoverPresentationController {
            popoverController.sourceView = sender
            popoverController.sourceRect = sender.bounds
        }
        
        self.present(actionSheet, animated: true, completion: nil)
    }

    func openCameraSheet(sender: UIButton) {
        let actionSheet = UIAlertController(title: "Select Video", message: "Choose a source", preferredStyle: .actionSheet)
        
        let photoLibraryAction = UIAlertAction(title: "Photo Library", style: .default) { _ in
            self.videoPicker?.showVideoPicker(sourceType: .photoLibrary, completion: { url, name in
                print(url, name)
                if let url = url {
                    self.sendMediaMessage(isVideo: true, url: "\(url)", isAwsUpload: false)

                    self.awsHelper.uploadVideoFile(url: url, fileName: name ?? "video") { progress in
                        
                    } completion: { success, url, err in
                        if err != nil {
                            self.displayAlert(title: "Error", msg: err?.localizedDescription, ok: "Ok")
                        } else {
                            self.sendMediaMessage(isVideo: true, url: url!, isAwsUpload: true)
                        }
                    }

                } else {
                    
                }
            })
        }
        
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { _ in
            self.videoPicker?.showVideoPicker(sourceType: .camera) { url, name in
                print(url, name)
                if let url = url {
                    self.sendMediaMessage(isVideo: true, url: "\(url)", isAwsUpload: false)

                    self.awsHelper.uploadVideoFile(url: url, fileName: name ?? "video") { progress in
                        
                    } completion: { success, url, err in
                        if err != nil {
                            self.displayAlert(title: "Error", msg: err?.localizedDescription, ok: "Ok")
                        } else {
                            self.sendMediaMessage(isVideo: true, url: url!, isAwsUpload: true)
                        }
                    }
                } else {}
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        actionSheet.addAction(photoLibraryAction)
        actionSheet.addAction(cameraAction)
        actionSheet.addAction(cancelAction)
        
        // For iPad compatibility
        if let popoverController = actionSheet.popoverPresentationController {
            popoverController.sourceView = sender
            popoverController.sourceRect = sender.bounds
        }
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    func openMediaView(isImage: Bool, isSendBtn: Bool = false, cancelTxt: String = "Cancel") {
        if isImage {
            self.imageView.isHidden = false
            self.view.bringSubviewToFront(self.imageView)
        } else {
            self.imageView.isHidden = true
        }
        self.sendView.isHidden = isSendBtn
        self.cancelBtn.setTitle(cancelTxt, for: .normal)
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 10, options: .curveEaseInOut, animations: {
            self.mediaView.transform = CGAffineTransform.identity
            self.mediaView.alpha = 1.0
            self.view.bringSubviewToFront(self.mediaView)
        }, completion: nil)
    }
    
    func closeMediaView() {
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 10, options: .curveEaseInOut, animations: {
            self.mediaView.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
            self.mediaView.alpha = 0.0
        }, completion: nil)
    }
}
