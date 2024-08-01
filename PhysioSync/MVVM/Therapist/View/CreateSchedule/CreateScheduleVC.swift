//
//  CreateScheduleVC.swift
//  PhysioSync
//
//  Created by Sanjeev Mehta on 24/06/24.
//

import UIKit
import Fastis

class CreateScheduleVC: UIViewController {

    //MARK: - IBOutlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var fromDateLbl: UILabel!
    @IBOutlet weak var toDateLbl: UILabel!
    @IBOutlet weak var addMoreExerciseBtn: UIButton!
    
    //MARK: - Variables
    var exerciseModel = [SingleExerciseModel]()
    var patientId = ""
    let vm = CreateScheduleViewModel.shareInstance
    var from: String?
    var to: String?
    
    var selectedFromDate: Date?
    var selectedToDate: Date?
    var isEdit = false
    var id = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setHeader("Create Schedule", isRightBtn: false) {
            self.dismissOrPopViewController()
        } rightButtonAction: { }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if exerciseModel.count == 0 {
            self.collectionView.isHidden = true
            self.addMoreExerciseBtn.isHidden = true
        } else {
            self.collectionView.isHidden = false
            self.addMoreExerciseBtn.isHidden = false
        }
        self.fromDateLbl.text = from ?? "---"
        self.toDateLbl.text = to ?? "---"
    }
    
    // MARK: - Open Calendar
    func openCalendar() {
        let fastisController = FastisController(mode: .range)
        fastisController.title = "Choose range"
        fastisController.minimumDate = Date()
        fastisController.allowToChooseNilDate = true
        if let fromDate = self.from, let toDate = to {
            selectedFromDate = parseDate(from: fromDate)
            selectedToDate = parseDate(from: toDate)
        }
        
        if let fromDate = selectedFromDate, let toDate = selectedToDate {
            fastisController.initialValue = FastisRange(from: fromDate, to: toDate)
        }
        
        fastisController.dismissHandler = {
        }
        fastisController.doneHandler = { [self] value in
            self.selectedFromDate = value!.fromDate
            self.selectedToDate = value?.toDate
            self.fromDateLbl.text = "\(dateFormat(value!.fromDate))"
            self.toDateLbl.text = "\(dateFormat(value!.toDate))"
            self.from = "\(dateFormat(value!.fromDate))"
            self.to = "\(dateFormat(value!.toDate))"
        }
        fastisController.present(above: self)
    }
    
    //MARK: - Parse Date
    func parseDate(from string: String?) -> Date? {
           guard let dateString = string else { return nil }
           let formatter = DateFormatter()
           formatter.dateFormat = "yyyy-MM-dd"
           return formatter.date(from: dateString)
       }
    
    //MARK: - Date Formatter
    func dateFormat(_ value: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: value)
    }
    
    //MARK: - callApi
    func callApi() {
        if fromDateLbl.text == "---" || toDateLbl.text == "---" {
            self.displayAlert(title: "Warning", msg: "Please select date", ok: "Ok")
        } else if exerciseModel.count == 0 {
            self.displayAlert(title: "Warning", msg: "Please select exercise", ok: "Ok")
        } else {
            var ids = [String]()
            for i in exerciseModel {
                ids.append(i.id)
            }
           
            if isEdit {
                let parm: [String: Any] = ["exercise_ids": ids, "start_date": fromDateLbl.text!, "end_date": toDateLbl.text!]
                vm.updateExercise(self, id: id ,with: parm) { _ in
                    self.dismissOrPopViewController()
                }
            } else {
                let parm: [String: Any] = ["exercise_ids": ids, "patient_id": patientId, "start_date": fromDateLbl.text!, "end_date": toDateLbl.text!]
                vm.callAssignExercise(self, with: parm) { status in
                    self.dismissOrPopViewController()
                }
            }
        }
    }
    
    @IBAction func selectDateRangeBtnActn(_ sender: UIButton) {
        openCalendar()
    }
    
    @IBAction func selectExerciseBtnActn(_ sender: UIButton) {
        if let vc = self.switchController(.exerciseCategoryVC, .therapistTab) as? ExerciseCategoryVC {
            vc.isCreateSchedule = true
            vc.delegate = self
            var arr = [SingleExerciseModel2]()
            for i in self.exerciseModel {
                arr.append(SingleExerciseModel2(videoTitle: i.videoTitle, categoryName: i.categoryName, categoryId: i.categoryId, description: i.description, id: i.id, videoUrl: i.videoUrl, therapistId: i.therapistId, version: i.version, videoThumbnail: i.video_thumbnail))
            }
            vc.selectedData = arr
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func saveBtnActn(_ sender: UIButton) {
        callApi()
    }
}

extension CreateScheduleVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return exerciseModel.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CreateScheduleCVC", for: indexPath) as! CreateScheduleCVC
        let data = exerciseModel[indexPath.item]
        cell.imgView.setImage(with: data.video_thumbnail)
        cell.imgView.contentMode = .scaleAspectFill
        cell.exerciseNameLbl.text = data.videoTitle
        cell.crossBtn.tag = indexPath.item
        cell.crossBtn.addTarget(self, action: #selector(crossBtnActn(_:)), for: .touchUpInside)
        return cell
    }
    
    @objc func crossBtnActn(_ sender: UIButton) {
        let tag = sender.tag
        exerciseModel.remove(at: tag)
        self.collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: collectionView.bounds.width/2, height: 200)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
        
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        // MARK: -  Apply animation
        UIView.animate(withDuration: 0.5) {
            cell.alpha = 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    }

}

extension CreateScheduleVC: SelectedExerciseData {
    func selectedExerciseData(data: [SingleExerciseModel]) {
        var existingIds = Set(exerciseModel.map { $0.id })
           
           for i in data {
               if !existingIds.contains(i.id) {
                   self.exerciseModel.append(i)
                   existingIds.insert(i.id)
               }
           }
           self.collectionView.reloadData()
    }
}
