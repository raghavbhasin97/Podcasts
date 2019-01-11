import UIKit

extension UIColor {
    
    //MARK: function
    convenience init(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat) {
        self.init(red: r/255.0, green: g/255.0, blue: b/255.0, alpha: 1.0)
    }
    
    //MARK: Colors
    static let hotBlack = UIColor(64, 66, 69)
    static let overlay = UIColor(white: 0, alpha: 0.2)
    static let optionBlue = UIColor(8, 148, 251)
    static let optionGreen = UIColor(20, 201, 159)
    static let optionRed = UIColor(140, 7, 44)
    static let hotWhite = UIColor(80, 182, 186)
    static let hotGray = UIColor(152, 153, 155)
    static let overlayDark = UIColor(white: 0, alpha: 0.5)
}
