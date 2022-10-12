import Foundation
import BrightcovePlayerSDK
class PlaylistHelper {
  class func getNextVideo(with currentVideoId: String,in playlist: [BCOVVideo]) -> BCOVVideo? {
    let currentIdx = playlist.firstIndex { eachVideo in
      eachVideo.properties[kBCOVVideoPropertyKeyId] as? String == currentVideoId
    }
    guard let currentIndex = currentIdx,
          currentIndex + 1 <= playlist.count - 1 else {
      return nil
    }
    let nextIdx = currentIndex + 1
    return playlist[nextIdx]
  }
  class func getPreviousVideo(with currentVideoId: String,in playlist: [BCOVVideo]) -> BCOVVideo? {
    let currentIdx = playlist.firstIndex { eachVideo in
      eachVideo.properties[kBCOVVideoPropertyKeyId] as? String == currentVideoId
    }
    guard let currentIndex = currentIdx,
          currentIndex - 1 >= 0 else {
      return nil
    }
    let nextIdx = currentIndex - 1
    return playlist[nextIdx]
  }
  class func getVideo(with videoId: String,in playlist: [BCOVVideo]) -> BCOVVideo? {
    let video = playlist.filter { eachVideo in
      (eachVideo.properties[kBCOVVideoPropertyKeyId] as? String) == videoId
    }.first
    return video
  }
  class func isNextVideoAvailable(with currentVideoId: String,in playlist: [BCOVVideo]) -> Bool {
    let currentIdx = playlist.firstIndex { eachVideo in
      eachVideo.properties[kBCOVVideoPropertyKeyId] as? String == currentVideoId
    }
    guard let currentIndex = currentIdx,
          currentIndex + 1 <= playlist.count - 1 else {
      return false
    }
    return true
  }
  class func isPrevVideoAvailable(with currentVideoId: String,in playlist: [BCOVVideo]) -> Bool {
    let currentIdx = playlist.firstIndex { eachVideo in
      eachVideo.properties[kBCOVVideoPropertyKeyId] as? String == currentVideoId
    }
    guard let currentIndex = currentIdx,
          currentIndex - 1 >= 0 else {
      return false
    }
    return true
  }
}
