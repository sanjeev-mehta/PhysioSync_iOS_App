//
//  PatientStatsVC.swift
//  PhysioSync
//
//  Created by Sanjeev Mehta on 21/06/24.
//

import UIKit
import SwiftUI

class PatientStatsVC: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.setHeader("Stats", isBackBtn: true, isRightBtn: false) {
            self.dismissOrPopViewController()
        } rightButtonAction: {}

        loadSwiftUIView()
    }
    
    func loadSwiftUIView() {
        let contentView = ContentView()
        
        let hostingController = UIHostingController(rootView: contentView)
        addChild(hostingController)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(hostingController.view)
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor, constant: 110),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        hostingController.didMove(toParent: self)
    }
}
