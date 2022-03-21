import Foundation
import BrightcovePlayerSDK
extension PlayerView: BCOVPlaybackSessionConsumer {
  public func playbackSession(_ session: BCOVPlaybackSession!, didReceive lifecycleEvent: BCOVPlaybackSessionLifecycleEvent!) {
    self.session = session
    self.currentPlayer = session.player
    self.lifecycleEvent = lifecycleEvent
  }
  public func playbackSession(_ session: BCOVPlaybackSession!, didProgressTo progress: TimeInterval) {
    guard let totalduration = session.player.currentItem?.duration.seconds else {
      return
    }
    shouldHideVideoOverlay(totalduration, progress)
    showNextVideoOverlay(totalduration, progress)
  }
  fileprivate func showNextVideoOverlay(_ totalduration: Double, _ progress: TimeInterval) {
    let threshold = totalduration - TimerConstants.thumbnailVideoEndOffset
    if progress >= threshold,
       !self.overlayDecorator.showOverlay {
      displayNextVideo()
    }
  }
  fileprivate func shouldHideVideoOverlay(_ totalduration: Double, _ progress: TimeInterval) {
    let threshold = totalduration - TimerConstants.thumbnailVideoEndOffset
    if progress < threshold {
      self.overlayDecorator.showOverlay = false
    }
  }
  // MARK: - Lifecycle events processing
  func processLifeCycleEvents() {
    switch lifecycleEvent?.eventType {
    case kBCOVPlaybackSessionLifecycleEventPlay:
      controlsFadingViewVisible = true
      self.customControlsView?.isPaused = false
    case kBCOVPlaybackSessionLifecycleEventPause:
      self.screenTapDecorator.reestablishTimer()
      self.customControlsView?.isPaused = true
    case kBCOVPlaybackSessionLifecycleEventReady:
      self.customControlsView?.isPaused = false
      closedCaptionsDecorator.session = session
    case kBCOVPlaybackSessionLifecycleEventEnd:
      print("Playback end")
      /*displayNextVideo()*/
    case kBCOVPlaybackSessionLifecycleEventPlayRequest:
      self.customControlsView?.isPaused = false
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
  }
}
