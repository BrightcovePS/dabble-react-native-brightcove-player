import UIKit
extension PlayerView: ClosedCaptionable {
  func addClosedCaptionsObserver() {
    closedCaptionsDecorator.addClosedCaptionsObserver()
  }
    func addAudioObserver() {
      closedCaptionsDecorator.addAudioObserver()
    }
  func presentClosedCaptions() {
    closedCaptionsDecorator.presentClosedCaptions()
  }
    func presentAudio() {
      closedCaptionsDecorator.presentAudio()
    }
}
extension UIView {
    var parentViewController: UIViewController? {
        // Starts from next (As we know self is not a UIViewController).
        var parentResponder: UIResponder? = self.next
        while parentResponder != nil {
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
            parentResponder = parentResponder?.next
        }
        return nil
    }
}
