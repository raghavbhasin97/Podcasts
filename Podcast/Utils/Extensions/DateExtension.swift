import Foundation

extension Date {
    func formatDate() -> String {
        let format = DateFormatter()
        format.dateFormat = "EEEE, MMM d, YYYY"
        let date = format.string(from: self)
        return date
    }
}
