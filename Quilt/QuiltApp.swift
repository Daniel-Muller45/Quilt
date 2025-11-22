import SwiftUI
import SwiftData

@main
struct QuiltApp: App {
    @StateObject var linkBus = LinkBus()

    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.black
        appearance.shadowColor = nil
        appearance.shadowImage = nil

        UITabBar.appearance().standardAppearance = appearance

        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }

        UITabBar.appearance().unselectedItemTintColor = UIColor.gray
    }

    var body: some Scene {
        WindowGroup {
            AuthRootView()
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
    return try! ModelContainer(for: schema, configurations: [config])
}()

final class LinkBus: ObservableObject {
    @Published var lastURL: URL?
}
