//
//  CalorieChartView.swift
//  SwiftUI Charts
//
//  Created by Sanjeev Mehta on 16/06/24.
//

import SwiftUI
import Charts

struct CalorieChartView: View {
    @ObservedObject var healthKitManager = HealthKitManager()

    var body: some View {
        VStack(alignment: .leading) {
            Text("Calories")
                .font(.title)
                .fontWeight(.bold)
                .padding()

            Chart(healthKitManager.calorieData, id: \.date) { dataPoint in
                Plot {
                    AreaMark(
                        x: .value("Day", dataPoint.date, unit: .day),
                        y: .value("Calories", dataPoint.caloriesBurned)
                    )
                    .foregroundStyle(.linearGradient(colors: [Color(red: 31/255, green: 89/255, blue: 218/255), Color(red: 31/255, green: 89/255, blue: 218/255).opacity(0.1)], startPoint: .bottom, endPoint: .top))
                    
                    LineMark(
                        x: .value("Day", dataPoint.date, unit: .day),
                        y: .value("Calories", dataPoint.caloriesBurned)
                    )
                    .foregroundStyle(.linearGradient(colors: [Color(red: 31/255, green: 89/255, blue: 218/255), Color(red: 31/255, green: 89/255, blue: 218/255).opacity(0.7)], startPoint: .bottom, endPoint: .top))
                    .lineStyle(StrokeStyle(lineWidth: 3))
                    
                    PointMark(
                        x: .value("Day", dataPoint.date, unit: .day),
                        y: .value("Calories", dataPoint.caloriesBurned)
                    )
                    .foregroundStyle(Color(red: 31/255, green: 89/255, blue: 218/255))
                    .symbolSize(30)
                    .accessibilityLabel("Calories Burned: \(Int(dataPoint.caloriesBurned))")
                }
                .accessibilityLabel(dataPoint.date.formatted(date: .complete, time: .standard))
                .accessibilityValue("\(Int(dataPoint.caloriesBurned)) calories burned")
                .accessibilityHidden(false)
            }
            .chartXAxis {
                AxisMarks(values: .init(healthKitManager.calorieData.map(\.date))) { _ in
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
                    .fill(Color.white)
                    .shadow(color: Color(red: 31/255, green: 89/255, blue: 218/255).opacity(0.3), radius: 5, x: 0, y: 5)
                    .padding(.horizontal, 10)
            )

            Spacer()
        }
    }
}
// MARK: - Accessibility

extension CalorieChartView: AXChartDescriptorRepresentable {
    func makeChartDescriptor() -> AXChartDescriptor {

        let dateFormatter: ((Date) -> (String)) = { date in
            date.formatted(date: .complete, time: .omitted)
        }

        let minCalories = healthKitManager.calorieData.map(\.caloriesBurned).min() ?? 0
        let maxCalories = healthKitManager.calorieData.map(\.caloriesBurned).max() ?? 0

        let xAxis = AXCategoricalDataAxisDescriptor(
            title: "Day",
            categoryOrder: healthKitManager.calorieData.map { dateFormatter($0.date) }
        )

        let yAxis = AXNumericDataAxisDescriptor(
            title: "Calories Burned",
            range: Double(minCalories)...Double(maxCalories),
            gridlinePositions: []
        ) { value in "\(Int(value)) calories" }

        let series = AXDataSeriesDescriptor(
            name: "Calorie Burn",
            isContinuous: false,
            dataPoints: healthKitManager.calorieData.map {
                .init(x: dateFormatter($0.date), y: Double($0.caloriesBurned), label: "\(Int($0.caloriesBurned)) calories")
            }
        )

        return AXChartDescriptor(
            title: "Calorie Burn Over Time",
            summary: nil,
            xAxis: xAxis,
            yAxis: yAxis,
            additionalAxes: [],
            series: [series]
        )
    }
}

// MARK: - Preview

struct CalorieChartView_Previews: PreviewProvider {
    static var previews: some View {
        CalorieChartView()
    }
}

// Utility function to format dates
extension Date {
    func formatted(date: DateFormatter.Style, time: DateFormatter.Style) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = date
        formatter.timeStyle = time
        return formatter.string(from: self)
    }
}
