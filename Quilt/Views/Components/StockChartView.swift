import SwiftUI
import Charts
import SwiftData

struct StockHistoryChartView: View {
    @StateObject private var vm = StockHistoryViewModel()
    @Binding var selectedTimeframe: Timeframe
    
    @State private var selectedSnapshot: StockSnapshot?
    @State private var isHovering = false
    
    let ticker: String
    
    private var filteredSnapshots: [StockSnapshot] {
        guard !vm.snapshots.isEmpty else { return [] }
        
        let all = vm.snapshots
        let calendar = Calendar.current
        guard let latestDate = all.last?.date else { return [] }
        
        let cutoff: Date?
        switch selectedTimeframe {
        case .d1: cutoff = calendar.date(byAdding: .day, value: -1, to: latestDate)
        case .w1: cutoff = calendar.date(byAdding: .day, value: -7, to: latestDate)
        case .m6: cutoff = calendar.date(byAdding: .month, value: -6, to: latestDate)
        case .ytd: cutoff = calendar.date(from: calendar.dateComponents([.year], from: latestDate))
        case .y1: cutoff = calendar.date(byAdding: .year, value: -1, to: latestDate)
        case .y5: cutoff = calendar.date(byAdding: .year, value: -5, to: latestDate)
        }
        
        guard let cutoffDate = cutoff else { return all }
        return all.filter { $0.date >= cutoffDate }
    }
    
    // Updated Logic: Returns (change, optional percent)
    private var performanceMetrics: (change: Double, percent: Double?)? {
        let snaps = filteredSnapshots
        guard let first = snaps.first, let last = snaps.last else { return nil }
        
        // Logic: Compare Start of Period vs (Hovered Value OR Last Value)
        let endValue = selectedSnapshot?.close ?? last.close
        let startValue = first.close
        
        let change = endValue - startValue
        
        let percent: Double?
        
        // Check for division by zero
        if startValue == 0 {
            percent = nil
        } else {
            percent = change / startValue
        }
        
        return (change, percent)
    }
    
