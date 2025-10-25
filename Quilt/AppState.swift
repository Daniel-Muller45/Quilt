import Foundation
import Combine

final class AppState: ObservableObject {
    @Published var isSignedIn: Bool = false
    @Published var portfolio: [Stock] = []
    @Published var isSyncing: Bool = false
}
