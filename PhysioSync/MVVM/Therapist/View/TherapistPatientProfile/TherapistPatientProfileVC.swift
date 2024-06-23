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
    @IBOutlet var shimmerEffectViews: [UIView]!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var ageLbl:UILabel!
    @IBOutlet weak var profileImgView: UIImageView!
    @IBOutlet weak var historyLbl: UILabel!
    @IBOutlet weak var startDateLbl : UILabel!
    @IBOutlet weak var endDateLbl : UILabel!
    
    // MARK: - Variables
//    var cellCount = 3
    var patientData: TherapistPatientData?    
    
    // MARK: - instances
    private let vm = TherapistPatientProfileViewModel.shareInstance

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        callApi()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setHeader("Therapist Profile", isRightBtn: false) {
            self.dismissOrPopViewController()
        } rightButtonAction: {
            
        }
    }
    
    func callApi() {
        if let data = self.patientData {
            getAssignedExerciseApi(patientId: data.Id)
        }
    }
    
    func setData() {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 10) {
                self.tableHeightConstraint.constant = self.tableView.contentSize.height
                if let data = self.vm.therapistPatientprofileModel?.data?[0].patientId {
                    self.nameLbl.text = "Name: " + data.firstName + " " + data.lastName
                    self.ageLbl.text = "Age: " + "\(self.calculateAge(dob: data.dateOfBirth))"
                    self.profileImgView.sd_setImage(with: URL(string: data.profilePhoto)!)
                    self.historyLbl.text = data.medicalHistory
                    
                }
                if let data = self.vm.therapistPatientprofileModel?.data?[0] {
                    self.startDateLbl.text = self.formatDateString(date: data.startDate)
                    
                    self.endDateLbl.text = self.formatDateString(date: data.endDate)
                    
                }
                self.tableView.reloadData() // Reload table view data

            }
        }
    }
    
    // MARK: - get Assigned Exercise
    
    func getAssignedExerciseApi(patientId: String) {
        vm.getAssignedExercise(vc: self, patientId: patientId) { status in
            DispatchQueue.main.async {
//                self.isLoading = false
                self.setData()
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
        let formattedDate = formatDateString(date: "2023-06-01T00:00:00.000Z")
        print(formattedDate)
        return (dateComponent.year!)
       
    }
    
    // MARK: - date format
    
    //MARK: - NEED TO CHECK DATE FUNCTION
    
        
        func formatDateString(date: String) -> String {
            let inputFormatter = DateFormatter()
            inputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXX"
            
            let dateOfBirth = inputFormatter.date(from: date)!
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "dd MMMM yyyy"
            let formattedDate = outputFormatter.string(from: dateOfBirth)
            return formattedDate
        }
   
    
    // MARK: -  Button Methods
    @IBAction func viewPatientInfoBtnActn(_ sender: UIButton) {
        if let vc = self.switchController(.therapistPatientStep1VC , .therapistPatientProfile) as? TherapistPatientStep1VC {
            self.pushOrPresentViewController(vc, true)
        }
    }
    
}
extension TherapistPatientProfileVC: UITableViewDelegate ,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return 4
       // return assignedExercises.count

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ScheduleTableTVC", for: indexPath) as! ScheduleTableTVC
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
       return 60
    }
}
