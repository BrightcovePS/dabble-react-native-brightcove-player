import UIKit
extension UIColor {
    func image(_ size: CGSize = CGSize(width: OverlaySize.width, height: OverlaySize.height)) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { rendererContext in
            self.setFill()
            rendererContext.fill(CGRect(origin: .zero, size: size))
        }
    }
}
