//
//  DisplayWatchData.swift
//  PhysioSync
//
//  Created by Sanjeev Mehta on 11/07/24.
//

import SwiftUI
import Charts

struct CaloriesChartView: View {
    let caloriesData: [Calories]
        
    var body: some View {
        VStack(alignment: .leading) {
            Text("Calories Burned")
                .font(.title)
                .fontWeight(.bold)
                .padding()
            
            Chart(caloriesData, id: \.id) { dataPoint in
                Plot {
                    AreaMark(
                        x: .value("Day", dataPoint.day),
                        y: .value("Calories", dataPoint.values.reduce(0, +))
                    )
                    .foregroundStyle(.linearGradient(colors: [.blue, .blue.opacity(0.1)], startPoint: .bottom, endPoint: .top))
                }
            }
            .chartXAxis {
                AxisMarks(values: .init(caloriesData.map(\.day))) { _ in
                    AxisTick()
                    AxisGridLine()
                    AxisValueLabel()
                }
            }
            .chartYAxis(.automatic)
            .frame(height: 300)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(UIColor.systemBackground))
                    .shadow(color: .blue.opacity(0.6), radius: 5, x: 0, y: 5)
                    .padding(.horizontal, 10)
            )
        }
        .padding()
    }
}

struct HeartRateChartView: View {
    let heartRateData: [HeartRate]
        
    @State private var barWidth = 15.0
    @State private var chartColor: Color = .red
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Heart Rate")
                .font(.largeTitle)
                .bold()
                .padding([.top, .leading])
            chart
                .frame(height: 300)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(UIColor.systemBackground))
                        .shadow(color: .blue.opacity(0.6), radius: 5, x: 0, y: 5)
                        .padding(.horizontal, 10)
                )
        }
    }
    
    private var chart: some View {
        Chart(heartRateData, id: \.day) { dataPoint in
            Plot {
                BarMark(
                    x: .value("Day", dataPoint.formattedDate!, unit: .day),
                    yStart: .value("BPM Min", dataPoint.bpmMinimum),
                    yEnd: .value("BPM Max", dataPoint.bpmMaximum),
                    width: .fixed(barWidth)
                )
                .clipShape(Capsule())
                .foregroundStyle(chartColor.gradient)
                
                if dataPoint.bpmMinimum == heartRateData.map(\.bpmMinimum).min() {
                    PointMark(
                        x: .value("Day", dataPoint.formattedDate!, unit: .day),
                        y: .value("BPM Min", dataPoint.bpmMinimum + 7)
                    )
                    .foregroundStyle(.black)
                    .accessibilityLabel("Minimum BPM \(dataPoint.bpmMinimum)")
                    .accessibilityValue("")
                    .annotation(position: .bottom) {
                        Text("Min \n\(dataPoint.bpmMinimum)")
                            .font(.callout)
                            .fontWeight(.bold)
                            .foregroundColor(.red)
                    }
                }
                
                if dataPoint.bpmMaximum == heartRateData.map(\.bpmMaximum).max() {
                    PointMark(
                        x: .value("Day", dataPoint.formattedDate!, unit: .day),
                        y: .value("BPM Min", dataPoint.bpmMaximum - 7)
                    )
                    .foregroundStyle(.black)
                    .accessibilityLabel("Maximum BPM \(dataPoint.bpmMaximum)")
                    .accessibilityValue(dataPoint.day)
                    .annotation(position: .top) {
                        Text("Max \n\(dataPoint.bpmMaximum)")
                            .font(.callout)
                            .fontWeight(.bold)
                            .foregroundColor(.red)
                    }
                }
                
            }
            .accessibilityLabel("")
            .accessibilityValue("\(dataPoint.bpmMinimum) to \(dataPoint.bpmMaximum) BPM")
            .accessibilityHidden(false)
            
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: ChartStrideBy.day.time)) { _ in
                AxisTick()
                AxisGridLine()
                AxisValueLabel(format: .dateTime.weekday(.abbreviated))
            }
        }
        .chartYAxis(.automatic)
        .chartXAxis(.automatic)
        .frame(height: 300)
    }
}

