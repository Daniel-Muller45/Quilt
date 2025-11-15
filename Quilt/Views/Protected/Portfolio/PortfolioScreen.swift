import SwiftUI
import SwiftData

struct PortfolioScreen: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var vm = PortfolioViewModel()
    private let token: String

    init(token: String) { self.token = token }

    var body: some View {
        NavigationStack {
            VStack {
                PortfolioSummaryView(token: token)
            }
        }
        .onAppear { vm.bind(modelContext: modelContext) }
        .task { await vm.refreshAll(token: token) }
    }
}
