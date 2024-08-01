import SwiftUI
import Charts

struct HeartRateRangeChart: View {

    @ObservedObject var healthKitManager = HealthKitManager()
    
    @State private var barWidth = 15.0
    @State private var chartColor: Color = Color(red: 31/255, green: 89/255, blue: 218/255) // Blue color
    
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
                        .shadow(color: chartColor.opacity(0.3), radius: 5, x: 0, y: 5) // Use chartColor for shadow
                        .padding(.horizontal, 10)
                )
        }
    }
    
    private var chart: some View {
        
        Chart(healthKitManager.heartRateData, id: \.weekday) { dataPoint in
            Plot {
                BarMark(
                    x: .value("Day", dataPoint.weekday, unit: .day),
                    yStart: .value("BPM Min", dataPoint.dailyMin),
                    yEnd: .value("BPM Max", dataPoint.dailyMax),
                    width: .fixed(barWidth)
                )
                .clipShape(Capsule())
                .foregroundStyle(chartColor.gradient) // Use chartColor for foreground style
                
                if dataPoint.dailyMin == healthKitManager.minBPM {
                    PointMark(
                        x: .value("Day", dataPoint.weekday, unit: .day),
                        y: .value("BPM Min", dataPoint.dailyMin + 7)
                    )
                    .foregroundStyle(.black)
                    .accessibilityLabel("Minimum BPM \(dataPoint.dailyMin)")
                    .accessibilityValue(dataPoint.weekday.weekdayString)
                    .annotation(position: .bottom) {
                        Text("Min \n\(healthKitManager.minBPM)")
                            .font(.callout)
                            .fontWeight(.bold)
                            .foregroundColor(chartColor) // Use chartColor for text color
                    }
                }
                
                if dataPoint.dailyMax == healthKitManager.maxBPM {
                    PointMark(
                        x: .value("Day", dataPoint.weekday, unit: .day),
                        y: .value("BPM Min", dataPoint.dailyMax - 7)
                    )
                    .foregroundStyle(.black)
                    .accessibilityLabel("Maximum BPM \(dataPoint.dailyMin)")
                    .accessibilityValue(dataPoint.weekday.weekdayString)
                    .annotation(position: .top) {
                        Text("Max \n\(healthKitManager.maxBPM)")
                            .font(.callout)
                            .fontWeight(.bold)
                            .foregroundColor(chartColor) // Use chartColor for text color
                    }
                }
                
            }
            .accessibilityLabel(dataPoint.weekday.weekdayString)
            .accessibilityValue("\(dataPoint.dailyMin) to \(dataPoint.dailyMax) BPM")
            .accessibilityHidden(false)

        }
        .chartXAxis {
            AxisMarks(values: .stride(by: ChartStrideBy.day.time)) { _ in
                AxisTick()
                AxisGridLine()
                AxisValueLabel(format: .dateTime.weekday(.abbreviated))
            }
        }
        .accessibilityChartDescriptor(self)
        .chartYAxis(.automatic)
        .chartXAxis(.automatic)
        .frame(height: 300)
        
    }
}

// MARK: - Accessibility

extension HeartRateRangeChart: AXChartDescriptorRepresentable {
    func makeChartDescriptor() -> AXChartDescriptor {
        
        let dateStringConverter: ((Date) -> (String)) = { date in
            date.formatted(date: .complete, time: .omitted)
        }
        
        let min = healthKitManager.heartRateData.map(\.dailyMin).min() ?? 0
        let max = healthKitManager.heartRateData.map(\.dailyMax).max() ?? 0
        
        let xAxis = AXCategoricalDataAxisDescriptor(
            title: "Day",
            categoryOrder: healthKitManager.heartRateData.map { dateStringConverter($0.weekday) }
        )

        let yAxis = AXNumericDataAxisDescriptor(
            title: "Heart Rate",
            range: Double(min)...Double(max),
            gridlinePositions: []
        ) { value in "Average: \(Int(value)) BPM" }

        let series = AXDataSeriesDescriptor(
            name: "Last Week",
            isContinuous: false,
            dataPoints: healthKitManager.heartRateData.map {
                .init(x: dateStringConverter($0.weekday),
                      y: Double($0.dailyAverage),
                      label: "Min: \($0.dailyMin) BPM, Max: \($0.dailyMax) BPM")
            }
        )

        return AXChartDescriptor(
            title: "Heart Rate range",
            summary: nil,
            xAxis: xAxis,
            yAxis: yAxis,
            additionalAxes: [],
            series: [series]
        )
    }
}

// MARK: - Preview

struct HeartRateRangeChart_Previews: PreviewProvider {
    static var previews: some View {
        HeartRateRangeChart()
    }
}

func date(year: Int, month: Int, day: Int = 1, hour: Int = 0, minutes: Int = 0, seconds: Int = 0) -> Date {
    Calendar.current.date(from: DateComponents(year: year, month: month, day: day, hour: hour, minute: minutes, second: seconds)) ?? Date()
}

enum Constants {
    static let previewChartHeight: CGFloat = 100
    static let detailChartHeight: CGFloat = 300
}

enum ChartStrideBy: Identifiable, CaseIterable {
    case second
    case minute
    case hour
    case day
    case weekday
    case weekOfYear
    case month
    case year
    
    var id: String { title }
    
    var title: String {
        switch self {
        case .second:
            return "Second"
        case .minute:
            return "Minute"
        case .hour:
            return "Hour"
        case .day:
            return "Day"
        case .weekday:
            return "Weekday"
        case .weekOfYear:
            return "Week of Year"
        case .month:
            return "Month"
        case .year:
            return "Year"
        }
    }
    
    var time: Calendar.Component {
        switch self {
        case .second:
            return .second
        case .minute:
            return .minute
        case .hour:
            return .hour
        case .day:
            return .day
        case .weekday:
            return .weekday
        case .weekOfYear:
            return .weekOfYear
        case .month:
            return .month
        case .year:
            return .year
        }
    }
}

extension Date {
    // Used for charts where the day of the week is used: visually  M/T/W etc
    // (but we want VoiceOver to read out the full day)
    var weekdayString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"

        return formatter.string(from: self)
    }
}
