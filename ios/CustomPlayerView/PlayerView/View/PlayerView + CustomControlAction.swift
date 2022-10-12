import Foundation
extension PlayerView: CustomControlsObserverable {
  func addInfoObserver() {
    customControlsView?.infoTapped = {[weak self] _ in
      guard let self = self,
      let currentPlayer = self.currentPlayer else {
        return
      }
      print("Info tapped")
      self.restablishTapTimer()
    }
  }
  
  func addMuteObserver() {
    customControlsView?.muteTapped = {[weak self] _ in
      guard let self = self,
      let currentPlayer = self.currentPlayer else {
        return
      }
      currentPlayer.isMuted = !self.currentPlayer!.isMuted
      self.customControlsView?.isMuted = currentPlayer.isMuted
      self.restablishTapTimer()
    }
  }
  
  func addClosedObserver() {
    customControlsView?.closeTapped = {[weak self] _ in
      guard let self = self else {
        return
      }
      print("Close tapped")
      self.restablishTapTimer()
    }
  }
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
    reestablishTimer()
  }
}
