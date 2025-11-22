import SwiftUI
import Charts
import SwiftData

struct PortfolioHistoryChartView: View {
    @StateObject private var vm = PortfolioHistoryViewModel()
    @Binding var selectedTimeframe: Timeframe
    
    @State private var selectedSnapshot: PortfolioSnapshot?
    @State private var isHovering = false
    
    private var filteredSnapshots: [PortfolioSnapshot] {
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
    
    private var performanceMetrics: (change: Double, percent: Double)? {
        let snaps = filteredSnapshots
        guard let first = snaps.first, let last = snaps.last, first.totalValue > 0 else { return nil }
        let start = first.totalValue
        let end = last.totalValue
        let change = end - start
        return (change, change / start)
    }
    
    private var displayedCurrentValue: String? {
        let snaps = filteredSnapshots
        guard !snaps.isEmpty else { return nil }
        if let selectedSnapshot { return selectedSnapshot.totalValue.formatted(.currency(code: "USD")) }
        if let last = snaps.last { return last.totalValue.formatted(.currency(code: "USD")) }
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
                
                let minVal = snaps.map(\.totalValue).min() ?? 0
                let minValAdjusted = minVal * 0.95
                let maxVal = snaps.map(\.totalValue).max() ?? 0
                let domainMin = minValAdjusted
                let domainMax = (maxVal > minValAdjusted) ? maxVal : minValAdjusted + 0.01
                
                let metrics = performanceMetrics
                let isUp = (metrics?.change ?? 0) >= 0
                let perfColor: Color = isUp ? .green : .red
                let arrow = isUp ? "arrowtriangle.up.fill" : "arrowtriangle.down.fill"
                let chartColor: Color = perfColor
                
                if let currentValueText = displayedCurrentValue {
                    Text(currentValueText)
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.white)
                }
                
                if let metrics = metrics {
                    HStack(spacing: 4) {
                        Image(systemName: arrow).font(.caption).foregroundStyle(perfColor)
                        Text(String(format: "%@%.2f", isUp ? "+" : "", metrics.change)).foregroundStyle(perfColor)
                        Text(String(format: "%@%.2f%%", isUp ? "+" : "", metrics.percent * 100)).foregroundStyle(perfColor)
                        Text("Today").foregroundColor(.white)
                    }
                    .font(.subheadline.weight(.semibold))
                }
                
                Text("As of \(Date.now.formatted(date: .abbreviated, time: .shortened))")
                    .font(.caption).foregroundColor(.secondary)
                
                                Chart(snaps) { snapshot in
                                    
                                    LineMark(
                                        x: .value("Date", snapshot.date),
                                        y: .value("Total Value", snapshot.totalValue)
                                    )
                                    .foregroundStyle(chartColor)
                                    .interpolationMethod(.monotone)
                                    
                                    AreaMark(
                                        x: .value("Date", snapshot.date),
                                        y: .value("Total Value", snapshot.totalValue)
                                    )
                                    .foregroundStyle(chartColor.opacity(0.25))
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
                                            y: .value("Total Value", snapshot.totalValue)
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
                        
                        let longPress = LongPressGesture(minimumDuration: 0.3, maximumDistance: 30)
                        let dragSequence = DragGesture(minimumDistance: 0)
                        
                        let mainGesture = longPress.sequenced(before: dragSequence)
                            .onChanged { value in
                                switch value {
                                case .second(true, let drag):
                                    if !isHovering { isHovering = true }
                                    
                                    if let location = drag?.location {
                                        let locationX = location.x - plotFrame.origin.x
                                        guard locationX >= 0, locationX <= plotFrame.size.width else { return }
                                        
                                        if let date: Date = proxy.value(atX: locationX) {
                                            if let nearest = snaps.min(by: {
                                                abs($0.date.timeIntervalSince(date)) < abs($1.date.timeIntervalSince(date))
                                            }) {
                                                selectedSnapshot = nearest
                                            }
                                        }
                                    }
                                default: break
                                }
                            }
                            .onEnded { _ in
                                isHovering = false
                                selectedSnapshot = nil
                            }
                        
                        Rectangle()
                            .fill(Color.clear)
                            .contentShape(Rectangle())
                            .gesture(mainGesture)
                    }
                }
                                .sensoryFeedback(.impact(weight: .medium, intensity: 1.0), trigger: isHovering) { oldValue, newValue in
                                    return newValue == true
                                }
                                .sensoryFeedback(.selection, trigger: selectedSnapshot?.date)
            }
        }
        .padding()
        .task { await vm.load() }
    }
}
