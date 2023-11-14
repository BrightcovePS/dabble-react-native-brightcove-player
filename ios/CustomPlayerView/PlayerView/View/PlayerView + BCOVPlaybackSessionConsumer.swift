import Foundation
import BrightcovePlayerSDK
extension PlayerView: BCOVPlaybackSessionConsumer {
  public func playbackSession(_ session: BCOVPlaybackSession!, didReceive lifecycleEvent: BCOVPlaybackSessionLifecycleEvent!) {
//    session.selectedLegibleMediaOption = .none //Disabling captions in video
      if (lifecycleEvent.eventType == kBCOVPlaybackSessionLifecycleEventReady) {
          self.session = session
          self.currentPlayer = session.player
          closedCaptionsDecorator.session = session
      }
    self.lifecycleEvent = lifecycleEvent
  }
  public func playbackSession(_ session: BCOVPlaybackSession!, didProgressTo progress: TimeInterval) {
    guard let totalduration = session.player.currentItem?.duration.seconds else {
      return
    }
    shouldResetConnectionActive(totalduration, progress)
    processAnyVideo(totalduration, progress)
    shouldHideVideoOverlay(totalduration, progress)
    showNextVideoOverlay(totalduration, progress)
  }
  fileprivate func showNextVideoOverlay(_ totalduration: Double, _ progress: TimeInterval) {
    let threshold = totalduration - TimerConstants.thumbnailVideoEndOffset
    if progress > threshold,
       !self.overlayDecorator.isPreviewWindowActive {
      overlayDecorator.isPreviewWindowActive = true
      displayNextVideo()
    }
  }
  fileprivate func shouldHideVideoOverlay(_ totalduration: Double, _ progress: TimeInterval) {
    let threshold = totalduration - TimerConstants.thumbnailVideoEndOffset
    //progress == 0 is to make isPreviewWindowActive = false even when the video is less than 5 seconds and when threshold == Nan and Progress is 0
    if (progress == 0 || progress < threshold) {
      self.overlayDecorator.showOverlay = false
      overlayDecorator.isPreviewWindowActive = false
    }
  }
  fileprivate func handleScrub(_ totalduration: Double, _ progress: TimeInterval) {
    let threshold = totalduration - TimerConstants.thumbnailVideoEndOffset
    if progress >= threshold {
      overlayDecorator.isPreviewWindowActive = true
      displayNextVideo()
    }
  }
  fileprivate func processAnyVideo(_ totalduration: Double, _ progress: TimeInterval) {
    let threshold = totalduration - TimerConstants.apiCallVideoEndOffset
    if progress >= threshold,
       !playlistRepo.isNextVideoAvailable(), !overlayDecorator.isConnectionWindowActive {
      overlayDecorator.isConnectionWindowActive = true
      connectToRemote()
    }
  }
  fileprivate func shouldResetConnectionActive(_ totalduration: Double, _ progress: TimeInterval) {
    let threshold = totalduration - TimerConstants.apiCallVideoEndOffset
    if progress < threshold {
      self.overlayDecorator.isConnectionWindowActive = false
    }
  }
  // MARK: - Lifecycle events processing
  func processLifeCycleEvents() {
    switch lifecycleEvent?.eventType {
    case kBCOVPlaybackSessionLifecycleEventPlay:
      controlsFadingViewVisible = true
      self.reestablishTimer()
      self.customControlsView?.isPaused = false
    case kBCOVPlaybackSessionLifecycleEventPause:
      controlsFadingViewVisible = true
      self.reestablishTimer()
      self.customControlsView?.isPaused = true
    case kBCOVPlaybackSessionLifecycleEventReady:
      controlsFadingViewVisible = true
      if session?.player.timeControlStatus == .playing || session?.player.timeControlStatus == .waitingToPlayAtSpecifiedRate {
        self.customControlsView?.isPaused = false
      } else {
        self.customControlsView?.isPaused = true
        cancelTimer()
      }
//      closedCaptionsDecorator.session = session
    case kBCOVPlaybackSessionLifecycleEventEnd:
      print("Playback end")
        /*displayNextVideo()*/
        if self.playbackType == .nonEpisodic {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
              let seekTime: CMTime = CMTimeMake(value: Int64((self.totalDuration)*1000), timescale: 10)
              self.playbackController?.seek(to: seekTime, toleranceBefore: .zero, toleranceAfter: .zero, completionHandler: { (finished: Bool) in
                self.slider?.setValue(1, animated: false)
                self.customControlsView?.playerState = .finished
                self.controlsFadingViewVisible = true
                self.customControlsView?.isPaused = true
                self.playbackController?.pause()
              })
            }
        }
       
    case kBCOVPlaybackSessionLifecycleEventPlayRequest:
      self.customControlsView?.isPaused = false
    case kBCOVPlaybackSessionLifecycleEventPlaybackLikelyToKeepUp:
      controlsFadingViewVisible = true
      self.reestablishTimer()
    default:
      break
    }
  }
  func sliderChanged() {
    guard let totalduration = session?.player.currentItem?.duration.seconds,
          let sliderVal = slider?.value
          else {
      return
    }
    let progress = totalduration * Double(sliderVal)
    self.shouldHideVideoOverlay(totalduration, progress)
    self.shouldResetConnectionActive(totalduration, progress)
    handleScrub(totalduration, progress)
  }
}
