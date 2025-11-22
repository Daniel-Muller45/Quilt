import SwiftUI
import SwiftData

struct ProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var auth: AuthViewModel
    
    // 1. Add the Query to fetch all accounts, sorted by name
    @Query(sort: \Account.name) private var accounts: [Account]

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Account")) {
                    if let email = auth.session?.user.email {
                        HStack {
                            Text("Email")
                            Spacer()
                            Text(email)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                // 2. Iterate over the fetched accounts
                Section(header: Text("Synced Brokerages")) {
                    if accounts.isEmpty {
                        Text("No brokerages connected")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(accounts) { account in
                            HStack {
                                Image(systemName: "arrow.trianglehead.2.clockwise.rotate.90")
                                VStack(alignment: .leading) {
                                    Text(account.name)
                                        .font(.body)
                                        .foregroundColor(.primary)
                                    
                                    // Optional: Show currency or last synced info
                                    Text(account.currency)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                
                                Spacer()
                                
                                // Display current value of the account
                                Text(account.currentValue, format: .currency(code: account.currency))
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }

                Section {
                    Button(role: .destructive) {
                        Task {
                            await auth.signOut()
                            dismiss()
                        }
                    } label: {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                            Text("Sign Out")
                        }
                    }
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // Add a generic close button for the sheet
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
