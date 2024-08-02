//
//  SleepGraphView.swift
//  SwiftUI Charts
//
//  Created by Sanjeev Mehta on 16/06/24.
//

import SwiftUI
import Charts

struct SleepGraphView: View {
   // @Binding var animatedData: [SleepData]
    let data: [SleepData]
    
    let categoryColors: [String: [Color]] = [
        "Awake": [Color(hex: "1F59DA"), Color(hex: "1F59DA")],
        "REM": [Color(hex: "15203D"), Color(hex: "15203D")],
        "Core": [Color(hex: "243155"), Color(hex: "243155")],
        "Deep": [Color(hex: "5C85DF"), Color(hex: "5C85DF")]
    ]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Sleep Analysis")
                .font(.largeTitle)
                .bold()
                .padding([.top, .leading])
            
            Chart {
                ForEach(data) { data in
                    BarMark(
                        x: .value("Category", data.category),
                        y: .value("Hours", data.hours)
                    )
                    .clipShape(CustomBarShape())
                    .foregroundStyle(
                        LinearGradient(
                            gradient: Gradient(colors: categoryColors[data.category]!),
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
