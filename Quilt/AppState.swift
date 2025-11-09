import Foundation
import Combine

final class AppState: ObservableObject {
    @Published var isSignedIn: Bool = false
    @Published var isSyncing: Bool = false
}
