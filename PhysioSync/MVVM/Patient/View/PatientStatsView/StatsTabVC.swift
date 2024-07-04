//
//  StatsTabVC.swift
//  PhysioSync
//
//  Created by Sanjeev Mehta on 21/06/24.
//

import UIKit
import Combine

class StatsTabVC: UIViewController {

    @IBOutlet var lbls: [UILabel]!
    
    private var healthKitManager = HealthKitManager()
    private var cancellables: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBindings()
    }
    
    private func setupBindings() {
            healthKitManager.$sleepData
                .receive(on: RunLoop.main)
                .sink { [weak self] sleepData in
                    self?.updateSleepLabels(sleepData)
                }
                .store(in: &cancellables)

            healthKitManager.$heartRateData
                .receive(on: RunLoop.main)
                .sink { [weak self] heartRateData in
                    self?.updateHeartRateLabels(heartRateData)
                }
                .store(in: &cancellables)

            healthKitManager.$calorieData
                .receive(on: RunLoop.main)
                .sink { [weak self] calorieData in
                    self?.updateCalorieLabels(calorieData)
                }
                .store(in: &cancellables)

            healthKitManager.$stepCountData
                .receive(on: RunLoop.main)
                .sink { [weak self] stepCountData in
                    self?.updateStepCountLabels(stepCountData)
                }
                .store(in: &cancellables)
        }
    
    private func updateSleepLabels(_ sleepData: [SleepData]) {
        var hrs = 0.00
            for (index, sleep) in sleepData.enumerated() {
                hrs += sleep.hours
                lbls[2].text = String(format: "%.1f hours", hrs)
            }
        }
    
    private func updateHeartRateLabels(_ heartRateData: [(weekday: Date, dailyAverage: Int, dailyMin: Int, dailyMax: Int)]) {
            
            if let latestHeartRate = heartRateData.last {
                lbls[3].text = "\(latestHeartRate.dailyAverage) bpm"
            }
        }
    
    private func updateCalorieLabels(_ calorieData: [(date: Date, caloriesBurned: Int)]) {
            if let latestCalorie = calorieData.last {
                lbls[0].text = "\(latestCalorie.caloriesBurned) kcal"
            }
        }

        private func updateStepCountLabels(_ stepCountData: [(weekday: Date, steps: Int)]) {
            if let latestStepCount = stepCountData.last {
                lbls[1].text = "\(latestStepCount.steps)"
            }
        }

    @IBAction func statsDetailBtnActn(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "PatientStatsVC") as! PatientStatsVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
