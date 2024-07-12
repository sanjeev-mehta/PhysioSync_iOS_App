//
//  PatientStatsVC.swift
//  PhysioSync
//
//  Created by Sanjeev Mehta on 21/06/24.
//

import UIKit
import SwiftUI

class PatientStatsVC: UIViewController {
    
    var watchData: WatchData?
    
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
        var contentView = ContentView()
        
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

class TherapisPatientStatsVC: UIViewController {
    
    var watchData: WatchData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.setHeader("Stats", isBackBtn: true, isRightBtn: false) {
            self.dismissOrPopViewController()
        } rightButtonAction: {}
        let caloriesData: [Calories] = watchData?.calories ?? []
        let heartRateData: [HeartRate] = watchData?.heartRate ?? []
        let stepCountData: [StepCount] = watchData?.stepCount ?? []
        var sleepData = [SleepData]()
        // Static sleep data for demonstration
        if let data = watchData?.sleep {
            let staticSleepData: [SleepData] = [
                SleepData(category: "Awake", hours: data[0].awakeHours),
                SleepData(category: "REM", hours: data[0].remHours),
                SleepData(category: "Core", hours: data[0].coreHours),
                SleepData(category: "Deep", hours: data[0].deepHours)
            ]
            sleepData = staticSleepData
        }
        
        loadSwiftUIView(caloriesData: caloriesData, heartRateData: heartRateData, sleepData: sleepData, stepCountData: stepCountData)

    }
    
    func loadSwiftUIView(caloriesData: [Calories], heartRateData: [HeartRate], sleepData: [SleepData], stepCountData: [StepCount]) {
        let contentView = TherapisContentView(caloriesData: caloriesData, heartRateData: heartRateData, sleepData: sleepData, stepCountData: stepCountData)

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
