import SwiftUI
import SwiftData


@main
struct QuiltApp: App {

    var body: some Scene {
        WindowGroup {
            AuthRootView()
        }
        .modelContainer(sharedContainer)
    }
}

let sharedContainer: ModelContainer = {
    let schema = Schema([Portfolio.self, Account.self, Holding.self])
    let config = ModelConfiguration(isStoredInMemoryOnly: false)
    return try! ModelContainer(for: schema, configurations: [config])
}()
