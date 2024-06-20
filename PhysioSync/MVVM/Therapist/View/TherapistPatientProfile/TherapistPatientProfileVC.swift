//
//  TherapistPatientProfileVC.swift
//  PhysioSync
//
//  Created by Gurmeet Singh on 2024-06-10.
//

import UIKit

class TherapistPatientProfileVC: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableHeightConstraint: NSLayoutConstraint!
    @IBOutlet var shifferEffectViews: [UIView]!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var ageLbl:UILabel!
    @IBOutlet weak var profileImgView: UIImageView!
    
    // MARK: - Variables
    var cellCount = 6
    var patientData: TherapistPatientData?
    
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
                if let data = self.patientData {
                    self.nameLbl.text = "Name: " + data.firstName + " " + data.lastName
                    self.ageLbl.text = "Age: " + "\(self.calculateAge(dob: data.dateOfBirth))"
                    self.profileImgView.sd_setImage(with: URL(string: data.profilePhoto)!)
                }
            }
        }
    }
    
    //MARK: - Age
    func calculateAge(dob: String) -> Int {
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXX"
        let dateOfBirth = dateFormater.date(from: dob)
        
        let calender = Calendar.current
        
        let dateComponent = calender.dateComponents([.year, .month, .day], from: dateOfBirth!, to: Date())
        
        return (dateComponent.year!)
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
       return 60
    }
}
