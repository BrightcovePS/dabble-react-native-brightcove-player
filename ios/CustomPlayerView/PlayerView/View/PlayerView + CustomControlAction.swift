import Foundation
extension PlayerView: CustomControlsObserverable {
  func addPlayPauseObserver() {
    customControlsView?.playPauseAction = {[weak self] _ in
      guard let self = self else {
        return
      }
      self.controlsView.playbackButton.sendActions(for: .touchUpInside)
    }
  }
}
