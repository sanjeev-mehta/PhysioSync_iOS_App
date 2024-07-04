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
    @IBOutlet var shadowViews: [UIView]!
    @IBOutlet var scheduleViews: [UIView]!
    @IBOutlet weak var scheduleNotFoundView: UIView!
    
    // MARK: - Variables
//    var cellCount = 3
    var patientData: TherapistPatientData?    
    
    // MARK: - instances
    private let vm = TherapistPatientProfileViewModel.shareInstance

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        for i in shadowViews {
            i.addShadow()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        callApi()
        self.setHeader("Patient Profile", isRightBtn: false) {
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
            UIView.animate(withDuration: 0.5) {
                print(self.vm.therapistPatientprofileModel?[0])
                if let data = self.vm.therapistPatientprofileModel?[0].data?.patient {
                    self.nameLbl.text = data.firstName + " " + data.lastName
                    self.ageLbl.text = "Age: " + "\(self.calculateAge(dob: data.dateOfBirth))"
                    self.profileImgView.sd_setImage(with: URL(string: data.profilePhoto)!)
                    self.historyLbl.text = data.medicalHistory
                    
                }
                if let data = self.vm.therapistPatientprofileModel?[0].data {
                    if data.exercise?.count != 0 {
                        let exerciseData = data.exercise![0]
                        self.startDateLbl.text = exerciseData.startDate
                        self.endDateLbl.text = exerciseData.endDate
                        self.tableHeightConstraint.constant = CGFloat(60 * exerciseData.exerciseIds.count)
                        self.scheduleNotFoundView.isHidden = true
                        for i in self.scheduleViews {
                            i.isHidden = false
                        }
                        self.tableView.isHidden = false
                    } else {
                        self.tableView.isHidden = true
                        for i in self.scheduleViews {
                            i.isHidden = true
                        }
                        self.scheduleNotFoundView.isHidden = false
                        self.tableHeightConstraint.constant = 100
                    }
                }
                self.tableView.reloadData()

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
        dateFormater.dateFormat = "yyyy-MM-dd"
        let dateOfBirth = dateFormater.date(from: dob)
        let calender = Calendar.current
        let dateComponent = calender.dateComponents([.year, .month, .day], from: dateOfBirth!, to: Date())
        return (dateComponent.year!)
    }
    
    // MARK: - date format
    
    //MARK: - NEED TO CHECK DATE FUNCTION
    
        
        func formatDateString(date: String) -> String {
            let inputFormatter = DateFormatter()
            inputFormatter.dateFormat = "yyyy-MM-dd"
            
            let dateOfBirth = inputFormatter.date(from: date)!
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "dd MMMM yyyy"
            let formattedDate = outputFormatter.string(from: dateOfBirth)
            return formattedDate
        }
   
    
    // MARK: -  Button Methods
    @IBAction func viewPatientInfoBtnActn(_ sender: UIButton) {
        if let vc = self.switchController(.therapistPatientStep1VC , .therapistPatientProfile) as? TherapistPatientStep1VC {
            vc.isEdit = true
            vc.model = vm.therapistPatientprofileModel?[0].data?.patient
            self.pushOrPresentViewController(vc, true)
        }
    }
    
    @IBAction func setScheduleBtnActn(_ sender: UIButton) {
        if let vc = self.switchController(.createScheduleVC, .ScheduleTab) as? CreateScheduleVC {
            if sender.tag == 1 {
                vc.exerciseModel = vm.therapistPatientprofileModel![0].data!.exercise![0].exerciseIds
                vc.from = vm.therapistPatientprofileModel![0].data!.exercise![0].startDate
                vc.to = vm.therapistPatientprofileModel![0].data!.exercise![0].endDate

            }
            vc.patientId = vm.therapistPatientprofileModel?[0].data?.patient!.Id ?? ""
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
}
extension TherapistPatientProfileVC: UITableViewDelegate ,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vm.getCount()
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
