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
    @State private var chartColor: Color = Color(red: 31/255, green: 89/255, blue: 218/255)

    var body: some View {
        VStack(alignment: .leading) {
            Text("Calories Burned")
                .font(.custom("Outfit-Regular", size: 20))
                .fontWeight(.bold)
                .padding()
            
            Chart(caloriesData.sorted { $0.formattedDate! < $1.formattedDate! }, id: \.id) { dataPoint in
                Plot {
                    AreaMark(
                        x: .value("Day", dataPoint.formattedDate!, unit: .day),
                        y: .value("Calories", dataPoint.values.reduce(0, +))
                    )
                    .foregroundStyle(chartColor.gradient)
                    
                    LineMark(
                        x: .value("Day", dataPoint.formattedDate!, unit: .day),
                        y: .value("Calories", dataPoint.values.reduce(0, +))
                    )
                    .foregroundStyle(.linearGradient(colors: [Color(red: 31/255, green: 89/255, blue: 218/255), Color(red: 31/255, green: 89/255, blue: 218/255).opacity(0.7)], startPoint: .bottom, endPoint: .top))
                    .lineStyle(StrokeStyle(lineWidth: 3))
                    
                    PointMark(
                        x: .value("Day", dataPoint.formattedDate!, unit: .day),
                        y: .value("Calories", dataPoint.values.reduce(0, +))
                    )
                    .foregroundStyle(Color(red: 31/255, green: 89/255, blue: 218/255))
                    .symbolSize(30)
                    .accessibilityLabel("Calories Burned: \(Int(dataPoint.values.reduce(0, +)))")
                }
            }
            .chartXAxis {
                AxisMarks(values: .init(caloriesData.compactMap { $0.formattedDate })) { value in
                    AxisTick()
                    AxisGridLine()
                    AxisValueLabel(format: .dateTime.weekday(.abbreviated))
                }
            }
            .chartYAxis(.automatic)
            .frame(height: 300)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(UIColor.systemBackground))
                    .shadow(color: chartColor.opacity(0.3), radius: 5, x: 0, y: 5)
                    .padding(.horizontal, 10)
            )
        }
        .padding()
    }
}

struct HeartRateChartView: View {
    let heartRateData: [HeartRate]
        
    @State private var barWidth = 15.0
    @State private var chartColor: Color = Color(red: 31/255, green: 89/255, blue: 218/255)

    var body: some View {
        VStack(alignment: .leading) {
            Text("Heart Rate")
                .font(.custom("Outfit-Regular", size: 20))
                .bold()
                .padding([.top, .leading])
            chart
                .frame(height: 300)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(UIColor.systemBackground))
                        .shadow(color: chartColor.opacity(0.3), radius: 5, x: 0, y: 5)
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
                            .foregroundColor(chartColor)
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
                            .foregroundColor(chartColor)
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
    @State private var chartColor: Color = Color(red: 31/255, green: 89/255, blue: 218/255)
//1F59DA 15203D #5C85DF #243155
    
    let categoryColors: [String: [Color]] = [
        "Awake": [Color(hex: "1F59DA"), Color(hex: "1F59DA")],
        "REM": [Color(hex: "3F71E0"), Color(hex: "3F71E0")],
        "Core": [Color(hex: "5C85DF"), Color(hex: "5C85DF")],
        "Deep": [Color(hex: "829EDD"), Color(hex: "829EDD")]
    ]
       
       // Static data for demonstration
       let staticSleepData: [SleepData] = [
           SleepData(category: "Awake", hours: 1.5),
           SleepData(category: "REM", hours: 2.0),
           SleepData(category: "Core", hours: 3.0),
           SleepData(category: "Deep", hours: 1.5)
       ]
       
       var body: some View {
           VStack(alignment: .leading) {
               Text("Sleep Analysis")
                   .font(.custom("Outfit-Regular", size: 20))
                   .bold()
                   .padding([.top, .leading])
               
               Chart {
                   ForEach(staticSleepData) { data in
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
                       .shadow(color: chartColor.opacity(0.2), radius: 5, x: 0, y: 5)
               )
           }
           .padding()
       }

}

struct StepCountChartView: View {
    let stepCountData: [StepCount]
    @State private var chartColor: Color = Color(red: 31/255, green: 89/255, blue: 218/255)

    var body: some View {
        VStack(alignment: .leading) {
            Text("Step Count")
                .font(.custom("Outfit-Regular", size: 20))
                .fontWeight(.bold)
                .padding()

            Chart(stepCountData.sorted { $0.formattedDate! < $1.formattedDate! }, id: \.id) { dataPoint in
                Plot {
                    BarMark(
                        x: .value("Day", dataPoint.formattedDate!, unit: .day),
                        yStart: .value("Steps", 0),
                        yEnd: .value("Steps", dataPoint.steps)
                    )
                    .foregroundStyle(.linearGradient(colors: [chartColor, chartColor.opacity(0.5)], startPoint: .bottom, endPoint: .top))
                }
            }
            .chartXAxis {
                AxisMarks(values: .init(stepCountData.compactMap { $0.formattedDate })) { value in
                    AxisTick()
                    AxisGridLine()
                    AxisValueLabel(format: .dateTime.weekday(.abbreviated))
                }
            }
            .chartYAxis(.automatic)
            .frame(height: 300)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(UIColor.systemBackground))
                    .shadow(color: chartColor.opacity(0.6), radius: 5, x: 0, y: 5)
                    .padding(.horizontal, 10)
            )
        }
    }
}

struct TherapisContentView: View {
    let caloriesData: [Calories]
    let heartRateData: [HeartRate]
    let sleepData: [SleepData]
    let stepCountData: [StepCount]
    
    var body: some View {
        NavigationView {
            ScrollView {
                
                SleepChartView(animatedData: .constant(sleepData))
                
                HeartRateChartView(heartRateData: heartRateData)
                    .padding()
                
                CaloriesChartView(caloriesData: caloriesData)
              
                StepCountChartView(stepCountData: stepCountData)
                    .padding()
            }
        }
    }
}

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        scanner.scanLocation = 1
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        
        let red = Double((rgb >> 16) & 0xFF) / 255.0
        let green = Double((rgb >> 8) & 0xFF) / 255.0
        let blue = Double(rgb & 0xFF) / 255.0
        
        self.init(red: red, green: green, blue: blue)
    }
}
