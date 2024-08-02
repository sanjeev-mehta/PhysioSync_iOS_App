//
//  ContentView.swift
//  SwiftUI Charts
//
//  Created by Sanjeev Mehta on 15/06/24.
//

import SwiftUI
import Charts

struct Item: Identifiable {
    var id = UUID()
    var type: String
    let value: Double
}

struct ContentView: View {
    @State private var animatedData: [SleepData] = []
    @ObservedObject var healthKitManager = HealthKitManager()
    var watchData: WatchData? = nil
    
    let items: [Item] = [Item(type: "Engineering", value: 100),Item(type: "Design", value: 35),Item(type: "Operation", value: 72),Item(type: "Management", value: 22), Item(type: "R&D", value: 72)]
    
    let sleepData: [SleepData] = [
        SleepData(category: "Awake", hours: 1.5),
        SleepData(category: "REM", hours: 2.0),
        SleepData(category: "Core", hours: 3.0),
        SleepData(category: "Deep", hours: 1.5)
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                SleepGraphView(data: sleepData)
                    .onAppear {
                        startAnimation()
                    }
                
                Spacer()
                
                HeartRateRangeChart()
                Spacer()
                
                CalorieChartView()
                
                StepsChartView()
            }
        }
        .navigationTitle("Charts")
    }
    
    private func startAnimation() {
        withAnimation(.easeInOut(duration: 1.0)) {
            animatedData = sleepData
        }
    }
}

#Preview {
    ContentView()
}

struct CustomBarShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let topRadius: CGFloat = 16.0 // Adjust the radius as needed
        
        // Define the rounded top
        path.addRoundedRect(in: CGRect(x: rect.origin.x, y: rect.origin.y, width: rect.width, height: rect.height), cornerSize: CGSize(width: topRadius, height: topRadius))
        
        // Draw the bottom part as a rectangle
        path.addRect(CGRect(x: rect.origin.x, y: rect.origin.y + topRadius, width: rect.width, height: rect.height - topRadius))
        
        return path
    }
}


