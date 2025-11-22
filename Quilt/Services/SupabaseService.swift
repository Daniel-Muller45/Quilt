//
//  SupabaseService.swift
//  Quilt
//
//  Created by Daniel Muller on 10/23/25.
//

import Foundation
import Supabase

final class SupabaseService {
    static let shared = SupabaseService()

    let client: SupabaseClient

    private init() {
        client = SupabaseClient(
            supabaseURL: AppConfig.supabaseURL,
            supabaseKey: AppConfig.supabaseAnonKey
        )
    }

    func signUp(email: String, password: String) async throws -> AuthResponse {
        try await client.auth.signUp(email: email, password: password)
    }

    func signIn(email: String, password: String) async throws -> Session {
        try await client.auth.signIn(email: email, password: password)
    }

    func getSession() async throws -> Session? {
        do {
            return try await client.auth.session
        } catch {
            print("Failed to fetch session:", error)
            return nil
        }
    }

    func refreshSession() async throws -> Session? {
        do {
            return try await client.auth.refreshSession()
        } catch {
            print("Failed to refresh session:", error)
            return nil
        }
    }

    func signOut() async throws {
        try await client.auth.signOut()
    }
    
    func fetchOneYearEOD(ticker: String) async throws -> [EODRow] {
        let start = Calendar.current.date(byAdding: .day, value: -365, to: Date())!
        let f = DateFormatter()
        f.calendar = Calendar(identifier: .iso8601)
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "yyyy-MM-dd"
        let startStr = f.string(from: start)

        let rows: [EODRow] = try await client
            .database
            .from("daily_stock_data")
            .select("date,close")
            .eq("ticker", value: ticker)
            .gte("date", value: startStr)
            .order("date", ascending: true)
            .execute()
            .value

        return rows
    }


}
