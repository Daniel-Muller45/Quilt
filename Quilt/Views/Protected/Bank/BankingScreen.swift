import SwiftUI
import ScalingHeaderScrollView

struct BankingScreen: View {
    @Environment(\.dismiss) private var dismiss

    @State private var collapseProgress: CGFloat = 0
    @State private var isLoadingMore = false

    private let service = BankingService()

    var body: some View {
        ZStack(alignment: .top) {
            ScalingHeaderScrollView(
                header: {
                    ZStack {
                        Color("PrimaryColor")
                            .ignoresSafeArea()

                        CardView(progress: collapseProgress)
                            .padding(.top, 130)
                            .padding(.bottom, 40)
                    }
                },
                content: {
                    VStack(spacing: 0) {
                        Color.white.frame(height: 15)
                        ForEach(service.transactions) { transaction in
                            TransactionView(transaction: transaction)
                        }
                        Color.white.frame(height: 15)
                    }
                    .background(Color.white)
                }
            )
            .height(min: 220, max: 372)
            .collapseProgress($collapseProgress)
            .allowsHeaderCollapse(true)
            .pullToLoadMore(isActive: isLoadingMore, contentOffset: 50) {
                await simulateLoadMore()
            }

            topButtons
            headerTitle
        }
        .ignoresSafeArea()
    }

    // MARK: - Header Title
    private var headerTitle: some View {
        VStack {
            Text("Visa Card")
                .font(.system(size: 17, weight: .medium))
                .padding(.top, 63)
                .opacity(1 - collapseProgress) // fades as header collapses
            Spacer()
        }
        .animation(.easeInOut(duration: 0.25), value: collapseProgress)
    }

    // MARK: - Top Buttons
    private var topButtons: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "arrow.backward")
                    .font(.system(size: 20, weight: .semibold))
                    .frame(width: 44, height: 44)
                    .background(.ultraThinMaterial, in: Circle())
            }
            .padding(.leading, 17)
            .padding(.top, 50)

            Spacer()

            Button {
                print("Info tapped")
            } label: {
                Image(systemName: "ellipsis")
                    .rotationEffect(.degrees(90))
                    .font(.system(size: 20, weight: .semibold))
                    .frame(width: 44, height: 44)
                    .background(.ultraThinMaterial, in: Circle())
            }
            .padding(.trailing, 17)
            .padding(.top, 50)
        }
    }

    // MARK: - Helpers
    private func simulateLoadMore() async {
        guard !isLoadingMore else { return }
        isLoadingMore = true
        try? await Task.sleep(for: .seconds(2))
        try? await Task.sleep(for: .seconds(2))
        isLoadingMore = false
    }
}

#Preview {
    BankingScreen()
}