    private var displayedCurrentValue: String? {
        let snaps = filteredSnapshots
        guard !snaps.isEmpty else { return nil }
        if let selectedSnapshot { return selectedSnapshot.close.formatted(.currency(code: "USD")) }
        if let last = snaps.last { return last.close.formatted(.currency(code: "USD")) }
        return nil
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            if vm.isLoading {
                ProgressView()
            } else if let error = vm.error {
                Text(error).foregroundStyle(.red).font(.subheadline)
            } else if filteredSnapshots.isEmpty {
                Text("No portfolio history for this period.")
                    .font(.subheadline).foregroundStyle(.secondary)
            } else {
                let snaps = filteredSnapshots
                
                let minVal = snaps.map(\.close).min() ?? 0
                let minValAdjusted = minVal * 0.95
                let maxVal = snaps.map(\.close).max() ?? 0
                let domainMin = minValAdjusted
                let domainMax = (maxVal > minValAdjusted) ? maxVal : minValAdjusted + 0.01
                
                let metrics = performanceMetrics
                let isUp = (metrics?.change ?? 0) >= 0
                let perfColor: Color = isUp ? .green : .red
                let arrow = isUp ? "arrowtriangle.up.fill" : "arrowtriangle.down.fill"
                // Use the perfColor for the chart line to reflect the current performance state
                let chartColor: Color = perfColor
                
                if let currentValueText = displayedCurrentValue {
                    Text(currentValueText)
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.white)
                }
                
                if let metrics = metrics {
                    HStack(spacing: 4) {
                        Image(systemName: arrow).font(.caption).foregroundStyle(perfColor)
                        
                        // Always show dollar change
                        Text(String(format: "%@%.2f", isUp ? "+" : "", metrics.change))
                            .foregroundStyle(perfColor)
                        
                        // Conditionally show percentage change
                        if let percent = metrics.percent {
                            Text(String(format: "(%@%.2f%%)", isUp ? "+" : "", percent * 100))
                                .foregroundStyle(perfColor)
                        } else {
                            // Display a dash or "N/A" if the percentage cannot be calculated (Start Value was 0)
                            Text("")
                                .foregroundStyle(perfColor)
                        }
                        
                        Text("Return").foregroundColor(.secondary)
                    }
                    .font(.subheadline.weight(.semibold))
                }
                
                // Dynamic Date Label
                if let selectedSnapshot {
                    let date = selectedSnapshot.date
                    // If the date is NOT today, force it to 4:00 PM (16:00)
                    let isToday = Calendar.current.isDateInToday(date)
                    let displayDate = isToday ? date : (Calendar.current.date(bySettingHour: 16, minute: 0, second: 0, of: date) ?? date)
                    
                    Text("On \(displayDate.formatted(date: .abbreviated, time: .shortened))")
                        .font(.caption).foregroundColor(.secondary)
                        .transition(.opacity)
                } else {
                    Text("As of \(Date.now.formatted(date: .abbreviated, time: .shortened))")
                        .font(.caption).foregroundColor(.secondary)
                        .transition(.opacity)
                }
                
                Chart(snaps) { snapshot in
                    if let first = snaps.first {
                            RuleMark(
                                y: .value("Start Value", first.close)
                            )
                            .foregroundStyle(Color.gray.opacity(0.4))
                            .lineStyle(StrokeStyle(lineWidth: 1, dash: [3]))
                        }
                    
                    LineMark(
                        x: .value("Date", snapshot.date),
                        y: .value("Total Value", snapshot.close)
                    )
                    .foregroundStyle(chartColor)
                    .interpolationMethod(.monotone)
                    
                    AreaMark(
                        x: .value("Date", snapshot.date),
                        y: .value("Total Value", snapshot.close)
                    )
                    .foregroundStyle(chartColor.opacity(0.0))
                    .interpolationMethod(.monotone)
                    
                    if let selectedSnapshot, selectedSnapshot.date == snapshot.date {
                        RuleMark(
                            x: .value("Date", selectedSnapshot.date),
                            yStart: .value("Start", domainMin),
                            yEnd: .value("End", domainMax)
                        )
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [5]))
                        .foregroundStyle(Color.white.opacity(0.3))
                        
                        PointMark(
                            x: .value("Date", snapshot.date),
                            y: .value("Total Value", snapshot.close)
                        )
                        .symbolSize(80)
                        .foregroundStyle(.white)
                    }
                }
                .chartYScale(domain: domainMin...domainMax)
                .frame(height: 160)
                .chartXAxis(.hidden)
                .chartYAxis(.hidden)
                
                .chartOverlay { proxy in
                    GeometryReader { geo in
                        let plotFrame = geo[proxy.plotAreaFrame]
                        let snaps = filteredSnapshots
                        
                        // Gesture definition: Long Press (0.25s) -> Drag
                        let longPress = LongPressGesture(minimumDuration: 0.25, maximumDistance: 30)
                        let drag = DragGesture(minimumDistance: 0)
                        let combinedGesture = longPress.sequenced(before: drag)
                        
                        Rectangle()
                            .fill(Color.clear)
                            .contentShape(Rectangle())
                            .gesture(
                                combinedGesture
                                    .onChanged { value in
                                        switch value {
                                        // Case 1: Long press matches, drag hasn't started or is in progress
                                        case .second(true, let drag):
                                            // Entering hover mode
                                            if !isHovering { isHovering = true }
                                            
                                            // If we have drag data, update the snapshot
                                            if let location = drag?.location {
                                                let locationX = location.x - plotFrame.origin.x
                                                
                                                if locationX >= 0 && locationX <= plotFrame.width {
                                                    if let date: Date = proxy.value(atX: locationX) {
                                                        if let nearest = snaps.min(by: {
                                                            abs($0.date.timeIntervalSince(date)) < abs($1.date.timeIntervalSince(date))
                                                        }) {
                                                            selectedSnapshot = nearest
                                                        }
                                                    }
                                                }
                                            }
                                        default:
                                            break
                                        }
                                    }
                                    .onEnded { _ in
                                        isHovering = false
                                        selectedSnapshot = nil
                                    }
                            )
                    }
                }
                .sensoryFeedback(.impact(weight: .medium, intensity: 1.0), trigger: isHovering) { oldValue, newValue in
                    return newValue == true
                }
                .sensoryFeedback(.selection, trigger: selectedSnapshot?.date)
            }
        }
        .padding()
        .task { await vm.load(ticker: ticker) }
    }
}
