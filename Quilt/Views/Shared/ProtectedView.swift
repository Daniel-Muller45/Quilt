import SwiftUI

struct ProtectedView<Content: View>: View {
    @EnvironmentObject var auth: AuthViewModel
    let content: () -> Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
            Group {
                if auth.session != nil {
                    content()
                } else {
                    LoginView()
                        .environmentObject(auth)
                }
            }
        }
}
