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
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            self.cellCount = 3
            self.isLoading = false
        }
    }
    
}

extension PatientExerciseTabVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return cellCount
        } else {
            return cellCount
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PatientExerciseTabTVC", for: indexPath) as! PatientExerciseTabTVC
            cell.selectionStyle = .none
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PatientExerciseTabTVC2", for: indexPath) as! PatientExerciseTabTVC2
            cell.selectionStyle = .none
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 300
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // Initial state for the animation
        cell.setTemplateWithSubviews(isLoading, animate: true, viewBackgroundColor: .systemBackground)
        cell.alpha = 0
        
        // Apply animation
        UIView.animate(withDuration: 0.5) {
            cell.alpha = 1
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.pressedAnimation {
                if let vc = self.switchController(.patientExerciseDetail, .patientExercisTab) {
                    vc.isHeroEnabled = true
                    vc.heroModalAnimationType = .zoom
                    //            vc.heroModalAnimationType = .slide(direction: .left)
                    vc.view.heroID = "cell_\(indexPath.section)_\(indexPath.row)"
                    self.pushOrPresentViewController(vc, false)
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
