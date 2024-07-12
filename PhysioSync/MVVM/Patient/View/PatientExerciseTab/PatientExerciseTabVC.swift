//
//  PatientExerciseTabVC.swift
//  PhysioSync
//
//  Created by Sanjeev Mehta on 07/06/24.
//

import UIKit
import Hero

class PatientExerciseTabVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    let vm = PatientHomeViewModel.shareInstance
    
    private var isLoading = true {
        didSet {
            tableView.isUserInteractionEnabled = !isLoading
            tableView.reloadData()
        }
    }
    private var cellCount = 3
    
    override func viewDidLoad() {
        super.viewDidLoad()
        isLoading = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.isLoading = false
        }
    }
    
}

extension PatientExerciseTabVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isLoading {
            return 3
        } else {
            return vm.assignExerciseCount(.assigned)
        }
       
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PatientExerciseTabTVC", for: indexPath) as! PatientExerciseTabTVC
        cell.selectionStyle = .none
        cell.imgView.addTopCornerRadius(radius: 16)
        cell.bottomView.addBottomCornerRadius(radius: 16)
        cell.bgView.layer.cornerRadius = 16
        cell.bgView.addShadow()
        if !isLoading {
            vm.setUpTableCell(cell, .assigned, indexPath.row)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 300
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // Initial state for the animation
        cell.setTemplateWithSubviews(isLoading, color: Colors.primaryClr, animate: true, viewBackgroundColor: Colors.darkGray)
        cell.alpha = 0
        
        // Apply animation
        UIView.animate(withDuration: 0.5) {
            cell.alpha = 1
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.pressedAnimation {
                if let vc = self.switchController(.patientExerciseDetail, .patientExercisTab) as? PatientExerciseDetailVC {
                    vc.data = self.vm.exerciseAssign[indexPath.row]
                    vc.isHeroEnabled = true
                    vc.heroModalAnimationType = .zoom
                    vc.view.heroID = "cell_\(indexPath.section)_\(indexPath.row)"
                    self.pushOrPresentViewController(vc, true)
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .systemBackground

        let headerLabel = UILabel()
        headerLabel.font = UIFont.boldSystemFont(ofSize: 20)
        headerLabel.textColor = .label // Or any color you prefer
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(headerLabel)

        // Set the label text
        if section == 0 {
            headerLabel.text = "Today’s Session"
        } else {
            headerLabel.text = "Completed"
        }

        // Set up constraints for the label
        NSLayoutConstraint.activate([
            headerLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            headerLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            headerLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 8),
            headerLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -8)
        ])

        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
            return 40
        }
}
