//
//  TempBrokerageData.swift
//  Quilt
//
//  Created by Daniel Muller on 10/29/25.
//

struct TempBrokerageData: Codable {
    let userId: String
    let userSecret: String
    var accounts: [SnapTradeAccount]?
    var holdings: [Holding]?
}
