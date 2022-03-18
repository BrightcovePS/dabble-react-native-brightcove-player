import Foundation
extension OverlayDecorator: AnyVideoProtocol {
  func fetchAnyBCVideo(for json: [AnyHashable : Any]?) {
    guard let parentView = parentView as? PlayerView,
          let json = json else {
      return
    }
    parentView.fetchAnyBCVideo(for: json)
  }
}
