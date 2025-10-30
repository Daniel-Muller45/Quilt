import Foundation

struct LocalStorage {
    static let brokerageKey = "temp_brokerage_data"

    static func saveBrokerageData(_ data: TempBrokerageData) {
        do {
            let encoded = try JSONEncoder().encode(data)
            UserDefaults.standard.set(encoded, forKey: brokerageKey)
        } catch {
            print("❌ Failed to encode brokerage data:", error)
        }
    }

    static func loadBrokerageData() -> TempBrokerageData? {
        guard let savedData = UserDefaults.standard.data(forKey: brokerageKey) else {
            return nil
        }
        do {
            return try JSONDecoder().decode(TempBrokerageData.self, from: savedData)
        } catch {
            print("❌ Failed to decode brokerage data:", error)
            return nil
        }
    }

    static func clearBrokerageData() {
        UserDefaults.standard.removeObject(forKey: brokerageKey)
    }
}
