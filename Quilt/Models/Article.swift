import Foundation

struct NewsArticle: Identifiable {
    let id = UUID()
    let title: String
    let source: String
    let summary: String
}
