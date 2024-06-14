//
//  TherapistPatientProfileVC.swift
//  PhysioSync
//
//  Created by Gurmeet Singh on 2024-06-10.
//

import UIKit

class TherapistPatientProfileVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableHeightConstraint: NSLayoutConstraint!
    @IBOutlet var shifferEffectViews: [UIView]!
    
    var cellCount = 6
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        setUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setHeader("Therapist Profile", isRightBtn: false) {
            self.dismissOrPopViewController()
        } rightButtonAction: {
            
        }
    }
    
    func setUI() {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 10) {
                self.tableHeightConstraint.constant = self.tableView.contentSize.height
            }
        }
    }
    
    // MARK: -  Button Methods
    @IBAction func viewPatientInfoBtnActn(_ sender: UIButton) {
        if let vc = self.switchController(.therapistPatientInfoVC , .therapistPatientProfile) as? TherapistPatientInfoVC {
            self.pushOrPresentViewController(vc, true)
        }
    }
    
}
extension TherapistPatientProfileVC: UITableViewDelegate ,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return cellCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "scheduleCell", for: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
       return 40
    }
}
