import Foundation
import BrightcovePlayerSDK
class PlayerRepository {
  var accountId: String?
  var policyKey: String?
  var playlistReferenceId: String? {
    didSet {
      CurrentPlayerItem.shared.playlistRefId = playlistReferenceId ?? StringConstants.kEmptyString
    }
  }
  var playlistId: String? {
    didSet {
      CurrentPlayerItem.shared.playlistId = playlistId ?? StringConstants.kEmptyString
    }
  }
  var referenceId: String? {
    didSet {
      CurrentPlayerItem.shared.referenceId = referenceId ?? StringConstants.kEmptyString
    }
  }
  var videoId: String? {
    didSet {
      CurrentPlayerItem.shared.videoId = videoId ?? StringConstants.kEmptyString
    }
  }
  var playlistVideos: [BCOVVideo]? {
    didSet {
      self.cacheAllPlaylistVideoIds()
    }
  }
  init(_ accountId: String? = nil,
       policyKey: String? = nil,
       playlistReferenceId: String? = nil,
       playlistId: String? = nil,
       referenceId: String? = nil,
       videoId: String? = nil) {
    self.accountId = accountId
    self.policyKey = policyKey
    self.videoId = videoId
  }
  func getPlaylistFromRefId() {
    guard let playlistReferenceId = self.playlistReferenceId  else { return }
    let playbackService = getPlaybackService()
    playbackService?.findPlaylist(withReferenceID: playlistReferenceId, parameters: formQueryParam(), completion: { playlist, jsonResponse, error in
      if let playlist = playlist,
         let videos = playlist.videos as? [BCOVVideo] {
        self.playlistVideos = videos
      }
    })
  }
  func getPlaylistFromPlaylistId() {
    guard let playlistId = self.playlistId  else { return }
    let playbackService = getPlaybackService()
    playbackService?.findPlaylist(withPlaylistID: playlistId, parameters: formQueryParam(), completion: { playlist, jsonResponse, error in
      if let playlist = playlist,
         let videos = playlist.videos as? [BCOVVideo] {
        self.playlistVideos = videos
      }
    })
  }
  private func formQueryParam() -> [String: Any] {
    return [:]
  }
  private func getPlaybackService() -> BCOVPlaybackService? {
    guard let accountId = self.accountId,
          let policyKey = self.policyKey else { return nil }
    let playbackServiceRequestFactory = BCOVPlaybackServiceRequestFactory(accountId: accountId, policyKey: policyKey)
    return BCOVPlaybackService(requestFactory: playbackServiceRequestFactory)
  }
  func getNextVideo() -> BCOVVideo? {
    guard let videoId = self.videoId,
          let playlist = self.playlistVideos else { return nil }
    return PlaylistHelper.getNextVideo(with: videoId, in: playlist)
  }
  func getPrevVideo() -> BCOVVideo? {
    guard let videoId = self.videoId,
          let playlist = self.playlistVideos else { return nil }
    return PlaylistHelper.getPreviousVideo(with: videoId, in: playlist)
  }
  func getVideo(with videoId: String) -> BCOVVideo? {
    guard let playlist = self.playlistVideos else { return nil }
    return PlaylistHelper.getVideo(with: videoId, in: playlist)
  }
  func getVideoFromCloud(with videoId: String, completionHandler: @escaping (BCOVVideo?, Error?) -> Void){
    let playbackService = getPlaybackService()
    playbackService?.findVideo(withVideoID: videoId, parameters:  formQueryParam(), completion: { bcVideo, response, error in
      completionHandler(bcVideo, error)
    })
  }
  func getAnyBCOVVideo(from json: [AnyHashable : Any]) -> BCOVVideo? {
    return BCOVPlaybackService.video(fromJSONDictionary: json)
  }
  private func getPlaylist(from json: [AnyHashable : Any]) -> BCOVPlaylist {
    return BCOVPlaybackService.playlist(fromJSONDictionary: json)
  }
  func isNextVideoAvailable() -> Bool {
    guard let videoId = self.videoId,
          let playlist = self.playlistVideos else { return false }
    return PlaylistHelper.isNextVideoAvailable(with: videoId, in: playlist)
  }
  func isPrevVideoAvailable() -> Bool {
    guard let videoId = self.videoId,
          let playlist = self.playlistVideos else { return false }
    return PlaylistHelper.isPrevVideoAvailable(with: videoId, in: playlist)
  }
  private func cacheAllPlaylistVideoIds() {
    CurrentPlayerItem.shared.playlistVideoIds = []
    self.playlistVideos?.forEach({ eachVideo in
      if let videoId = eachVideo.properties[kBCOVVideoPropertyKeyId] as? String {
        CurrentPlayerItem.shared.playlistVideoIds.append(videoId)
      }
    })
  }
}
