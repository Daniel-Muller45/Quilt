//
//  SnapTradeUser.swift
//  Quilt
//
//  Created by Daniel Muller on 10/28/25.
//

struct RegisterUserResponse: Codable {
    let success: Bool
    let data: SnapTradeUser
}
struct LoginRedirectResponse: Codable {
    let success: Bool
    let redirect_url: String
}

struct AccountsResponse: Codable {
    let success: Bool
    let accounts: [SnapTradeAccount]
}

struct HoldingsResponse: Codable {
    let success: Bool
    let holdings: [Holding]
}
