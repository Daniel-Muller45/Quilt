import SwiftUI

struct ConnectBrokerageView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("Connect a new brokerage")
                    .font(.title2)
                    .bold()

                Button("Connect Robinhood") {
                    dismiss()
                }
                
                Button("Connect Fidelity") {
                    dismiss()
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Add Brokerage")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }
}
