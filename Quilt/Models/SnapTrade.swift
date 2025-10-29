//
//  SnapTrade.swift
//  Quilt
//
//  Created by Daniel Muller on 10/28/25.
//

struct SnapTradeAccount: Codable {
    let id: String
    let broker: String
    let name: String?
}

struct SnapTradeUser: Codable {
    let userId: String
    let userSecret: String
}
