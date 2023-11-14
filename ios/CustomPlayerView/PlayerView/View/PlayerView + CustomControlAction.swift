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
    func addReplayObserver() {
      customControlsView?.replayTapped = {[weak self] _ in
        guard let self = self,
        let currentPlayer = self.currentPlayer else {
          return
        }
        print("Replay tapped")
        self.playbackController?.play()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
          let seekTime: CMTime = CMTimeMake(value: Int64(0), timescale: 1000)
          self.playbackController?.seek(to: seekTime, completionHandler: { (finished: Bool) in
            self.customControlsView?.playerState = .unknown
            self.playbackController?.play()
          })
        }
        self.restablishTapTimer()
      }
    }
  func addClosedObserver() {
    customControlsView?.closeTapped = {[weak self] _ in
      guard let self = self else {
        return
      }
        if let superview = self.superview as? BrightcovePlayer {
            superview.closeTapped()
            
        }
      self.performScreenTransition(with: .normal)
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
