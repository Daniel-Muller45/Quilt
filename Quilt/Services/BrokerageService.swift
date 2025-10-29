//
//  BrokerageService.swift
//  Quilt
//
//  Created by Daniel Muller on 10/28/25.
//

import Foundation

final class BrokerageService {
    
    func registerUser(uid: String, token: String, completion: @escaping (Result<SnapTradeUser, Error>) -> Void) {
            let body = ["uid": uid]
            
            NetworkManager.shared.makeRequest(
                to: "/brokerages/register",
                method: "POST",
                body: body,
                authToken: token
            ) { (result: Result<RegisterUserResponse, Error>) in
                switch result {
                case .success(let response):
                    completion(.success(response.data))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    
    func getLoginRedirect(userId: String, userSecret: String, brokerage: String, token: String, completion: @escaping (Result<String, Error>) -> Void) {
            let body = [
                "user_id": userId,
                "user_secret": userSecret,
                "brokerage": brokerage
            ]
            
            NetworkManager.shared.makeRequest(
                to: "/brokerages/login-redirect",
                method: "POST",
                body: body,
                authToken: token
            ) { (result: Result<LoginRedirectResponse, Error>) in
                switch result {
                case .success(let response):
                    completion(.success(response.redirect_url))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    
    func getAccounts(userId: String, userSecret: String, authToken: String, completion: @escaping (Result<[SnapTradeAccount], Error>) -> Void) {
        let body = ["user_id": userId, "user_secret": userSecret]
        
        NetworkManager.shared.makeRequest(
            to: "/brokerages/accounts",
            method: "POST",
            body: body,
            authToken: authToken
        ) { (result: Result<AccountsResponse, Error>) in
            switch result {
            case .success(let response):
                completion(.success(response.accounts))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func getHoldings(accountId: String, userId: String, userSecret: String, token: String, completion: @escaping (Result<[Holding], Error>) -> Void) {
            let body = [
                "account_id": accountId,
                "user_id": userId,
                "user_secret": userSecret
            ]
            
            NetworkManager.shared.makeRequest(
                to: "/brokerages/holdings",
                method: "POST",
                body: body,
                authToken: token
            ) { (result: Result<HoldingsResponse, Error>) in
                switch result {
                case .success(let response):
                    completion(.success(response.holdings))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
}
