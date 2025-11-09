//import SwiftUI
//
//struct NewsView: View {
//    @State private var articles: [NewsArticle] = []
//    @State private var isLoading = true
//    @State private var errorMessage: String?
//
//
//
//    var body: some View {
//        NavigationStack {
//            Group {
//                if isLoading {
//                    ProgressView("Loading news...")
//                        .progressViewStyle(CircularProgressViewStyle())
//                } else if let errorMessage = errorMessage {
//                    Text(errorMessage)
//                        .foregroundColor(.red)
//                        .multilineTextAlignment(.center)
//                } else {
//                    List(articles) { article in
//                        VStack(alignment: .leading, spacing: 8) {
//                            Text(article.title)
//                                .font(.headline)
//                            Text(article.source)
//                                .font(.subheadline)
//                                .foregroundColor(.gray)
//                            Text(article.summary)
//                                .font(.body)
//                                .lineLimit(3)
//                        }
//                        .padding(.vertical, 4)
//                    }
//                    .listStyle(.plain)
//                }
//
//
//
//            }
//            .navigationTitle("Market News")
//            .onAppear {
//                Task { await fetchNews() }
//            }
//        }
//    }
//
//    func fetchNews() async {
//        isLoading = true
//        defer { isLoading = false }
//
//        do {
//            try await Task.sleep(nanoseconds: 1_000_000_000)
//            self.articles = [
//                NewsArticle(title: "Apple Q4 Earnings Beat Expectations",
//                            source: "Reuters",
//                            summary: "Apple reported better-than-expected earnings driven by iPhone sales."),
//                NewsArticle(title: "Tesla Shares Jump After Record Deliveries",
//                            source: "Bloomberg",
//                            summary: "Tesla's Q3 deliveries exceeded analyst expectations, sending shares higher.")
//            ]
//        } catch {
//            errorMessage = "Failed to fetch news: \(error.localizedDescription)"
//        }
//    }
//}
