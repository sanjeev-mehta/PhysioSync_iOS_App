//
//  TherapistPatientVC.swift
//  PhysioSync
//
//  Created by Gurmeet Singh on 2024-06-10.
//

import UIKit

class TherapistPatientVC: UIViewController, UIContextMenuInteractionDelegate {
    
    // MARK: - Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var patientCountLabel: UILabel!
    @IBOutlet weak var searchBar: UITextField!
    @IBOutlet weak var listBtn: UIButton!
    @IBOutlet weak var gridBtn: UIButton!
    @IBOutlet weak var patientNotFoundImgView: UIImageView!
    
    //MARK: - Variables
    var cellCount = 21
    var numberOfPatients: Int = 0
    var tag = 0
    
    private var isLoading = true {
        didSet {
            tableView.isUserInteractionEnabled = !isLoading
            tableView.reloadData()
            collectionView.isUserInteractionEnabled = !isLoading
            collectionView.reloadData()
        }
    }
    private let vm = TherapistPatientViewModel.shareInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showCollectionView()
        setCollectionView()
        setTableView()
        setSearchBar()
        
        let leftSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeGesture(_:)))
            leftSwipeGesture.direction = .left
        self.view.addGestureRecognizer(leftSwipeGesture)
        
        let rightSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeGesture(_:)))
            rightSwipeGesture.direction = .right
        self.view.addGestureRecognizer(rightSwipeGesture)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.isLoading = true
        callPatientApi()
    }
    
    @objc func handleSwipeGesture(_ gesture: UISwipeGestureRecognizer) {
        if gesture.direction == .left {
            self.view.hapticFeedback(style: .soft)
            self.showCollectionView()
            changeGridList(tag: 1)
        } else if gesture.direction == .right {
            self.tableView.isHidden = false
            self.view.hapticFeedback(style: .soft)
            self.hideCollectionView()
            changeGridList(tag: 0)
        }
    }
    
    // MARK: - Call Patient API & Number of Patients
    func callPatientApi() {
        vm.getPatient(vc: self) { status in
            DispatchQueue.main.async {
                self.isLoading = false
                self.numberOfPatients = self.vm.getCount()
                self.patientCountLabel.text = " \(self.numberOfPatients)"
                self.changeGridList(tag: 1)
            }
        }
    }
    
    
    // MARK: - Set Up Search Bar
    func setSearchBar() {
        searchBar.textColor = .black
        searchBar.addTarget(self, action: #selector(searchActn(_ :)), for: .allEvents)
    }
    
    func setCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "ProfileGridCVC", bundle: nil), forCellWithReuseIdentifier: "ProfileGridCVC")
    }
    
    func setTableView() {
        tableView.isHidden = true
        tableView.delegate = self
        tableView.dataSource = self
        tableView.showsVerticalScrollIndicator = false
    }
    
    func showCollectionView() {
        UIView.animate(withDuration: 0.4) {
            self.tableView.transform = CGAffineTransform(translationX: -1000, y: 0)
            UIView.animate(withDuration: 0.2) {
                self.collectionView.transform = CGAffineTransform.identity
            }
        }
    }
    
    func hideCollectionView() {
        UIView.animate(withDuration: 0.4) {
            self.collectionView.transform = CGAffineTransform(translationX: 1000, y: 0)
            UIView.animate(withDuration: 0.2) {
                self.tableView.transform = CGAffineTransform.identity
            }
        }
    }
    
    func openProfileInfoController(data: TherapistPatientData) {
        if let vc = self.switchController(.therapistPatientProfileVC, .therapistPatientProfile) as? TherapistPatientProfileVC {
            vc.patientData = data
            self.pushOrPresentViewController(vc, true)
        }
    }
    
    func changeGridList(tag: Int) {
        self.tag = tag
        if tag != 0 {
            self.gridBtn.setImage(UIImage(named: "gridEnable"), for: .normal)
            self.listBtn.setImage(UIImage(named: "listIcon"), for: .normal)
        } else {
            self.gridBtn.setImage(UIImage(named: "gridIcon"), for: .normal)
            self.listBtn.setImage(UIImage(named: "listEnable"), for: .normal)
        }
    }
    
    // MARK: - Buttons Action
    @IBAction func listGridBtnActn(_ sender: UIButton) {
        sender.pressedAnimation {
            if sender.tag == 0 {
                self.tableView.isHidden = false
                self.hideCollectionView()
            } else {
                self.showCollectionView()
            }
            self.changeGridList(tag: sender.tag)
        }
    }
    
    @IBAction func addPatientBtnActn(_ sender: UIButton) {
        sender.pressedAnimation {
            if let vc = self.switchController(.therapistPatientStep1VC, .therapistPatientProfile) as? TherapistPatientStep1VC {
                vc.isEdit = false
                self.pushOrPresentViewController(vc, true)
            }
        }
    }
}

