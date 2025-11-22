import SwiftUI

struct CustomHeader: View {
    var title: String = "Portfolio"
    // The token is required to initialize the ConnectBrokerageView.
    // Pass this from your parent view (e.g., read from AppStorage or Environment).
    var token: String
    
    // Internal state for managing sheets
    @State private var showBrokerageSheet = false
    @State private var showProfileSheet = false
    
    var body: some View {
        HStack {
            // Left Button (Profile)
            Button {
                showProfileSheet.toggle()
            } label: {
                Image(systemName: "person.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.primary)
            }
            
            Spacer()
            
            // Center Title
            Text(title)
                .font(.headline)
                .fontWeight(.bold)
            
            Spacer()
            
            // Right Button (Connect Brokerage)
            Button {
                showBrokerageSheet.toggle()
            } label: {
                Image(systemName: "plus")
                    .imageScale(.large)
                    .foregroundColor(.primary)
            }
        }
        .padding([.leading, .trailing, .bottom])
        .background(Color(UIColor.systemBackground))
        // 1. Handle the Brokerage Sheet internally
        .sheet(isPresented: $showBrokerageSheet) {
            ConnectBrokerageView(token: token)
        }
        // 2. Handle the Profile Sheet internally (Placeholder)
        .sheet(isPresented: $showProfileSheet) {
            ProfileView()
        }

    }
}

// MARK: - Example Usage
struct ContentView: View {
    // You only need to provide the data (token/title), not the logic.
    let userToken = "sample_token_123"
    
    var body: some View {
        VStack {
            CustomHeader(title: "Portfolio", token: userToken)
            
            Spacer()
            
            Text("Dashboard Content")
        }
    }
}

struct CustomHeader_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
