import Foundation

extension Date {
    var portfolioStamp: String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "MM/dd h:mm a"   // -> 11/10 9:50 AM
        return f.string(from: self)
    }
}
