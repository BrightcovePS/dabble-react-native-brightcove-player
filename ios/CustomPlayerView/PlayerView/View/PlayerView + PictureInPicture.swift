import Foundation
import AVKit
/*LSP, OCP in action*/
extension PlayerView: PictureInPictureable {
  func checkIfPictureInPictureEnabled() {
    pictureInPictureDecorator.checkIfPictureInPictureEnabled()
  }
  func addPictureInPictureObserver() {
    pictureInPictureDecorator.addPictureInPictureObserver()
  }
  func startPictureInPicture() {
    pictureInPictureDecorator.startPictureInPicture()
  }
  func hideControls() {
    pictureInPictureDecorator.hideControls()
  }
  func showControls() {
    pictureInPictureDecorator.showControls()
  }
}