struct SleepChartView: View {
    @Binding var animatedData: [SleepData]
       
       let categoryColors: [String: [Color]] = [
           "Awake": [Color.red, Color.orange],
           "REM": [Color.purple, Color.pink],
           "Core": [Color.yellow, Color.green],
           "Deep": [Color.blue, Color.indigo]
       ]
       
       // Static data for demonstration
       let staticSleepData: [SleepData] = [
           SleepData(category: "Awake", hours: 6.5),
           SleepData(category: "REM", hours: 2.5),
           SleepData(category: "Core", hours: 1.5),
           SleepData(category: "Deep", hours: 3.0)
       ]
       
       var body: some View {
           VStack(alignment: .leading) {
               Text("Sleep Analysis")
                   .font(.largeTitle)
                   .bold()
                   .padding([.top, .leading])
               
               Chart {
                   ForEach(animatedData) { data in
                       BarMark(
                           x: .value("Category", data.category),
                           y: .value("Hours", data.hours)
                       )
                       .clipShape(CustomBarShape())
                       .foregroundStyle(
                           LinearGradient(
                               gradient: Gradient(colors: categoryColors[data.category] ?? [.gray]),
                               startPoint: .bottom,
                               endPoint: .top
                           )
                       )
                       .annotation(position: .top) {
                           Text("\(data.hours, specifier: "%.1f")h")
                               .font(.caption)
                               .foregroundColor(.primary)
                       }
                   }
               }
               .chartXAxis {
                   AxisMarks(values: .automatic) { _ in
                       AxisGridLine()
                       AxisTick()
                       AxisValueLabel()
                   }
               }
               .chartYAxis {
                   AxisMarks(values: .automatic) { _ in
                       AxisGridLine()
                       AxisTick()
                       AxisValueLabel()
                   }
               }
               .frame(height: 300)
               .padding([.horizontal, .bottom])
               .background(
                   RoundedRectangle(cornerRadius: 10)
                       .fill(Color(UIColor.systemBackground))
                       .shadow(color: .blue.opacity(0.6), radius: 5, x: 0, y: 5)
               )
           }
           .padding()
       }

}

struct StepCountChartView: View {
    let stepCountData: [StepCount]

    var body: some View {
        VStack(alignment: .leading) {
            Text("Step Count")
                .font(.title)
                .fontWeight(.bold)
                .padding()

            Chart(stepCountData, id: \.id) { dataPoint in
                Plot {
                    BarMark(
                        x: .value("Day", dataPoint.day),
                        yStart: .value("Steps", 0),
                        yEnd: .value("Steps", dataPoint.steps)
                    )
                    .clipShape(Capsule())
                    .foregroundStyle(.linearGradient(colors: [.green, .green.opacity(0.1)], startPoint: .bottom, endPoint: .top))
                }
            }
            .chartXAxis {
                AxisMarks(values: .init(stepCountData.map(\.day))) { _ in
                    AxisTick()
                    AxisGridLine()
                    AxisValueLabel()
                }
            }
            .chartYAxis(.automatic)
            .frame(height: 300)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(UIColor.systemBackground))
                    .shadow(color: .blue.opacity(0.6), radius: 5, x: 0, y: 5)
                    .padding(.horizontal, 10)
            )
        }
    }
}

struct TherapisContentView: View {
    let caloriesData: [Calories]
    let heartRateData: [HeartRate]
    let sleepData: [SleepData] // Static sleep data
    let stepCountData: [StepCount]
    
    var body: some View {
        NavigationView {
            ScrollView {
                    CaloriesChartView(caloriesData: caloriesData)
                        .padding()
                    
                    HeartRateChartView(heartRateData: heartRateData)
                        .padding()
                    
                    SleepChartView(animatedData: .constant(sleepData)) // Use static sleep data here
                        .padding()
                    
                    StepCountChartView(stepCountData: stepCountData)
                        .padding()
            }
        }
    }
}
