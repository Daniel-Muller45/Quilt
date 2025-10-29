//
//  BrokerageViewModel.swift
//  Quilt
//
//  Created by Daniel Muller on 10/28/25.
//
import Foundation
import SwiftUI


@MainActor
class BrokerageViewModel: ObservableObject {
    @Published var accounts: [SnapTradeAccount] = []
    @Published var holdings: [Holding] = []
    @Published var redirectURL: String?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let brokerageService = BrokerageService()
    
    func registerUser(uid: String, token: String) {
        isLoading = true
        brokerageService.registerUser(uid: uid, token: token) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let user):
                    print("✅ Registered:", user)
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func getLoginRedirect(userId: String, userSecret: String, brokerage: String, token: String) {
        isLoading = true
        brokerageService.getLoginRedirect(userId: userId, userSecret: userSecret, brokerage: brokerage, token: token) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let url):
                    self.redirectURL = url
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }

    func loadAccounts(userId: String, userSecret: String, token: String) {
        isLoading = true
        brokerageService.getAccounts(userId: userId, userSecret: userSecret, authToken: token) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let accounts):
                    self.accounts = accounts
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func loadHoldings(accountId: String, userId: String, userSecret: String, token: String) {
        isLoading = true
        brokerageService.getHoldings(accountId: accountId, userId: userId, userSecret: userSecret, token: token) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let holdings):
                    self.holdings = holdings
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
}
