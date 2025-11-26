import SwiftUI
import Charts // Requires iOS 16+

// MARK: - Models

enum SentimentType: String, CaseIterable {
    case bullish = "Bullish"
    case bearish = "Bearish"
    case neutral = "Neutral"
    
    var color: Color {
        switch self {
        case .bullish: return .green
        case .bearish: return .red
        case .neutral: return .yellow
        }
    }
    
    var icon: String {
        switch self {
        case .bullish: return "arrow.up.right.circle.fill"
        case .bearish: return "arrow.down.right.circle.fill"
        case .neutral: return "minus.circle.fill"
        }
    }
}

struct Stock: Identifiable {
    let id = UUID()
    let symbol: String
    let name: String
    let price: Double
    let changePercent: Double
    let shares: Double
    
    var value: Double { price * shares }
}

struct AIInsight: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let sentiment: SentimentType
    let relatedSymbol: String?
    let confidenceScore: Double // 0.0 to 1.0
}

// MARK: - View Model

class PortfolioTestViewModel: ObservableObject {
    @Published var portfolioValue: Double = 142500.00
    @Published var dayChange: Double = 1250.50
    @Published var dayChangePercent: Double = 0.88
    
    @Published var holdings: [Stock] = [
        Stock(symbol: "AAPL", name: "Apple Inc.", price: 175.50, changePercent: 1.2, shares: 150),
        Stock(symbol: "TSLA", name: "Tesla, Inc.", price: 240.00, changePercent: -2.5, shares: 50),
        Stock(symbol: "NVDA", name: "NVIDIA Corp.", price: 460.00, changePercent: 3.1, shares: 40),
        Stock(symbol: "MSFT", name: "Microsoft", price: 330.00, changePercent: 0.5, shares: 80)
    ]
    
    @Published var aiInsights: [AIInsight] = [
        AIInsight(
            title: "Tech Sector Resilience",
            description: "Despite market volatility, your heavy allocation in Tech (65%) is shielded by strong earnings reports from NVDA and AAPL. Recommend holding current positions.",
            sentiment: .bullish,
            relatedSymbol: nil,
            confidenceScore: 0.92
        ),
        AIInsight(
            title: "Tesla Volatility Alert",
            description: "Recent supply chain disruptions may impact TSLA's Q4 margins. AI models predict short-term downside risk tailored to your $12k exposure.",
            sentiment: .bearish,
            relatedSymbol: "TSLA",
            confidenceScore: 0.75
        ),
        AIInsight(
            title: "Diversification Opportunity",
            description: "Your portfolio shows low correlation with Energy sectors. Consider rebalancing dividends into XLE to reduce beta.",
            sentiment: .neutral,
            relatedSymbol: nil,
            confidenceScore: 0.85
        )
    ]
}

// MARK: - Components

struct InsightCard: View {
    let insight: AIInsight
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "sparkles")
                        .font(.caption)
                    Text("AI Analysis")
                        .font(.caption)
                        .fontWeight(.bold)
                        .textCase(.uppercase)
                }
                .foregroundStyle(.purple)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.purple.opacity(0.1))
                .cornerRadius(8)
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: insight.sentiment.icon)
                    Text(insight.sentiment.rawValue)
                }
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(insight.sentiment.color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(insight.title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                Text(insight.description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            HStack {
                if let symbol = insight.relatedSymbol {
                    Text("Related to \(symbol)")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.secondary.opacity(0.1))
                        .cornerRadius(4)
                }
                
                Spacer()
                
                Text("Confidence: \(Int(insight.confidenceScore * 100))%")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(LinearGradient(colors: [.purple.opacity(0.3), .blue.opacity(0.1)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1)
        )
    }
}

struct StockRow: View {
    let stock: Stock
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(stock.symbol)
                    .font(.headline)
                    .fontWeight(.bold)
                Text(stock.name)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            // Sparkline placeholder (Chart)
            Chart {
                RuleMark(y: .value("Zero", 0))
                    .foregroundStyle(.clear)
                // Mock data points for visual flair
                LineMark(x: .value("1", 0), y: .value("Price", stock.price * 0.98))
                LineMark(x: .value("2", 1), y: .value("Price", stock.price * 1.01))
                LineMark(x: .value("3", 2), y: .value("Price", stock.price * 0.99))
                LineMark(x: .value("4", 3), y: .value("Price", stock.price))
            }
            .chartXAxis(.hidden)
            .chartYAxis(.hidden)
            .foregroundStyle(stock.changePercent >= 0 ? .green : .red)
            .frame(width: 60, height: 30)
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(stock.price.formatted(.currency(code: "USD")))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text("\(stock.changePercent >= 0 ? "+" : "")\(String(format: "%.2f", stock.changePercent))%")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(stock.changePercent >= 0 ? Color.green : Color.red)
                    .cornerRadius(4)
            }
            .frame(width: 80, alignment: .trailing)
        }
        .padding(.vertical, 8)
    }
}

