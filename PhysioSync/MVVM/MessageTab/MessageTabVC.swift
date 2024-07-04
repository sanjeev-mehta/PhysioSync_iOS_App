//
//  MessageTabVC.swift
//  PhysioSync
//
//  Created by Gurmeet Singh on 2024-06-02.
//

import UIKit

class MessageTabVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchTf: UITextField!
    
    let vm = MessageViewModel.shareInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTableView()
        searchTf.addTarget(self, action: #selector(searchActn(_ :)), for: .allEvents)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.debugPrint("\(vm.getUserCount())")
        self.tableView.reloadData()
    }
    
    @objc func searchActn(_ sender: UITextField) {
        if searchTf.text != "" {
            vm.filter(query: searchTf.text!)
            self.tableView.reloadData()
        }
    }
    
    // MARK: - Set Table View
    func setTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "MessageTVC", bundle: nil), forCellReuseIdentifier: "MessageTVC")
    }
    
    // MARK: - Methods
    func openChat(_ senderId: String, name: String, link: String) {
        let id = UserDefaults.standard.getTherapistId()
        TherapistHomeVC.socketHandler.fetchPreviousMessage(senderId, id)
        if let vc = self.switchController(.chatVC, .messageTab) as? ChatScreenVC {
            vc.recieverId = senderId
            vc.name = name
            vc.profileImgLink = link
            if UserDefaults.standard.getUsernameToken() != "" {
                vc.isPatient = false
            } else {
                vc.isPatient = true
            }
            self.pushOrPresentViewController(vc, true)
        }
    }

}

// MARK: - UITableView Delegate and Data Source Methods
extension MessageTabVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vm.getUserCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageTVC", for: indexPath) as! MessageTVC
        cell.selectionStyle = .none
        vm.setUpCell(cell, index: indexPath.row)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let patient = vm.model[indexPath.row].patient!
        openChat(patient.Id,name: patient.firstName + " " + patient.lastName, link: patient.profilePhoto)
    }
    
}
