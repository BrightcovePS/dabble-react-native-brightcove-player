import Foundation
class PictureInPictureDecorator: PlayerDecoratorProtocol, PictureInPictureable {
  weak var playerView: PlayerView?
  required init(_ playerView: PlayerView) {
    self.playerView = playerView
  }
  func checkIfPictureInPictureEnabled() {
    #if targetEnvironment(simulator)
    self.playerView?.customControlsView?.pictureInPictureEnabled = true
    #else
    self.playerView?.customControlsView?.pictureInPictureEnabled = false
    /* Donot delete*/
    //self.playerView?.customControlsView?.pictureInPictureEnabled =  self.playerView?.playbackController.pictureInPictureController.isPictureInPicturePossible ?? false
    #endif
  }
  func addPictureInPictureObserver() {
    self.playerView?.customControlsView?.pictureInPictureTapped = {
      [weak self] _ in
      guard let self = self else { return }
      self.startPictureInPicture()
      // Hack to manually tap the B'cove pictureInPictureButton to get the desired effect.
      //self.controlsView.pictureInPictureButton.sendActions(for: .touchUpInside)
    }
  }
  func startPictureInPicture() {
    self.playerView?.playbackController.pictureInPictureController?.startPictureInPicture()
  }
  func hideControls() {
    self.playerView?.controlsView.isHidden = true
    self.playerView?.controlsFadingView.isHidden = true
  }
  func showControls() {
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
      self.playerView?.controlsView.isHidden = false
      self.playerView?.controlsFadingView.isHidden = false
    }
  }
}
