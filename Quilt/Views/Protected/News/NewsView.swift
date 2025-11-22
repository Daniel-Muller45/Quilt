import SwiftUI
import SwiftData

struct NewsView: View {
    let token: String

    var body: some View {
        VStack(spacing: 0) {
            CustomHeader(
                title: "News",
                token: token
            )
        }
    }
}
