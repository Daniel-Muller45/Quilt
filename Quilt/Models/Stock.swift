import Foundation

struct Stock: Identifiable, Codable {
    var id: String
    var symbol: String
    var name: String
    var price: Double
    var change: Double
    var cha: Double
}
