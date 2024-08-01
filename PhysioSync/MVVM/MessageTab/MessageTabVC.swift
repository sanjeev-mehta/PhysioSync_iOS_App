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
    @IBOutlet weak var messageCountLbl: UILabel!
    @IBOutlet weak var messageCountView: UIView!
    @IBOutlet weak var messageNotFoundImgView: UIImageView!
    
    let vm = MessageViewModel.shareInstance
    private var updateTimer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()
        setTableView()
        searchTf.addTarget(self, action: #selector(searchActn(_:)), for: .allEvents)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startTimer()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopTimer()
    }

    private func startTimer() {
        stopTimer() // Ensure any existing timer is invalidated
        updateTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.showData()
        }
    }

    private func stopTimer() {
        updateTimer?.invalidate()
        updateTimer = nil
    }

    func showData() {
        tableView.reloadData()
        if vm.unreadCount() == 0 {
            messageCountView.isHidden = true
        } else {
            messageCountView.isHidden = false
            messageCountLbl.text = "\(vm.unreadCount())"
        }
    }

    @objc func searchActn(_ sender: UITextField) {
        vm.filter(query: searchTf.text!)
        tableView.reloadData()
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
        if let vc = switchController(.chatVC, .messageTab) as? ChatScreenVC {
            vc.recieverId = senderId
            vc.name = name
            vc.profileImgLink = link
            if UserDefaults.standard.getUsernameToken() != "" {
                vc.isPatient = false
            } else {
                vc.isPatient = true
            }
            pushOrPresentViewController(vc, true)
        }
    }
}

// MARK: - UITableView Delegate and Data Source Methods
extension MessageTabVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if vm.getUserCount() == 0 {
            messageNotFoundImgView.isHidden = false
            tableView.isHidden = true
        } else {
            messageNotFoundImgView.isHidden = true
            tableView.isHidden = false
        }
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
        openChat(patient.Id, name: patient.firstName + " " + patient.lastName, link: patient.profilePhoto)
    }
}
