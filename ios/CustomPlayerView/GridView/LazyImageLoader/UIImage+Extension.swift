import UIKit
extension UIImageView {
  static var urlStore = [String:String]()
  public func setImage(url: String, placeholderImage: UIImage? = nil, completion: (() -> Void)?) {
    /*Unique to each instance*/
    let tmpAddress = String(format: "%p", unsafeBitCast(self, to: Int.self))
    UIImageView.urlStore[tmpAddress] = url
    
    if let image = placeholderImage {
      self.image = image
    } else{
      self.backgroundColor = .darkGray
    }
    AsyncImageLoader().downloadAndCacheImage(url: url, onSuccess: { (image, url) in
      DispatchQueue.main.async {
        if UIImageView.urlStore[tmpAddress] == url {
          self.contentMode = .scaleToFill;
          self.image = image
          self.backgroundColor = .darkGray
          completion?()
        }
      }
    }) { _ in
      completion?()
    }
  }
}
