import UIKit
import Alamofire

let imageCache = NSCache<AnyObject, UIImage>()

extension UIImageView {
    func downloadImage(url: String, completion: ((UIImage?) -> Void)? = nil ) {
        if url.isEmpty { return }
        if let image = imageCache.object(forKey: url as AnyObject) {
            DispatchQueue.main.async {[weak self] in
                self?.image = image
                completion?(image)
            }
            return
        }
        
        Alamofire.request(url).responseData { (response) in
            guard let data = response.value else { return }
            if let image = UIImage(data: data) {
                imageCache.setObject(image, forKey: url as AnyObject)
                DispatchQueue.main.async {[weak self] in
                    self?.image = image
                    completion?(image)
                }
            }
        }
    }
}
