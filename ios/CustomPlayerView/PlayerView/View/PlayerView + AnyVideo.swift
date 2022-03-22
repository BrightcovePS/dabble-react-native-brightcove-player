import Foundation
extension PlayerView {
  func fetchAnyBCVideo(for json: [AnyHashable : Any]?) {
    guard let json = json else { return }
    let video = playlistRepo.getAnyBCOVVideo(from: json)
    overlayDecorator.nextAnyVideo = video
    /*To handle async response and not show preview when out of window*/
    if !overlayDecorator.showOverlay {
      overlayDecorator.showOverlay = overlayDecorator.isPreviewWindowActive ?  true : false
    }
  }
}