struct PortfolioHeader: View {
    @ObservedObject var vm: PortfolioTestViewModel
    
    var body: some View {
        VStack(spacing: 8) {
            Text("Total Balance")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Text(vm.portfolioValue.formatted(.currency(code: "USD")))
                .font(.system(size: 40, weight: .bold, design: .rounded))
            
            HStack {
                Image(systemName: vm.dayChange >= 0 ? "arrow.up.right" : "arrow.down.right")
                Text("\(vm.dayChange.formatted(.currency(code: "USD"))) (\(String(format: "%.2f", vm.dayChangePercent))%)")
            }
            .font(.headline)
            .foregroundStyle(vm.dayChange >= 0 ? .green : .red)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(vm.dayChange >= 0 ? Color.green.opacity(0.15) : Color.red.opacity(0.15))
            .cornerRadius(20)
        }
        .padding(.vertical, 20)
    }
}

// MARK: - Main Screen

struct PortfolioAnalysisView: View {
    @StateObject private var viewModel = PortfolioTestViewModel()
    @State private var selectedTab = "Insights"
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header Section
                    PortfolioHeader(vm: viewModel)
                    
                    // Segmented Control
                    Picker("View", selection: $selectedTab) {
                        Text("Overview").tag("Overview")
                        Text("AI Insights").tag("Insights")
                        Text("News").tag("News")
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    
                    if selectedTab == "Insights" {
                        // AI Summary Section
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("Portfolio Health")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                Spacer()
                                Label("AI Active", systemImage: "bolt.fill")
                                    .font(.caption)
                                    .foregroundStyle(.purple)
                            }
                            .padding(.horizontal)
                            
                            // Health Score Card
                            HStack(spacing: 20) {
                                ZStack {
                                    Circle()
                                        .stroke(Color.gray.opacity(0.2), lineWidth: 10)
                                    Circle()
                                        .trim(from: 0, to: 0.85)
                                        .stroke(
                                            LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing),
                                            style: StrokeStyle(lineWidth: 10, lineCap: .round)
                                        )
                                        .rotationEffect(.degrees(-90))
                                    
                                    VStack {
                                        Text("85")
                                            .font(.title)
                                            .fontWeight(.bold)
                                        Text("Score")
                                            .font(.caption2)
                                            .textCase(.uppercase)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                .frame(width: 80, height: 80)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Excellent Shape")
                                        .font(.headline)
                                    Text("Your portfolio is well diversified, though slightly overweight in Tech. Risk levels are within your defined tolerance.")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(3)
                                }
                            }
                            .padding()
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(16)
                            .padding(.horizontal)
                            
                            // Insights Feed
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Key Insights")
                                    .font(.headline)
                                    .padding(.horizontal)
                                
                                ForEach(viewModel.aiInsights) { insight in
                                    InsightCard(insight: insight)
                                        .padding(.horizontal)
                                }
                            }
                        }
                    } else {
                        // Fallback/Stock List View
                        VStack(alignment: .leading) {
                            Text("Holdings")
                                .font(.title3)
                                .fontWeight(.bold)
                                .padding(.horizontal)
                            
                            ForEach(viewModel.holdings) { stock in
                                StockRow(stock: stock)
                                    .padding(.horizontal)
                                Divider()
                                    .padding(.leading)
                            }
                        }
                    }
                }
                .padding(.bottom, 20)
            }
            .navigationTitle("Portfolio AI")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {}) {
                        Image(systemName: "bell.badge")
                    }
                }
            }
        }
    }
}

// MARK: - Preview

struct PortfolioAnalysisView_Previews: PreviewProvider {
    static var previews: some View {
        PortfolioAnalysisView()
            .preferredColorScheme(.dark)
    }
}
