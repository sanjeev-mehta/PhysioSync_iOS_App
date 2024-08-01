//
//  SleepGraphView.swift
//  SwiftUI Charts
//
//  Created by Sanjeev Mehta on 16/06/24.
//

import SwiftUI
import Charts

struct SleepGraphView: View {
    @Binding var animatedData: [SleepData]
    
    let categoryColors: [String: [Color]] = [
        "Awake": [Color(red: 31/255, green: 89/255, blue: 218/255, opacity: 1)],
        "REM": [Color(red: 31/255, green: 218/255, blue: 162/255, opacity: 1)],
        "Core": [Color(red: 0, green: 0, blue: 0, opacity: 1)],
        "Deep": [Color.blue, Color.indigo]
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
                    .shadow(color: .blue.opacity(0.3), radius: 5, x: 0, y: 5)
            )
        }
        .padding()
    }
}
