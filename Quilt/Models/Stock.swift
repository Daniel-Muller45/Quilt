//
//  Stock.swift
//  Quilt
//
//  Created by Daniel Muller on 10/23/25.
//

import Foundation

struct Stock: Identifiable, Codable {
    var id: String
    var symbol: String
    var name: String
    var price: Double
    var change: Double
    var cha: Double
}
