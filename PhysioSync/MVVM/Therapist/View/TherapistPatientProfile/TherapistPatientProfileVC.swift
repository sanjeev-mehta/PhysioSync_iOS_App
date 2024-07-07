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
    @IBOutlet weak var scrollView: UIScrollView!
    
    // MARK: - Variables
//    var cellCount = 3
    var patientData: TherapistPatientData?    
    
    // MARK: - instances
    private let vm = TherapistPatientProfileViewModel.shareInstance
    var id = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        scrollView.delegate = self
        for i in 0..<shadowViews.count {
            if i != 0 {
                shadowViews[i].addShadow()
            }
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
                if let data = self.vm.therapistPatientprofileModel?[0].data?.patient {
                    self.nameLbl.text = data.firstName + " " + data.lastName
                    self.ageLbl.text =  "\(self.calculateAge(dob: data.dateOfBirth))" + "Years"
                    self.profileImgView.sd_setImage(with: URL(string: data.profilePhoto)!)
                    self.historyLbl.text = data.injuryDetails
                    
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
        sender.pressedAnimation {
            if let vc = self.switchController(.therapistPatientStep1VC , .therapistPatientProfile) as? TherapistPatientStep1VC {
                vc.isEdit = true
                vc.model = self.vm.therapistPatientprofileModel?[0].data?.patient
                self.pushOrPresentViewController(vc, true)
            }
        }
    }
    
    @IBAction func setScheduleBtnActn(_ sender: UIButton) {
        sender.pressedAnimation {
            if let vc = self.switchController(.createScheduleVC, .ScheduleTab) as? CreateScheduleVC {
                if sender.tag == 1 {
                    vc.exerciseModel = self.vm.therapistPatientprofileModel![0].data!.exercise![0].exerciseIds
                    vc.from = self.vm.therapistPatientprofileModel![0].data!.exercise![0].startDate
                    vc.to = self.vm.therapistPatientprofileModel![0].data!.exercise![0].endDate
                    vc.isEdit = true
                } else {
                    vc.isEdit = false
                }
                vc.id = self.vm.therapistPatientprofileModel![0].data!.exercise![0].Id
                vc.patientId = self.vm.therapistPatientprofileModel?[0].data?.patient!.Id ?? ""
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    @IBAction func phoneBtnActn(_ sender: UIButton) {
        sender.pressedAnimation {
            if let phoneURL = URL(string: "tel://\(self.vm.therapistPatientprofileModel?[0].data?.patient?.phone_no ?? "1234567890")") {
                if UIApplication.shared.canOpenURL(phoneURL) {
                    UIApplication.shared.open(phoneURL, options: [:], completionHandler: nil)
                } else {
                    self.displayAlert(title: "Error", msg: "Your device cannot make phone calls.", ok: "OK")
                }
            }
        }
    }
    
    @IBAction func messageBtnActn(_ sender: UIButton) {
        sender.pressedAnimation {
            if let vc = self.switchController(.chatVC, .messageTab) as? ChatScreenVC {
                vc.isPatient = false
                if let data = self.vm.therapistPatientprofileModel?[0].data?.patient {
                    vc.name = data.firstName + " " + data.lastName
                    vc.profileImgLink = data.profilePhoto
                    vc.recieverId = data.Id
                }
                self.pushOrPresentViewController(vc, true)
            }
        }
    }
}

extension TherapistPatientProfileVC: UITableViewDelegate ,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vm.getCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ScheduleTableTVC", for: indexPath) as! ScheduleTableTVC
        vm.setCategoryCell(cell, index: indexPath.row)
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
       return 60
    }
}

extension TherapistPatientProfileVC: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print(scrollView.contentOffset.y)
        if scrollView.contentOffset.y.isLess(than: 0.0) {
            scrollView.contentOffset.y = -40
        }
    }
}
