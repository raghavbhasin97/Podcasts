import Foundation

extension String {
    func sanatizeHTML() -> String{
        return self.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
    }
}

extension Float64 {
    func formatDuration() -> String {
        let (h,m,s) = (self/3600, (self.truncatingRemainder(dividingBy: 3600))/60, (self.truncatingRemainder(dividingBy: 60)))
        let hrs = Int(h)
        let min = Int(m)
        let sec = Int(s)
        if hrs == 0 {
            return String(format: "%02d:%02d", min,sec)
        }
        return String(format: "%02d:%02d:%02d", hrs,min,sec)
    }
}

