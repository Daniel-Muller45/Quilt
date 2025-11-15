import SwiftUI
import SwiftData

@main
struct QuiltApp: App {
    @StateObject var linkBus = LinkBus()

    var body: some Scene {
        WindowGroup {
            RootWithDump() // <— wrap your root so we can access modelContext
                .environmentObject(linkBus)
                .onOpenURL { url in
                    print("📬 onOpenURL:", url.absoluteString)
                    linkBus.lastURL = url
                }
        }
        .modelContainer(sharedContainer)
    }
}

let sharedContainer: ModelContainer = {
    let schema = Schema([Portfolio.self, Account.self, Holding.self])
    let config = ModelConfiguration(isStoredInMemoryOnly: false)
    // ❌ Don’t call debugPrintSwiftDataContents() here — not on MainActor.
    return try! ModelContainer(for: schema, configurations: [config])
}()

final class LinkBus: ObservableObject {
    @Published var lastURL: URL?
}

/// A tiny wrapper so we can access the SwiftData context
struct RootWithDump: View {
    @Environment(\.modelContext) private var context

    var body: some View {
        AuthRootView()
            .task {
                // Run on main actor after the model container is attached
                await MainActor.run {
                    debugPrintSwiftDataContents(context)
                }
            }
    }
}

@MainActor
func debugPrintSwiftDataContents(_ context: ModelContext) {
    print("=== 🧠 SwiftData Debug Dump ===")
    do {
        let accounts = try context.fetch(FetchDescriptor<Account>())
        print("\n📘 Accounts (\(accounts.count))")
        for a in accounts {
            print("""
                - id: \(a.id)
                  name: \(a.name)
                  brokerage: \(a.brokerage)
                  currency: \(a.currency)
                  lastSyncedAt: \(String(describing: a.lastSyncedAt))
                """)
        }

        let holdings = try context.fetch(FetchDescriptor<Holding>())
        print("\n💼 Holdings (\(holdings.count))")
        for h in holdings {
            print("""
                - id: \(h.id)
                  symbol: \(h.symbol)
                  quantity: \(h.quantity)
                  avgCost: \(h.avgCost)
                """)
        }

        let portfolios = try context.fetch(FetchDescriptor<Portfolio>())
        print("\n📊 Portfolios (\(portfolios.count))")
        for p in portfolios {
            print("""
                - asOf: \(p.asOf)
                  accounts: \(p.accounts.count)
                """)
        }

        print("=== ✅ End of SwiftData Dump ===\n")
    } catch {
        print("❌ Error fetching SwiftData contents: \(error)")
    }
}
