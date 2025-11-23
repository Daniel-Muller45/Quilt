//
//  TransactionViewModel.swift
//  Quilt
//
//  Created by Daniel Muller on 11/22/25.
//

import Foundation
import Supabase

@MainActor
final class TransactionViewModel: ObservableObject {
    @Published var transactions: [StockTransaction] = []
    @Published var isLoading = false
    @Published var error: String?

    func load(ticker: String) async {
        isLoading = true
        error = nil

        do {
            let client = SupabaseService.shared.client

            let rows: [StockTransaction] = try await client
                .database
                .from("transactions")
                .select("trade_date,ticker,type,quantity,fee,price,cash_delta")
                .eq("ticker", value: ticker)
                .order("trade_date", ascending: false)
                .execute()
                .value

            self.transactions = rows
            print("self.transactions \(self.transactions) for ticker \(ticker)")
        } catch {
            print("Failed to load stock transactions for ticker \(ticker):", error)
            self.error = error.localizedDescription
        }

        isLoading = false
    }
}