// MARK: - UISearchBarDelegate
extension TherapistPatientVC {
    //    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    //        vm.searchPatients(query: searchText)
    //        tableView.reloadData()
    //        collectionView.reloadData()
    //    }
    @objc func searchActn(_ sender: UITextField) {
            vm.searchPatients(query: searchBar.text!)
            self.tableView.reloadData()
            self.collectionView.reloadData()
    }
}

// MARK: - Collection View Delegate and Data Source
extension TherapistPatientVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.isLoading {
            patientNotFoundImgView.isHidden = true
            return cellCount
        } else {
            if vm.getCount() == 0 {
                patientNotFoundImgView.isHidden = false
                tableView.isHidden = true
            } else {
                patientNotFoundImgView.isHidden = true
                tableView.isHidden = false
            }
            return vm.getCount()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProfileGridCVC", for: indexPath) as! ProfileGridCVC
        //        cell.bgView.backgroundColor = .blue
        cell.bgView.layer.cornerRadius = 12
        cell.imgView.layer.cornerRadius = 12
        cell.imgView.clipsToBounds = true
        cell.imgView.contentMode = .scaleAspectFill
//        cell.bgView.addShadow()
        if !self.isLoading {
            vm.updateCellUI(tableCell: nil, collectionCell: cell, index: indexPath.row)
        }
        let interaction = UIContextMenuInteraction(delegate: self)
        cell.addInteraction(interaction)
        cell.tag = indexPath.item
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: collectionView.bounds.width/3, height: 155)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
        
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        cell.setTemplateWithSubviews(isLoading, color: Colors.darkGray, animate: true, viewBackgroundColor: .lightGray)
        //cell.alpha = 0
        
        // Apply animation
//        UIView.animate(withDuration: 0.5) {
//            cell.alpha = 1
//        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // MARK: - Switch Controllers on tap
        let data = vm.passData(index: indexPath.item)
        openProfileInfoController(data: data)
    }
}

// MARK: - Table View Delegates and DataSource

extension TherapistPatientVC: UITableViewDelegate ,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.isLoading {
            return cellCount
        } else {
            return vm.getCount()
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TherapistPatientListTVC", for: indexPath) as! TherapistPatientListTVC
        if !self.isLoading {
            vm.updateCellUI(tableCell: cell, collectionCell: nil, index: indexPath.row)
        }
        cell.imgView.contentMode = .scaleAspectFill
        let interaction = UIContextMenuInteraction(delegate: self)
        cell.addInteraction(interaction)
        cell.tag = indexPath.row
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.setTemplateWithSubviews(isLoading, color: Colors.darkGray, animate: true, viewBackgroundColor: .lightGray)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = vm.passData(index: indexPath.row)
        openProfileInfoController(data: data)
    }
    
    // MARK: - UIContextMenuInteractionDelegate
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { suggestedActions in
            var index: IndexPath?
            
            if self.tag == 1 {
                // Retrieve the tag from the cell in the collection view
                if let cell = interaction.view as? UICollectionViewCell {
                    let row = cell.tag
                    index = IndexPath(row: row, section: 0)
                }
            } else {
                // Retrieve the tag from the cell in the table view
                if let cell = interaction.view as? UITableViewCell {
                    let row = cell.tag
                    index = IndexPath(row: row, section: 0)
                }
            }
            
            guard let validIndexPath = index else {
                print("Invalid index path")
                return nil
            }
            
            let editAction = UIAction(title: "Edit", image: UIImage(named: "edit")) { action in
                self.handleEditAction(at: validIndexPath)
            }
            return UIMenu(title: "", children: [editAction])
        }
    }

    func handleEditAction(at indexPath: IndexPath) {
        print("Edit action triggered for row \(indexPath.row)")
        // Implement edit functionality here
        if let vc = self.switchController(.therapistPatientStep1VC , .therapistPatientProfile) as? TherapistPatientStep1VC {
            vc.isEdit = true
            let data = self.vm.filteredPatients[indexPath.row]
            let patient = Patient(Id: data.Id, therapistId: data.therapistId, firstName: data.firstName, lastName: data.lastName, patientEmail: data.patientEmail, injuryDetails: data.injuryDetails, password: "", exerciseReminderTime: data.exerciseReminderTime, medicineReminderTime: data.medicineReminderTime, dateOfBirth: data.dateOfBirth, allergyIfAny: data.allergyIfAny, profilePhoto: data.profilePhoto, gender: data.gender, medicalHistory: data.medicalHistory, createdAt: data.createdAt, updatedAt: data.updatedAt, _v: data._v, isActive: data.isActive, unreadCount: 0, address: "", phone_no: "")
            vc.model = patient
            self.pushOrPresentViewController(vc, true)
        }
    }
}
