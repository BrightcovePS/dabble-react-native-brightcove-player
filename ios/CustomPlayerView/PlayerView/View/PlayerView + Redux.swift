import Foundation
import BrightcovePlayerSDK
struct NextVideoBridgeKeys {
  static let kReferenceId = "referenceId"
  static let kVideoId = "videoId"
}
extension PlayerView: StoreSubscriber {
  func newState(state: State) {
    switch (state as? OverlayReduxState)?.actionType {
    case .overlaySelection:
      handleOverlaySelection(state)
    case .closeOverlay:
      handleOverlayClose()
    case .none:
      break
    }
  }
  fileprivate func handleOverlaySelection(_ state: State) {
    let referenceId = (state as? OverlayReduxState)?.referenceId ?? StringConstants.kEmptyString
    let videoId = (state as? OverlayReduxState)?.videoId ?? StringConstants.kEmptyString
    if let video = playlistRepo.getVideo(with: videoId) {
      self.referenceId = referenceId
      self.videoId = videoId
      self.playbackController.setVideos([video] as NSFastEnumeration)
    } else if let nextVideo = overlayDecorator.nextAnyVideo {
      /*Fallback mechanism incase the next video mismatched in race conition due to rapid swipe of scrollbar*/
      let nextVideoId = nextVideo.properties[kBCOVVideoPropertyKeyId] as? String
      if nextVideoId == videoId {
      self.referenceId = referenceId
      self.videoId = videoId
      self.playbackController.setVideos([nextVideo] as NSFastEnumeration)
      }
    } else {
      self.playlistRepo.getVideoFromCloud(with: videoId) { video, error in
        guard let video = video else { return }
        self.playbackController.setVideos([video] as NSFastEnumeration)
      }
    }
    let dictVideoDetails = [NextVideoBridgeKeys.kReferenceId: referenceId,
                            NextVideoBridgeKeys.kVideoId: videoId]
    self.player.nextVideoPlayer(dictVideoDetails)
    self.overlayDecorator.showOverlay = false
  }
  fileprivate func handleOverlayClose() {
    self.overlayDecorator.hideOverylay()
    self.overlayDecorator.performHideOverlayAuxillaryActions()
  }
}
