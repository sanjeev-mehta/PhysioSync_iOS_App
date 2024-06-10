//
//  TherapistNotificationVC.swift
//  PhysioSync
//
//  Created by Gurmeet Singh on 2024-06-10.
//

import UIKit

class TherapistNotificationVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var notificationView: UIView!
    @IBOutlet weak var acknowledgeView: UIView!
    @IBOutlet weak var replyView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        setNotificationView()
    }
    
    func setNotificationView() {
        acknowledgeView.addTopCornerRadius(radius: 16)
        replyView.clipsToBounds = true
        replyView.layer.cornerRadius = 16
        replyView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMinYCorner]
    }
    
    func openNotifcationView() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 10, options: .curveEaseInOut, animations: {
            self.notificationView.transform = CGAffineTransform.identity
            self.notificationView.alpha = 1.0
        }, completion: nil)
    }
    
    func closeNotifcationView() {
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 10, options: .curveEaseInOut, animations: {
            self.notificationView.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
            self.notificationView.alpha = 0.0
        }, completion: nil)
    }
    
    // MARK: - Buttons Actions
    @IBAction func cancelBtnActn(_ sender: UIButton) {
        sender.pressedAnimation {
            self.closeNotifcationView()
        }
    }
}

// MARK: - Table View DataSource and delegate methods
extension TherapistNotificationVC: UITableViewDelegate ,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationTVC", for: indexPath) as! NotificationTVC
        
        cell.watchVideoBtn.tag = indexPath.row
        cell.watchVideoBtn.addTarget(self, action: #selector(watchVideoBtnActn(_ :)), for: .touchUpInside)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    @objc func watchVideoBtnActn(_ sender: UIButton) {
        sender.pressedAnimation {
            self.openNotifcationView()
        }
    }
}
