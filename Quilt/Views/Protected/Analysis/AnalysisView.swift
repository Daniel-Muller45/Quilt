import SwiftUI
import SwiftData
import Charts

struct MonthlyContribution: Identifiable {
    let id = UUID()
    let date: Date
    let amount: Double
}

struct PerformanceTestPoint: Identifiable {
    let id = UUID()
    let date: Date
    let value: Double
    let type: String
}

struct SectorAllocation: Identifiable {
    let id = UUID()
    let sector: String
    let percentage: Double
}

@Observable
class AnalysisViewModel {
    var contributions: [MonthlyContribution] = []
    var performanceData: [PerformanceTestPoint] = []
    var allocationData: [SectorAllocation] = []
    
    init() {
        generateMockData()
    }
    
    func generateMockData() {
        let calendar = Calendar.current
        let today = Date()
        
        for i in 0..<6 {
            if let date = calendar.date(byAdding: .month, value: -i, to: today) {
                contributions.append(.init(date: date, amount: Double.random(in: 500...1500)))
            }
        }
        contributions.sort { $0.date < $1.date }
        
        for i in 0..<12 {
            if let date = calendar.date(byAdding: .month, value: -i, to: today) {
                let baseValue = 10000.0 + (Double(12 - i) * 500)
                performanceData.append(.init(date: date, value: baseValue * Double.random(in: 0.95...1.1), type: "My Portfolio"))
                performanceData.append(.init(date: date, value: baseValue * Double.random(in: 0.98...1.05), type: "S&P 500"))
            }
        }
        performanceData.sort { $0.date < $1.date }
        
        allocationData = [
            .init(sector: "Tech", percentage: 0.45),
            .init(sector: "Finance", percentage: 0.20),
            .init(sector: "Health", percentage: 0.15),
            .init(sector: "Energy", percentage: 0.10),
            .init(sector: "Other", percentage: 0.10)
        ]
    }
}

struct AnalysisView: View {
    let token: String
    @State private var viewModel = AnalysisViewModel()
    
    @Environment(\.colorScheme) var scheme

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                CustomHeader(
                    title: "Analysis",
                    token: token
                )
                
                HStack(spacing: 12) {
                    MetricCard(title: "YTD Return", value: "+12.4%", icon: "arrow.up.right", color: .green)
                    MetricCard(title: "Dividends", value: "$342.50", icon: "dollarsign.circle", color: .blue)
                }
                .padding(.horizontal)

                VStack(alignment: .leading) {
                    Text("Performance vs S&P 500")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    Chart {
                        ForEach(viewModel.performanceData) { point in
                            LineMark(
                                x: .value("Date", point.date),
                                y: .value("Value", point.value)
                            )
                            .foregroundStyle(by: .value("Type", point.type))
                            .interpolationMethod(.catmullRom)
                        }
                    }
                    .chartYAxis {
                        AxisMarks(position: .leading)
                    }
                    .chartForegroundStyleScale([
                        "My Portfolio": .purple,
                        "S&P 500": .gray
                    ])
                    .frame(height: 250)
                    .padding()
                    .background(Color(uiColor: .secondarySystemBackground))
                    .cornerRadius(16)
                    .padding(.horizontal)
                }

                VStack(alignment: .leading) {
                    Text("Monthly Contributions")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    Chart(viewModel.contributions) { item in
                        BarMark(
                            x: .value("Month", item.date, unit: .month),
                            y: .value("Amount", item.amount)
                        )
                        .foregroundStyle(LinearGradient(colors: [.blue, .cyan], startPoint: .bottom, endPoint: .top))
                        .annotation(position: .top) {
                            Text("$\(Int(item.amount))")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                    .frame(height: 200)
                    .padding()
                    .background(Color(uiColor: .secondarySystemBackground))
                    .cornerRadius(16)
                    .padding(.horizontal)
                }
                
                VStack(alignment: .leading) {
                    Text("Sector Allocation")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    Chart(viewModel.allocationData) { item in
                        SectorMark(
                            angle: .value("Allocation", item.percentage),
                            innerRadius: .ratio(0.6),
                            angularInset: 1.5
                        )
                        .foregroundStyle(by: .value("Sector", item.sector))
                        .cornerRadius(5)
                    }
                    .frame(height: 250)
                    .padding()
                    .background(Color(uiColor: .secondarySystemBackground))
                    .cornerRadius(16)
                    .padding(.horizontal)
                }
                
                Spacer().frame(height: 50)
            }
        }
        .background(Color(uiColor: .systemBackground))
    }
}

struct MetricCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Spacer()
            }
            
            Text(value)
                .font(.title3)
                .bold()
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(uiColor: .secondarySystemBackground))
        .cornerRadius(12)
    }
}
