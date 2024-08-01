//
//  IWatchConnectivity.swift
//  SwiftUI Charts
//
//  Created by Sanjeev Mehta on 16/06/24.
//

import SwiftUI
import HealthKit

// Define a public class to manage sleep data state
public class HealthKitManager: ObservableObject {
    @Published var sleepData: [SleepData] = []
    @Published var heartRateData: [(weekday: Date, dailyAverage: Int, dailyMin: Int, dailyMax: Int)] = []
    @Published var calorieData: [(date: Date, caloriesBurned: Int)] = []
    @Published var stepCountData: [(weekday: Date, steps: Int)] = []

    private let healthStore = HKHealthStore()
    static var ishealthkitPermissionPermitted = false

    init() {
        requestAuthorization()
    }

    // Function to request authorization for HealthKit
    private func requestAuthorization() {
        let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
        let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate)!
        let stepsType = HKObjectType.quantityType(forIdentifier: .stepCount)!
        let calorieType = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!

        let typesToRead: Set<HKObjectType> = [sleepType, heartRateType, stepsType, calorieType]

        healthStore.requestAuthorization(toShare: nil, read: typesToRead) { [weak self] (success, error) in
            guard let self = self else { return }
            if success {
                // Fetch data after authorization
                self.fetchSleepData()
                self.fetchHeartRateData()
                self.fetchCalorieData()
                self.fetchStepCountData()
                HealthKitManager.ishealthkitPermissionPermitted = true
            } else {
                if let error = error {
                   // print("HealthKit authorization failed. Error: \(error.localizedDescription)")
                }
            }
        }
    }

    // Function to fetch sleep data from HealthKit
    private func fetchSleepData() {
        let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
        let calendar = Calendar.current
        let now = Date()
        
        // Define start and end dates for the most recent night
        let startOfDay = calendar.startOfDay(for: now)
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else {
            //print("Error calculating end of day.")
            return
        }
        
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: endOfDay, options: .strictEndDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        let query = HKSampleQuery(sampleType: sleepType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor]) { (query, samples, error) in
            if let samples = samples as? [HKCategorySample] {
                // Process fetched samples
                var wakeHours: Double = 0.0
                var remHours: Double = 0.0
                var lightSleepHours: Double = 0.0
                var deepSleepHours: Double = 0.0
                
                for sample in samples {
                    let hours = sample.endDate.timeIntervalSince(sample.startDate) / 3600.0
                    switch sample.value {
                    case 2:
                        wakeHours += hours
                    case 4:
                        deepSleepHours += hours
                    case 5:
                        remHours += hours
                    case 3:
                        lightSleepHours += hours
                    default:
                        break
                    }
                }
                
                // Create SleepData array in the required format
                let formattedSleepData = [
                    SleepData(category: "Awake", hours: wakeHours),
                    SleepData(category: "REM", hours: remHours),
                    SleepData(category: "Core", hours: lightSleepHours),
                    SleepData(category: "Deep", hours: deepSleepHours)
                ]
                
                DispatchQueue.main.async {
                    // Update sleepData property
                    self.sleepData = formattedSleepData
                }
                
            } else {
                if let error = error {
                  //  print("Error fetching sleep data from HealthKit: \(error.localizedDescription)")
                }
            }
        }
        
        healthStore.execute(query)
    }
    
    // Function to fetch heart rate data from HealthKit
    private func fetchHeartRateData() {
         let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate)!
         let calendar = Calendar.current
         let now = Date()
         
         // Define start date as 7 days ago
         guard let startDate = calendar.date(byAdding: .day, value: -7, to: now) else {
            // print("Error calculating start date.")
             return
         }
         
         let predicate = HKQuery.predicateForSamples(withStart: startDate, end: now, options: .strictEndDate)
         let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
         let query = HKSampleQuery(sampleType: heartRateType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor]) { (query, samples, error) in
             if let samples = samples as? [HKQuantitySample] {
                 var heartRateData: [(weekday: Date, dailyAverage: Int, dailyMin: Int, dailyMax: Int)] = []
                 let groupedSamples = Dictionary(grouping: samples) { sample in
                     calendar.startOfDay(for: sample.startDate)
                 }
                 
                 for (date, samples) in groupedSamples {
                     let values = samples.map { $0.quantity.doubleValue(for: HKUnit(from: "count/min")) }
                     let dailyMin = values.min() ?? 0.0
                     let dailyMax = values.max() ?? 0.0
                     let dailyAverage = values.reduce(0, +) / Double(values.count)
                     
                     heartRateData.append((weekday: date, dailyAverage: Int(dailyAverage), dailyMin: Int(dailyMin), dailyMax: Int(dailyMax)))
                 }
                 
                 heartRateData.sort { $0.weekday < $1.weekday }
                 
                 DispatchQueue.main.async {
                     // Update heartRateData property
                     self.heartRateData = heartRateData
                 }
                 
             } else {
                 if let error = error {
                     //print("Error fetching heart rate data from HealthKit: \(error.localizedDescription)")
                 }
             }
         }
         
         healthStore.execute(query)
     }

     // Computed properties for min, max, earliest, latest, and date interval based on heartRateData
     var minBPM: Int {
         heartRateData.min { a, b in
             a.dailyMin < b.dailyMin
         }?.dailyMin ?? 0
     }

     var maxBPM: Int {
         heartRateData.max { a, b in
             a.dailyMax < b.dailyMax
         }?.dailyMax ?? 0
     }

     var earliestDate: Date {
         heartRateData.min { a, b in
             a.weekday < b.weekday
         }?.weekday ?? Date()
     }

     var latestDate: Date {
         heartRateData.max { a, b in
             a.weekday < b.weekday
         }?.weekday ?? Date()
     }

     var dateInterval: DateInterval {
         DateInterval(start: earliestDate, end: latestDate)
     }
    
    // Function to fetch calorie data from HealthKit
      private func fetchCalorieData() {
          let energyBurnedType = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!
          let calendar = Calendar.current
          let now = Date()
          
          // Define start date as 7 days ago
          guard let startDate = calendar.date(byAdding: .day, value: -7, to: now) else {
              print("Error calculating start date.")
              return
          }

          let predicate = HKQuery.predicateForSamples(withStart: startDate, end: now, options: .strictEndDate)
          let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
          let query = HKSampleQuery(sampleType: energyBurnedType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor]) { (query, samples, error) in
              if let samples = samples as? [HKQuantitySample] {
                  var calorieData: [(date: Date, caloriesBurned: Int)] = []
                  let groupedSamples = Dictionary(grouping: samples) { sample in
                      calendar.startOfDay(for: sample.startDate)
                  }
                  
                  for (date, samples) in groupedSamples {
                      let totalCalories = samples.reduce(0) { sum, sample in
                          sum + sample.quantity.doubleValue(for: .kilocalorie())
                      }
                      
                      calorieData.append((date: date, caloriesBurned: Int(totalCalories)))
                  }
                  
                  calorieData.sort { $0.date < $1.date }
                  
                  DispatchQueue.main.async {
                      // Update calorieData property
                      self.calorieData = calorieData
                      print(self.calorieData, "*****")
                  }
                  
              } else {
                  if let error = error {
                      print("Error fetching calorie data from HealthKit: \(error.localizedDescription)")
                  }
              }
          }
          
          healthStore.execute(query)
      }
    
    private func fetchStepCountData() {
        let stepCountType = HKObjectType.quantityType(forIdentifier: .stepCount)!
        let calendar = Calendar.current
        let now = Date()
        
        // Define start date as 7 days ago
        guard let startDate = calendar.date(byAdding: .day, value: -6, to: now) else {
            print("Error calculating start date.")
            return
        }
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: now, options: .strictEndDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        let query = HKSampleQuery(sampleType: stepCountType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor]) { (query, samples, error) in
            if let samples = samples as? [HKQuantitySample] {
                var stepCountData: [(weekday: Date, steps: Int)] = []
                let groupedSamples = Dictionary(grouping: samples) { sample in
                    calendar.startOfDay(for: sample.startDate)
                }
                
                for (date, samples) in groupedSamples {
                    let values = samples.map { $0.quantity.doubleValue(for: .count()) }
                    let dailyMin = values.min() ?? 0.0
                    let dailyMax = values.max() ?? 0.0
                    let dailyAverage = values.reduce(0, +) / Double(values.count)
                    
                    stepCountData.append((weekday: date, steps: Int(dailyMax)))
                }
                
                // Sort stepCountData by date before updating
                stepCountData.sort { $0.weekday < $1.weekday }
                
                DispatchQueue.main.async {
                    // Update stepCountData property
                    self.stepCountData = stepCountData
                }
                
            } else {
                if let error = error {
                    print("Error fetching step count data from HealthKit: \(error.localizedDescription)")
                }
            }
        }
        
        healthStore.execute(query)
    }
}

