//
//  StepsChartView.swift
//  SwiftUI Charts
//
//  Created by Sanjeev Mehta on 16/06/24.
//

import SwiftUI
import Charts

struct StepsChartView: View {
    @ObservedObject var healthKitManager = HealthKitManager()
    
     var body: some View {
         VStack(alignment: .leading) {
             Text("Steps Count Over Time")
                 .font(.title)
                 .fontWeight(.bold)
                 .padding()
             
             Chart(healthKitManager.stepCountData, id: \.weekday) { dataPoint in
                 Plot {
                     BarMark(
                        x: .value("Day", dataPoint.weekday, unit: .day),
                        yStart: .value("Steps", 0),
                        yEnd: .value("Steps", dataPoint.steps)
                     )
                     .clipShape(Capsule())
                     .foregroundStyle(.linearGradient(colors: [.green, .green.opacity(0.1)], startPoint: .bottom, endPoint: .top))
                 }
                 .accessibilityLabel(dataPoint.weekday.formatted(date: .complete, time: .standard))
                 .accessibilityValue("\(dataPoint.steps) steps")
                 .accessibilityHidden(false)
             }
             .chartXAxis {
                 AxisMarks(values: .init(healthKitManager.stepCountData.map(\.weekday))) { date in
                     AxisTick()
                     AxisGridLine()
                     AxisValueLabel(format: .dateTime.weekday(.abbreviated))
                 }
             }
             .accessibilityChartDescriptor(self)
             .chartYAxis(.automatic)
             .chartXAxis(.automatic)
             .frame(height: 300)
             .padding()
             .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(UIColor.systemBackground))
                    .shadow(color: .blue.opacity(0.6), radius: 5, x: 0, y: 5)
                    .padding(.horizontal, 10)
             )
             Spacer()
         }
     }
}

extension StepsChartView: AXChartDescriptorRepresentable {
    func makeChartDescriptor() -> AXChartDescriptor {

        let dateFormatter: ((Date) -> (String)) = { date in
            date.formatted(date: .complete, time: .omitted)
        }

        let minSteps = healthKitManager.stepCountData.map(\.steps).min() ?? 0
        let maxSteps = healthKitManager.stepCountData.map(\.steps).max() ?? 0

        let xAxis = AXCategoricalDataAxisDescriptor(
            title: "Day",
            categoryOrder: healthKitManager.stepCountData.map { dateFormatter($0.weekday) }
        )

        let yAxis = AXNumericDataAxisDescriptor(
            title: "Steps Count",
            range: Double(minSteps)...Double(maxSteps),
            gridlinePositions: []
        ) { value in "\(Int(value)) steps" }

        let series = AXDataSeriesDescriptor(
            name: "Steps Count",
            isContinuous: false,
            dataPoints: healthKitManager.stepCountData.map {
                .init(x: dateFormatter($0.weekday), y: Double($0.steps), label: "\($0.steps) steps")
            }
        )

        return AXChartDescriptor(
            title: "Steps Count Over Time",
            summary: nil,
            xAxis: xAxis,
            yAxis: yAxis,
            additionalAxes: [],
            series: [series]
        )
    }
}


#Preview {
    StepsChartView()
}
