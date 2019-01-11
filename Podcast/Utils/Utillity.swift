import UIKit

func getString(text: String, font: CGFloat, weight: UIFont.Weight, color: UIColor) -> NSAttributedString {
    return NSAttributedString(string: text, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: font, weight: weight), NSAttributedString.Key.foregroundColor: color])
    
}

func generateAudioURL(from: String) -> URL? {
    if from.contains("file://") {
        if let url = URL(string: from) {
            if let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                let fileName = url.lastPathComponent
                return path.appendingPathComponent(fileName)
            }
        }
    }
    return URL(string: from)
}