struct HeartRateDataPoint {
    let weekday: Date
    let dailyAverage: Int
    let dailyMin: Int
    let dailyMax: Int
}

struct SleepData: Identifiable {
    let id = UUID()
    let category: String
    let hours: Double
}

extension HealthKitManager {
    var formattedCalorieData: [[String: Any]] {
        return calorieData.map { data in
            [
                "day": DateFormatter.localizedString(from: data.date, dateStyle: .short, timeStyle: .none),
                "values": [data.caloriesBurned]
            ]
        }
    }

    var formattedHeartRateData: [[String: Any]] {
        return heartRateData.map { data in
            [
                "day": DateFormatter.localizedString(from: data.weekday, dateStyle: .short, timeStyle: .none),
                "bpm_minimum": data.dailyMin,
                "bpm_maximum": data.dailyMax
            ]
        }
    }

    var formattedSleepData: [[String: Any]] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let today = dateFormatter.string(from: Date())
        let sleep = sleepData.reduce(into: [String: Double]()) { (result, data) in
            result[data.category.lowercased() + "_hours"] = data.hours
        }
        return [[
            "day": today,
            "awake_hours": sleep["awake_hours"] ?? 0.0,
            "rem_hours": sleep["rem_hours"] ?? 0.0,
            "core_hours": sleep["core_hours"] ?? 0.0,
            "deep_hours": sleep["deep_hours"] ?? 0.0
        ]]
    }

    var formattedStepCountData: [[String: Any]] {
        return stepCountData.map { data in
            [
                "day": DateFormatter.localizedString(from: data.weekday, dateStyle: .short, timeStyle: .none),
                "steps": data.steps
            ]
        }
    }
}
