import Foundation
extension PlayerView: CustomControlsObserverable {
  func addForwardSeekObserver() {
    customControlsView?.forwardAction = {[weak self] _ in
      guard let self = self else {
        return
      }
      self.restablishTapTimer()
    }
  }
  func addBackwardSeekObserver() {
    customControlsView?.rewindAction = {[weak self] _ in
      guard let self = self else {
        return
      }
      self.restablishTapTimer()
    }
  }
  func addPlayPauseObserver() {
    customControlsView?.playPauseAction = {[weak self] _ in
      guard let self = self else {
        return
      }
      self.restablishTapTimer()
      self.controlsView.playbackButton.sendActions(for: .touchUpInside)
    }
  }
  func restablishTapTimer() {
    controlsFadingViewVisible = true
    screenTapDecorator.reestablishTimer()
  }
}
