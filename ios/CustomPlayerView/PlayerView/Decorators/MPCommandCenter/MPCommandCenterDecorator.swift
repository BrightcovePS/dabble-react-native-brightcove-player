import Foundation
import BrightcovePlayerSDK
class MPRemoteCommandCenterDecorator: PlayerDecoratorProtocol, MPCommandCenterPlayable, SessionReferenceable {
  weak var playerView: PlayerView?
  weak var session: BCOVPlaybackSession?
  var playlistRepo: PlayerRepository {
    return playerView?.playlistRepo ?? PlayerRepository()
  }
  var referenceId: String? {
    return playerView?.referenceId
  }
  let commandCenter =  MPRemoteCommandCenter.shared()
  required init(_ playerView: PlayerView) {
    self.playerView = playerView
  }
  func setupNowPlayingInfoCenter() {
    commandCenter.playCommand.isEnabled = true
    commandCenter.playCommand.addTarget {event in
      self.session?.player.play()
      return .success
    }
    commandCenter.pauseCommand.isEnabled = true
    commandCenter.pauseCommand.addTarget {event in
      self.session?.player.pause()
      return .success
    }
    commandCenter.nextTrackCommand.isEnabled = false
    commandCenter.nextTrackCommand.addTarget {event in
      self.playerView?.playNextVideo()
      return .success
    }
    commandCenter.previousTrackCommand.isEnabled = false
    commandCenter.previousTrackCommand.addTarget {event in
      self.playerView?.playPrevVideo()
      return .success
    }
  }
  func enableNextVideo() {
    commandCenter.nextTrackCommand.isEnabled = true
  }
  func disableNextVideo() {
    commandCenter.nextTrackCommand.isEnabled = false
  }
  func enablePrevVideo() {
    commandCenter.previousTrackCommand.isEnabled = true
  }
  func disablePrevVideo() {
    commandCenter.previousTrackCommand.isEnabled = false
  }
  func updateNextVideoMPCommandCenter() {
    if playlistRepo.isNextVideoAvailable() {
      enableNextVideo()
    } else {
      disableNextVideo()
    }
  }
  func updatePrevVideoMPCommandCenter() {
    if playlistRepo.isPrevVideoAvailable() {
      enablePrevVideo()
    } else {
      disablePrevVideo()
    }
  }
  func updateMPCommandCenter() {
    updateNextVideoMPCommandCenter()
    updatePrevVideoMPCommandCenter()
    updateMPCommandCentreUI()
  }
  func updateMPCommandCentreUI() {
    guard let referenceId = self.referenceId else { return }
    let bcovVideo = self.playlistRepo.getVideo(with: referenceId)
    let title = bcovVideo?.properties[kBCOVPlaylistPropertiesKeyName]
    var nowPlayingInfo = [String : Any]()
    nowPlayingInfo[MPMediaItemPropertyTitle] = title
    MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
  }
}
