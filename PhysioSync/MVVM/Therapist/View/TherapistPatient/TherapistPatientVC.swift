//
//  TherapistPatientVC.swift
//  PhysioSync
//
//  Created by Gurmeet Singh on 2024-06-10.
//

import UIKit

class TherapistPatientVC: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: - Variables
    var cellCount = 21
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
        self.isLoading = true
        callPatientApi()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    func callPatientApi() {
        vm.getPatient(vc: self) { status in
            DispatchQueue.main.async {
                self.isLoading = false
            }
        }
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
            self.pushOrPresentViewController(vc, false)
        }
    }
    // MARK: - Buttons Action
    @IBAction func listGridBtnActn(_ sender: UIButton) {
        if sender.tag == 0 {
            self.tableView.isHidden = false
            hideCollectionView()
        } else {
            showCollectionView()
        }
    }
}

// MARK: - Collection View Delegate and Data Source
extension TherapistPatientVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.isLoading {
            return cellCount
        } else {
            return vm.getCount()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProfileGridCVC", for: indexPath) as! ProfileGridCVC
//        cell.bgView.backgroundColor = .blue
        cell.bgView.layer.cornerRadius = 12
        cell.imgView.layer.cornerRadius = 12
        cell.imgView.clipsToBounds = true
        cell.bgView.addShadow()
        vm.updateCellUI(tableCell: nil, collectionCell: cell, index: indexPath.row)
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
        cell.setTemplateWithSubviews(isLoading, animate: true, viewBackgroundColor: .systemBackground)
        cell.alpha = 0
        
        // Apply animation
        UIView.animate(withDuration: 0.5) {
            cell.alpha = 1
        }
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
        vm.updateCellUI(tableCell: cell, collectionCell: nil, index: indexPath.row)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.setTemplateWithSubviews(isLoading, animate: true, viewBackgroundColor: .systemBackground)
        cell.alpha = 0
        
        // Apply animation
        UIView.animate(withDuration: 0.5) {
            cell.alpha = 1
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = vm.passData(index: indexPath.row)
        openProfileInfoController(data: data)
    }
}
