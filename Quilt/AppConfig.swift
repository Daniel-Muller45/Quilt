import Foundation

struct AppConfig {
    private static let config: [String: Any] = {
        guard let url = Bundle.main.url(forResource: "Config", withExtension: "plist"),
              let data = try? Data(contentsOf: url),
              let plist = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any] else {
            fatalError("Could not load Config.plist")
        }
        return plist
    }()

    static var supabaseURL: URL {
        guard let urlString = config["SUPABASE_URL"] as? String,
              let url = URL(string: urlString) else {
            fatalError("SUPABASE_URL missing in Config.plist")
        }
        return url
    }

    static var supabaseAnonKey: String {
        guard let key = config["SUPABASE_ANON_KEY"] as? String else {
            fatalError("SUPABASE_ANON_KEY missing in Config.plist")
        }
        return key
    }
}
