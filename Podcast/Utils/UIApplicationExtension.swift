import UIKit

extension UIApplication {
    func addSubview(view: UIView) {
        let main = keyWindow?.rootViewController
        main?.view.addSubview(view)
    }
}
